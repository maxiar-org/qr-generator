---
title: Instalar la app en el iPhone
description: Agregar el Generador de QR a la pantalla de inicio del iPhone.
sidebar:
  order: 5
---

El Generador de QR es una PWA (Progressive Web App): no está en la App Store,
pero se puede agregar a la pantalla de inicio del iPhone para abrirla como
cualquier otra app, con su propio ícono y sin la barra de Safari.

## Pasos

1. Abrí la URL de la app en **Safari** (tiene que ser Safari: Chrome en iOS no
   ofrece esta opción).
2. Tocá el botón de **Compartir** (el cuadrado con la flecha hacia arriba), en
   la barra inferior.
3. Deslizá hasta encontrar **Agregar a pantalla de inicio** y tocalo.
4. Confirmá el nombre (**Generador de QR**) y tocá **Agregar**, arriba a la
   derecha.

Va a aparecer un ícono nuevo en la pantalla de inicio. Al abrirlo, la app
ocupa toda la pantalla, sin la barra de direcciones de Safari.

## Por qué conviene

- Un toque menos para empezar a generar una etiqueta: no hace falta buscar el
  link ni tener la pestaña abierta.
- La app se ve y se siente como una app instalada (pantalla completa, ícono
  propio), aunque siga corriendo en el navegador.

## Si no aparece la opción

- Confirmá que estás usando Safari, no otro navegador.
- Si la app se sirve por HTTP en la red local (por ejemplo durante una prueba
  con Docker), **Agregar a pantalla de inicio** funciona igual, pero algunas
  funciones que requieren HTTPS (como la hoja de compartir al guardar la
  imagen) pueden no estar disponibles — ver
  [Imprimir con WePrint](/qr-generator/guia-de-uso/imprimir-con-weprint/#si-no-tenés-https-a-mano).
