# Mercado Pago — evidencia del issue #20

La app captura el QR existente del comercio con cámara o foto, muestra su
contenido sin modificar y pide confirmación antes de regenerar la etiqueta.
No crea cobros ni necesita credenciales de Mercado Pago. Las fotos y los frames
se decodifican localmente con jsQR 1.4.0 (código y licencia en `web/vendor/`).

## Ver el flujo

- [Elegir cámara o foto](01-captura.png)
- [Confirmar el contenido](02-confirmacion.png)
- [Etiqueta](03-etiqueta.png)
- [Advertencia por QR ajeno](04-qr-ajeno.png)
- [Payload EMVCo](05-emvco.png)
- [Permiso de cámara denegado](06-permiso-denegado.png)
- [Cámara simulada con píxeles de un QR](07-camara-simulada.png)
- [Escritorio](08-desktop.png)
- [App servida por HTTPS](09-https.png)

Los PNG `etiqueta-464.png`, `etiqueta-640.png` y `etiqueta-560.png` tienen
464 px de ancho. `etiqueta-emv.png` conserva el payload EMVCo original.
Los fixtures de `test/fixtures/mercado_pago/` son de prueba: **no pagar**.
`interoperable` es sintético; `emv` sigue el formato de los ejemplos de la documentación
[de Mercado Pago](https://www.mercadopago.com.ar/developers/es/docs/qr-code/interoperable/acceptor-flow/tests).

## Reproducir

```sh
flutter analyze
flutter test
flutter build web --release
python3 -m http.server 8765 --directory build/web
```

En otra terminal, con Python y Playwright instalados:

```sh
python3 -m pip install playwright
python3 -m playwright install chromium
python3 scripts/test_qr_capture.py
python3 scripts/capture_mercado_pago.py
```

Los scripts prueban decodificación desde PNG (link, EMVCo, interoperable,
QR ajeno e imagen sin QR), cancelación, permiso denegado y cámara simulada.
El recorrido de UI confirma y exporta las tres variantes, vuelve a decodificar
los PNG exportados y verifica el portapapeles. Recorre también WhatsApp e
Instagram hasta guardar y copiar.

Verificación del 9/10/2026: `flutter analyze` sin observaciones, 110 tests
Flutter en verde y build web release correcto. La prueba del límite de bytes
falló antes de corregir el validador y pasó después. Ambos scripts Playwright
pasaron completos. El túnel respondió HTTP 200 y Chromium confirmó
`isSecureContext` y disponibilidad de `getUserMedia`.

El detector de Impeccable no analiza los widgets Flutter; se revisaron las
capturas manualmente. Sobre el CSS del escáner sólo señaló el negro del fondo
del video: es intencional para el área sin imagen de la cámara.

## Prueba real en iPhone — pendiente

Este entorno no tiene acceso a un iPhone ni a la DT01. La cámara simulada de
Chromium **no reemplaza** esta prueba de aceptación. No se hicieron pagos.

Con el servidor anterior activo, ejecutar:

```sh
cloudflared tunnel --url http://localhost:8765
```

Abrir en Safari del iPhone la URL HTTPS que imprime el comando. El túnel es
[temporal](https://developers.cloudflare.com/tunnel/get-started/quick-tunnels/)
y requiere mantener ambos procesos activos.

1. Inicio → Mercado Pago → **Escanear QR del comercio**. Permitir la cámara y
   comprobar que usa la trasera. Escanear el QR vigente del comercio.
2. Verificar con el comercio el contenido capturado, confirmar y elegir cada
   variante. Guardar el PNG en Fotos o copiar el contenido.
3. Repetir con **Subir foto del QR**, y con permiso denegado/cancelación.
4. Importar el PNG en WePrint, imprimir en la DT01 y comprobar su lectura.
5. Registrar en el PR modelo de iPhone, versión de iOS, resultado y captura.

La validación reconoce enlaces HTTPS de `mpago.la` y
`link.mercadopago.com.ar`, o estructura EMVCo argentina (AR/032, cuenta,
campos obligatorios y CRC). Es reconocimiento de formato: no autentica el
aceptador, titular ni vigencia. Los QR dinámicos o con importe muestran una
advertencia porque pueden no servir para cartelería permanente. Los payloads
muy densos requieren comprobar lectura del papel; no se promete validar
comercialmente cualquier QR interoperable.
