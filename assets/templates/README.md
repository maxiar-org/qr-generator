# Templates de cartelería

Versiones **de ejemplo**, pendientes de los diseños finales de Eduardo. Generadas
con la herramienta integrada `image_gen` y referencias JPG reducidas con Pillow
(a un máximo de 768 px por lado y menos de 300 KB). No se usó CLI ni API.

Los cuatro PNG RGBA miden **1200 × 1800 px** (vertical 2:3). Solo el interior
rectangular del recuadro tiene alfa 0; todo lo demás tiene alfa 255.
No contienen un QR: se dibuja encima en la previsualización (#34), centrado y
escalado dentro del recuadro transparente.

| Archivo | Tipo de QR |
|---|---|
| `google-resenas.png` | Reseñas de Google |
| `instagram.png` | Instagram |
| `mercadopago.png` | Mercado Pago |
| `whatsapp.png` | WhatsApp |

## Catálogo (`templates.json`)

`templates.json` lista los templates que ofrece la app. Cada entrada:

```json
{
  "id": "whatsapp",
  "name": "WhatsApp",
  "image": "assets/templates/whatsapp.png",
  "tags": ["whatsapp"]
}
```

- `id`: identificador único y estable (no se muestra).
- `name`: nombre visible en el selector.
- `image`: ruta del asset, relativa a la raíz del repo.
- `tags`: tipos de QR donde aplica (`google`, `instagram`, `whatsapp`,
  `mercadopago`; un template puede llevar varios) y, opcionalmente, el
  formato (`adhesivo`, `mostrador`, `tarjetero`) como una etiqueta más.
- `frame` (opcional): `[izquierda, arriba, derecha, abajo]` en coordenadas
  **relativas** (0 a 1) al ancho y alto de la imagen, con derecha y abajo
  **exclusivos** (mismo formato que imprime el verificador de abajo). Solo
  hace falta para templates **sin** recuadro transparente: si la imagen es
  un PNG con el recuadro transparente, la app lo detecta sola y `frame` se
  puede omitir.

### Sumar un template nuevo

1. Agregá el PNG a esta carpeta. Si tiene el recuadro transparente (ver
   abajo), no hace falta nada más que una entrada en `templates.json` con
   `id`, `name`, `image` y `tags` (sin `frame`): la app calcula el recuadro
   sola. No hace falta tocar código ni `pubspec.yaml` (la carpeta completa
   ya está declarada como asset).
2. Si el PNG no tiene transparencia (por ejemplo, un diseño final de
   imprenta sin recuadro recortado), agregá `frame` a mano con las
   coordenadas relativas del recuadro.

## Verificar o sumar un template

Necesitás Python 3 y Pillow (`python3 -m pip install Pillow`). Desde la raíz:

```sh
python3 scripts/templates_transparent.py assets/templates/*.png
python3 -m unittest discover -s scripts -p test_templates_transparent.py
```

El verificador acepta uno o varios archivos. Rechaza tamaños menores, proporciones
distintas de 2:3, transparencia parcial, huecos que toquen el borde, huecos
irregulares y varios huecos separados. Devuelve código 1 si algún archivo falla.
Imprime JSON por archivo: `pixels` y `relative` contienen
`[izquierda, arriba, derecha, abajo]`, con derecha y abajo **exclusivos**.
Las coordenadas relativas se dividen por el ancho o el alto correspondiente;
no se guardan como configuración de la UI.

`previews/` contiene capturas reducidas sobre fondo salmón: el color visible dentro
del recuadro demuestra la transparencia. Son evidencia, no templates para la app.

## Generación y posproceso

Prompts usados (una llamada integrada por marca, con su JPG de referencia):

- Común: recrear la referencia como cartel plano nítido de alta resolución,
  vertical 2:3; conservar composición, colores y marca reconocible; interior
  del recuadro transparente y resto opaco; sin QR, perspectiva ni mockup.
- Google: marca multicolor arriba, cinco estrellas doradas, marco central de cuatro
  colores y regla inferior. Textos: “DEJANOS TU RESEÑA”, “¡Tu opinión es muy valiosa!”,
  “Ayudanos compartiendo tu experiencia.”
- Instagram: ícono degradado y “Seguinos en Instagram” arriba, marco violeta,
  “Descubrí más novedades, contenido y promociones.” debajo y marca al pie.
- Mercado Pago: logo del apretón de manos y marca arriba, línea y marco turquesa,
  textos azul marino “PAGÁ CON QR”, “Rápido, fácil y seguro.”,
  “Escaneá el código para pagar”; pie turquesa con “Elegí tu medio de pago”.
- WhatsApp: “Agendanos”, logo y marca verdes arriba, marco central verde,
  ícono de conversación y “Escribí y consultá.” debajo, línea verde al pie.

Pillow compuso las salidas sobre blanco para volver opaco el exterior, escaló
con Lanczos de 1024 × 1536 a 1200 × 1800 y recortó un rectángulo de alfa 0
sin suavizado. El marco redondeado de WhatsApp se corrigió a rectangular.
Los textos se revisaron visualmente. Las marcas son recreaciones de ejemplo,
no archivos oficiales ni diseños finales de imprenta.
