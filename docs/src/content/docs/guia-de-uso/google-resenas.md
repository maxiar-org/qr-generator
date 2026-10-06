---
title: QR de Google Reseñas
description: Generar una etiqueta con QR de Google Reseñas para un comercio.
sidebar:
  order: 3
---

El QR de Google Reseñas abre directamente el formulario para dejar una reseña
del comercio. Como Google no ofrece una forma de convertir cualquier link de
Maps en el identificador que necesitamos, hay un paso manual: ver
[por qué en Decisiones](/qr-generator/decisiones/google-resenas/).

## Pasos

1. Si tenés un link corto (`maps.app.goo.gl/...`) o una URL sin ID explícito,
   abrilo en Maps y anotá el **nombre** y la **dirección** de la sucursal.
2. Abrí el [Place ID Finder de Google](https://developers.google.com/maps/documentation/places/web-service/place-id),
   buscá ese nombre y dirección y confirmá que sea la sucursal correcta.
   Copiá el **Place ID** que muestra (no el CID ni la URL del navegador).
3. En la app, tocá **Google Reseñas**, pegá el Place ID (o una URL de Maps que
   ya incluya `query_place_id`) y tocá **Generar QR**.
4. Escaneá el QR con otro celular: debe abrir la reseña del comercio elegido.
   Verificá el nombre antes de imprimir — no hace falta publicar una reseña
   para probar.
5. Tocá **Vista previa de impresión**, elegí la variante (Adhesivo, Mostrador
   o Tarjetero) y ajustá el texto si querés.
6. Seguí con [imprimir con WePrint](/qr-generator/guia-de-uso/imprimir-con-weprint/).

## Para tener en cuenta

- El QR contiene `https://search.google.com/local/writereview?placeid=<PLACE_ID>`.
- Google puede cambiar el Place ID de un comercio: si vas a reimprimir
  cartelería vieja, volvé a verificarlo en Finder antes de imprimir.
- Si editás el Place ID o la URL después de generar el QR, el resultado
  anterior se borra para evitar imprimir el QR equivocado.
