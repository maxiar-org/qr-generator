# Generación de conceptos

Herramienta integrada `image_gen`; sin CLI ni claves API. Tres llamadas, un intento por concepto, sin regeneraciones.

## Concepto A
Tiempo observado: 39.5 s.

```text
Use case: logo-brand. Create one original flat logo concept for Generador de QR, a practical tool producing printed QR labels for small Argentine shops. Concept A: a compact square paper label with a single cut corner at bottom right and three bold square voids arranged like QR registration modules, extremely reduced geometry. Dark petroleum blue #0F4C5C symbol on warm paper #F7F6F2. Centered single symbol, no text, no shadows, no gradients, no mockup. Must remain distinct and readable at 16 pixels and in pure black and white. Thick shapes and generous negative space. No speech bubbles, phones, cameras, letter G, multicolor motifs, handshakes, or resemblance to WhatsApp Instagram Google Mercado Pago. Vector-friendly design, square canvas.
```

## Concepto B
Tiempo observado: 46.0 s.

```text
Use case: logo-brand. One original logo concept B for Generador de QR, a professional tool for printing QR labels in Argentine shops. A minimalist paper strip exiting a horizontal printing slot: two chunky horizontal geometric bars and one square cutout in the paper, compact balanced silhouette. Single dark petroleum #0F4C5C on warm paper #F7F6F2. Single centered mark without text, flat vector-like geometry, no gradients or shadows. Legible at 16px and pure black and white; very few thick shapes. Avoid speech bubbles, phones, cameras, G letters, colorful branding, handshake, and resemblance to WhatsApp Instagram Google Mercado Pago. Square canvas.
```

## Concepto C
Tiempo observado: 44.0 s.

```text
Use case: logo-brand. Create one original concept C for Generador de QR, a practical QR label printing app for Argentine shops. Abstract stamp: three solid chunky squares in an L arrangement, with a short diagonal rectangular block occupying bottom-right, suggesting a label being applied. Just four separate bold shapes, no enclosing border, no tiny QR details. Single dark petroleum blue #0F4C5C on warm paper #F7F6F2. Flat vector-like symbol centered on square canvas. No text, shadows, gradients, speech bubbles, phones, camera outline, G letters, handshake, multicolor or resemblance to WhatsApp Instagram Google Mercado Pago. Must work at 16px and in black and white.
```

## Resultado y limitaciones

Se eligió C y se redibujó con cuatro primitivas SVG, ajustando proporciones, radios y espacios para una grilla de 64 unidades. El resultado generado era raster y traía variaciones sutiles de tono; el SVG fija el color exacto y elimina esas variaciones. No se usó autotrace ni se tomó el raster como ícono final. A conserva su silueta a 16 px pero pierde detalle: esa limitación motivó descartarlo, sin gastar otra generación. B conserva la silueta de impresión pero es menos propio del producto.

Las imágenes originales se copiaron desde `$CODEX_HOME/generated_images/` sin modificarlas. La herramienta tardó aproximadamente 39, 46 y 44 segundos por concepto (tiempo de llamada observado, no de GPU). No hubo errores ni reintentos. Los prompts completos de arriba son los enviados a la herramienta integrada. No se usaron CLI de generación ni API keys.

El README de `maxiar-org/ai-dev-team` consultado durante la tarea no contenía la sección «Generación de imágenes»; se aplicaron las instrucciones del issue y de la skill `imagegen`.

## Verificación

- TDD: primero fallaron los tests nuevos por la paleta Flutter y el tamaño del favicon; luego pasaron con los assets y metadatos nuevos.
- `flutter analyze`: sin observaciones. `flutter test`: 88 tests en verde. `flutter build web --release`: correcto.
- Playwright, viewport 390 × 844: inicio → WhatsApp / Instagram → datos → etiqueta → botón Copiar link. Capturas de ambas vistas previas junto a esta nota. No se verificó el portapapeles del sistema ni una instalación física en iPhone.
- Pestaña real de Chromium con interfaz visible en Xvfb, capturada desde el servidor del build; no es una pestaña dibujada en HTML.
- Lámina en navegador con SVG a 16/32 px y negro puro, y simulación de inicio iOS que usa el PNG real. No es una captura de un iPhone físico.
- Detector Impeccable sobre los HTML modificados: sin hallazgos. No evalúa los widgets Flutter ni certifica el logo; la revisión de la identidad es visual.
- Impeccable avisó que `PRODUCT.md` dice web aunque hay proyecto iOS. Se conserva el alcance PWA explícito del producto; no se cambia la plataforma documentada en este issue.

Revisión final independiente de identidad: **ship**, sin hallazgos materiales. Revisión documental: paleta y alcance coherentes; se alineó la versión de CairoSVG del script con las instrucciones de reproducción.
