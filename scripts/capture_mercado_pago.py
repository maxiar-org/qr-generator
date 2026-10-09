"""Playwright evidence and regressions; serve build/web on localhost:8765."""
from pathlib import Path
from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "docs/evidence/issue-20"
OUTPUT.mkdir(parents=True, exist_ok=True)
with sync_playwright() as p:
    browser = p.chromium.launch()
    context = browser.new_context(viewport={"width": 390, "height": 844},
                                  permissions=["clipboard-read", "clipboard-write"])
    page = context.new_page()
    def home():
        page.goto("http://localhost:8765")
        page.wait_for_timeout(5000)
        page.locator("flt-semantics-placeholder").evaluate("(e) => e.click()")
    def shot(name):
        page.wait_for_timeout(500)
        page.screenshot(path=str(OUTPUT / name))
    def upload(name):
        page.get_by_role("button", name="Subir foto del QR").click()
        page.locator("input[type=file]").set_input_files(str(ROOT / f"test/fixtures/mercado_pago/{name}.png"))
    home()
    page.get_by_text("Mercado Pago", exact=True).click()
    shot("01-captura.png")
    upload("link")
    page.get_by_text("Contenido capturado", exact=True).wait_for()
    shot("02-confirmacion.png")
    page.get_by_role("button", name="Confirmar y ver etiqueta").click()
    page.get_by_role("button", name="Guardar imagen", exact=True).wait_for()
    shot("03-etiqueta.png")
    for variant, height in [("Adhesivo",464), ("Mostrador",640), ("Tarjetero",560)]:
        page.get_by_role("button", name=variant, exact=True).click()
        page.wait_for_timeout(600)
        with page.expect_download() as download:
            page.get_by_role("button", name="Guardar imagen", exact=True).click()
        download.value.save_as(str(OUTPUT / f"etiqueta-{height}.png"))
        # Independently decode the actual PNG, including its printed label.
        page.evaluate("window.decoded = undefined; void window.qrCapture(false).then(v => window.decoded = v)")
        page.locator("input[type=file]").set_input_files(str(OUTPUT / f"etiqueta-{height}.png"))
        page.wait_for_function("window.decoded !== undefined")
        assert page.evaluate("window.decoded") == (ROOT / "test/fixtures/mercado_pago/link.txt").read_text()
    page.get_by_role("button", name="Copiar contenido", exact=True).click()
    assert page.evaluate("navigator.clipboard.readText()") == (ROOT / "test/fixtures/mercado_pago/link.txt").read_text()
    home()
    page.get_by_text("Mercado Pago", exact=True).click()
    upload("unrelated")
    page.locator("flt-semantics span").filter(has_text="No reconocemos").wait_for()
    shot("04-qr-ajeno.png")
    assert page.get_by_role("button", name="Confirmar y ver etiqueta").count() == 0
    upload("emv")
    page.locator("flt-semantics span").filter(has_text="estructura EMVCo").wait_for()
    shot("05-emvco.png")
    page.get_by_role("button", name="Confirmar y ver etiqueta").click()
    page.wait_for_timeout(1000)
    with page.expect_download() as download:
        page.get_by_role("button", name="Guardar imagen", exact=True).click()
    download.value.save_as(str(OUTPUT / "etiqueta-emv.png"))
    page.get_by_role("button", name="Copiar contenido", exact=True).click()
    assert page.evaluate("navigator.clipboard.readText()") == (ROOT / "test/fixtures/mercado_pago/emv.txt").read_text()
    page.evaluate("window.decoded = undefined; void window.qrCapture(false).then(v => window.decoded = v)")
    page.locator("input[type=file]").set_input_files(str(OUTPUT / "etiqueta-emv.png"))
    page.wait_for_function("window.decoded !== undefined")
    assert page.evaluate("window.decoded") == (ROOT / "test/fixtures/mercado_pago/emv.txt").read_text()
    home()
    page.get_by_text("Mercado Pago", exact=True).click()
    page.evaluate("""() => { navigator.mediaDevices.getUserMedia = async () => {
        throw new DOMException('Denied', 'NotAllowedError');
    }; }""")
    page.get_by_role("button", name="Escanear QR del comercio").click()
    page.get_by_text("No pudimos abrir la cámara.", exact=False).wait_for()
    shot("06-permiso-denegado.png")
    page.get_by_role("button", name="Cancelar", exact=True).click()
    # Feed real QR pixels through a simulated MediaStream, not a decoded result.
    image_data = (ROOT / "test/fixtures/mercado_pago/link.png").read_bytes()
    import base64
    page.evaluate("""async (url) => {
        const image = new Image(); image.src = url; await image.decode();
        const canvas = document.createElement('canvas');
        canvas.width = image.width; canvas.height = image.height;
        canvas.getContext('2d').drawImage(image, 0, 0);
        window.mockStream = canvas.captureStream(10);
        navigator.mediaDevices.getUserMedia = async (constraints) => {
            window.cameraConstraints = constraints;
            return window.mockStream;
        };
    }""", "data:image/png;base64," + base64.b64encode(image_data).decode())
    page.get_by_role("button", name="Escanear QR del comercio").click()
    page.get_by_text("Contenido capturado", exact=True).wait_for()
    assert page.evaluate("cameraConstraints.video.facingMode.ideal") == "environment"
    assert page.evaluate("mockStream.getTracks().every(t => t.readyState === 'ended')")
    shot("07-camara-simulada.png")
    # Regression flows explicitly required by AGENTS.md.
    for title, field, value, expected in [
        ("WhatsApp","Celular argentino","011 15 2345-6789","https://wa.me/5491123456789"),
        ("Instagram","Usuario o enlace de Instagram","@mi_comercio","https://instagram.com/mi_comercio")
    ]:
        home()
        page.get_by_text(title, exact=True).click()
        page.get_by_role("textbox", name=field, exact=False).fill(value)
        page.get_by_role("button", name="Ver etiqueta", exact=True).click()
        page.wait_for_timeout(1000)
        page.get_by_role("button", name="Copiar link", exact=True).click()
        assert page.evaluate("navigator.clipboard.readText()") == expected
        with page.expect_download() as download:
            page.get_by_role("button", name="Guardar imagen", exact=True).click()
        assert download.value.suggested_filename.endswith(".png")
    page.set_viewport_size({"width":1280,"height":900})
    home()
    page.get_by_text("Mercado Pago", exact=True).click()
    upload("link")
    page.get_by_text("Contenido capturado", exact=True).wait_for()
    shot("08-desktop.png")
    browser.close()
print("Mercado Pago, camera simulation, exports and WhatsApp/Instagram: passed")
