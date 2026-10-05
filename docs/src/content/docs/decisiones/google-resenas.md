---
title: "Decisión: Google Reseñas"
description: Resumen de por qué el QR de Google Reseñas se genera a partir de un Place ID manual.
sidebar:
  order: 1
---

**Decisión:** usar el **Place ID Finder de Google de forma manual**, sin
clave propia, backend ni cobros de API. Maxi busca el comercio en Finder,
confirma nombre y dirección, y pega el Place ID en la app. También se acepta
una URL de `google.com/maps` que ya incluya `query_place_id`, o un link de
reseña `https://search.google.com/local/writereview?placeid=...`.

**Por qué:** no existe una forma documentada, sin credenciales, de convertir
cualquier link corto de Maps (`maps.app.goo.gl/...`) en un Place ID. Las
alternativas automáticas (Places API) requieren proyecto, facturación y
credenciales propias — fuera del alcance de esta app. El paso manual por
Finder es gratuito, público y no depende de una clave que haya que proteger.

**Qué significa para el día a día:** ver los pasos completos en
[la guía de uso → Google Reseñas](/qr-generator/guia-de-uso/google-resenas/).

**Documento completo:** [`docs/google-resenas.md`](https://github.com/maxiar-org/qr-generator/blob/main/docs/google-resenas.md) —
incluye la comparación completa de alternativas consideradas, costos de la
Places API y las fuentes oficiales citadas.
