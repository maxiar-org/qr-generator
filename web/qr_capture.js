/* Local-only acquisition. jsQR 1.4.0 is vendored; no CDN at runtime. */
(() => {
  let cancelActive = () => {};
  window.cancelQrCapture = () => cancelActive();
  window.qrCapture = (camera) => new Promise((resolve) => {
    cancelActive();
    const previousFocus = document.activeElement;
    const dialog = document.createElement("dialog");
    dialog.className = "qr-capture";
    const title = document.createElement("h2");
    title.id = "qr-capture-title";
    title.textContent = camera ? "Escanear QR del comercio" : "Subir foto del QR";
    dialog.setAttribute("aria-labelledby", title.id);
    const status = document.createElement("p");
    status.setAttribute("role", "status");
    status.textContent = camera ? "Apuntá al QR completo, con buena luz." : "Elegí una foto donde se vea el QR completo.";
    const video = document.createElement("video");
    video.setAttribute("playsinline", "");
    video.muted = true;
    video.autoplay = true;
    video.hidden = !camera;
    const input = document.createElement("input");
    input.type = "file";
    input.accept = "image/*";
    input.setAttribute("aria-label", "Foto del QR");
    input.hidden = camera;
    const cancel = document.createElement("button");
    cancel.textContent = "Cancelar";
    dialog.append(title, status, video, input, cancel);
    document.body.append(dialog);
    dialog.showModal();

    let done = false;
    let stream;
    let timer;
    let objectUrl;
    const stopStream = (value) => value?.getTracks().forEach(track => track.stop());
    const finish = (value = null) => {
      if (done) return;
      done = true;
      clearTimeout(timer);
      stopStream(stream);
      video.srcObject = null;
      if (objectUrl) URL.revokeObjectURL(objectUrl);
      window.removeEventListener("pagehide", onHide);
      document.removeEventListener("visibilitychange", onVisibility);
      dialog.close();
      dialog.remove();
      cancelActive = () => {};
      previousFocus?.focus();
      resolve(value);
    };
    const onHide = () => finish();
    const onVisibility = () => { if (camera && document.hidden) finish(); };
    window.addEventListener("pagehide", onHide);
    document.addEventListener("visibilitychange", onVisibility);
    cancelActive = finish;
    cancel.onclick = () => finish();
    dialog.oncancel = (event) => { event.preventDefault(); finish(); };

    const canvas = document.createElement("canvas");
    const context = canvas.getContext("2d", {willReadFrequently: true});
    function decode(source, width, height) {
      const ratio = Math.min(1, 1600 / Math.max(width, height));
      canvas.width = Math.round(width * ratio);
      canvas.height = Math.round(height * ratio);
      context.drawImage(source, 0, 0, canvas.width, canvas.height);
      const pixels = context.getImageData(0, 0, canvas.width, canvas.height);
      return window.jsQR(pixels.data, pixels.width, pixels.height)?.data ?? null;
    }
    input.onchange = async () => {
      const file = input.files[0];
      if (!file || done) return;
      if (file.size > 20 * 1024 * 1024) {
        status.textContent = "La foto supera los 20 MB. Elegí una imagen más chica.";
        input.value = "";
        return;
      }
      input.disabled = true;
      status.textContent = "Leyendo foto…";
      try {
        objectUrl = URL.createObjectURL(file);
        const image = new Image();
        image.src = objectUrl;
        await image.decode();
        if (done) return;
        const data = decode(image, image.naturalWidth, image.naturalHeight);
        if (data) finish(data);
        else status.textContent = "No encontramos un QR. Probá otra foto más cerca y con buena luz.";
      } catch (_) {
        if (!done) status.textContent = "No pudimos abrir esta foto. Probá con una imagen JPG o PNG.";
      } finally {
        if (objectUrl) URL.revokeObjectURL(objectUrl);
        objectUrl = null;
        input.disabled = false;
        input.value = "";
      }
    };

    if (!camera) return;
    if (!window.isSecureContext || !navigator.mediaDevices?.getUserMedia) {
      status.textContent = "La cámara necesita HTTPS y un navegador compatible. Volvé y subí una foto del QR.";
      video.hidden = true;
      return;
    }
    navigator.mediaDevices.getUserMedia({
      audio: false,
      video: {facingMode: {ideal: "environment"}, width: {ideal: 1280}, height: {ideal: 720}}
    }).then(async (value) => {
      if (done) { stopStream(value); return; }
      stream = value;
      video.srcObject = stream;
      await video.play();
      if (done) return;
      const tick = () => {
        if (done) return;
        try {
          if (video.readyState >= 2 && video.videoWidth) {
            const data = decode(video, video.videoWidth, video.videoHeight);
            if (data) { finish(data); return; }
          }
        } catch (_) {
          status.textContent = "No pudimos leer la cámara. Volvé y probá subiendo una foto.";
          stopStream(stream);
          return;
        }
        timer = setTimeout(tick, 180);
      };
      tick();
    }).catch(() => {
      stopStream(stream);
      if (!done) {
        video.hidden = true;
        status.textContent = "No pudimos abrir la cámara. Habilitá el permiso en Safari o volvé y subí una foto.";
      }
    });
  });
})();
