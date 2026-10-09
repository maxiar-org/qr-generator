# Identidad de Generador de QR

`logo.svg` es la fuente vectorial: tres módulos y una etiqueta diagonal, redibujados a partir del concepto C generado con `image_gen`. Usa Sello (`#0F4C5C`). Funciona sin depender del color y sin texto a 16 px. No representa un QR escaneable.

Se eligió C por su silueta simple y sus espacios abiertos. A pierde detalle interno al reducirse; B se parece a un comando genérico de impresión. El símbolo no usa globos, teléfonos, cámaras, letras de Google ni apretones de manos. La revisión visual no encontró parecido con WhatsApp, Instagram, Google o Mercado Pago; no es una búsqueda exhaustiva de marcas registradas.

No se necesita versión horizontal en este issue: la cabecera queda para el siguiente. El SVG tiene fondo transparente para ese uso futuro; todos los PNG de instalación llevan fondo Papel opaco (`#F7F6F2`) y sin esquinas recortadas.

## Regenerar íconos

Desde la raíz (Python 3 y biblioteca de sistema Cairo):

```sh
python3 -m venv /tmp/qr-branding-venv
/tmp/qr-branding-venv/bin/pip install CairoSVG==2.9.1
/tmp/qr-branding-venv/bin/python scripts/generate_branding.py
flutter test test/branding_test.dart
```

El script sólo rasteriza el SVG local: no genera imágenes con IA, no llama APIs ni requiere claves. Produce favicon de 32 px, íconos de 192/512 px, maskable de 192/512 px y Apple Touch de 180 px. El navegador reduce el favicon a 16 px.

En maskable, el dibujo se escala al 72% y se centra: su esquina extrema queda a menos del 38,2% del lado desde el centro, dentro del círculo seguro de radio 40%. El test verifica los píxeles de tinta, dimensiones y opacidad de los archivos entregados.

## Evidencia

[Registro y prompts](../../docs/issue-28/generation.md), [lámina](../../docs/issue-28/identity-board.png), [pestaña real de Chromium](../../docs/issue-28/favicon-browser.png) y [simulación de iPhone](../../docs/issue-28/iphone-simulation.png).

Los tres originales generados quedan en `docs/issue-28/concepts/`, fuera de los assets de la app. Para explorar la lámina y ver el logo en tamaño real:

```sh
python3 -m http.server 8828
```

Abrí http://localhost:8828/docs/issue-28/preview.html.

Esta entrega define el logo sobre la paleta existente del issue #26. La frase histórica de `PRODUCT.md` sobre ausencia de identidad describe el estado previo a esta entrega; no cambia el nombre funcional ni los principios del producto.
