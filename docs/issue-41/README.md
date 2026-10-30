# Segundo template por tipo de QR

Variantes de ejemplo: **Noche** (Google Reseñas), **Ciruela** (Instagram),
**Celeste** (Mercado Pago) y **Verde** (WhatsApp). Los originales siguen primero.
La diferencia principal es el fondo pleno y el llamado a la acción debajo del QR.
Los nombres cortos se leen en las miniaturas de 64 px.

## Generación y posproceso

Se usó la skill de sistema `imagegen` con la herramienta integrada `image_gen`,
una llamada por diseño. Sin CLI, API ni fallback Gemini.
Los prompts completos están en `prompts.json` y en los metadatos de cada PNG.
Se inspeccionaron los originales mediante copias JPG de 512 × 768 px, menores
que 300 KB; las generaciones partieron de texto, sin adjuntar referencias.

El generador entregó transparencias difusas: se conservaron los logos generados,
se recortaron y se limpiaron sus alfas con Pillow. Se compusieron fondos opacos
(#14233D, #632448, #007FA3 y #075E54) y textos con IBM Plex Sans del repositorio.
En WhatsApp se eliminaron también los restos verdes del fondo del logo.
La tipografía principal usa peso 650 y 94 px; el texto secundario, 49 px.

Cada PNG mide 1200 × 1800 px. El único hueco transparente ocupa
`[180, 380, 1020, 1220)` (840 × 840 px), rodeado de blanco y con alfa 0;
todo el resto tiene alfa 255. No hay `frame` en el catálogo: Flutter lo detecta.
`pubspec.yaml` ya registra todo `assets/templates/`.

## Verificación y recorrido

```sh
flutter analyze
flutter test
python3 -m unittest discover -s scripts -p test_templates_transparent.py
python3 scripts/templates_transparent.py assets/templates/*-noche.png assets/templates/*-ciruela.png assets/templates/*-celeste.png assets/templates/*-verde.png
flutter build web --release
python3 -m http.server 8766 --directory build/web
```

Abrí http://localhost:8766 con viewport 390 × 844. Para cada tipo, elegí ambas
miniaturas y luego «Ver en pantalla completa»; cerrá con la X.

- WhatsApp: celular de ejemplo `1123456789` → «Ver etiqueta».
- Instagram: usuario de ejemplo `comercio.ejemplo` → «Ver etiqueta».
- Google: Place ID ficticio `ChIJ_ejemplo` → «Generar QR» → «Vista previa de impresión».
- Mercado Pago: «Subir foto del QR» con `test/fixtures/mercado_pago/link.png` → «Confirmar y ver etiqueta».

Las capturas `*-original.png`, `*-alternativo.png` y `*-completa.png` documentan
las dos opciones y la pantalla completa. Se verificó copiar el enlace de WhatsApp
e Instagram desde la previsualización. Son datos de prueba, no comercios reales.

El detector HTML/CSS de Impeccable no aplica a estos PNG ni al canvas de Flutter.
Se revisaron las capturas móviles; no se modificó el sistema de diseño de la app.

## Límites

Son diseños de ejemplo, no los definitivos de Eduardo. La validación es de web;
no se hizo impresión física con la DT01. El flujo «Guardar imagen» conserva la
etiqueta térmica existente: seleccionar un cartel cambia la previsualización y
la pantalla completa, tal como funciona desde #34.
