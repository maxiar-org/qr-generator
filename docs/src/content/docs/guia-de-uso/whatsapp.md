---
title: QR de WhatsApp
description: Generar una etiqueta con QR de WhatsApp para un comercio.
sidebar:
  order: 1
---

El QR de WhatsApp abre un chat con el comercio, con un mensaje inicial ya escrito
si el comercio quiere uno.

## Pasos

1. En el inicio de la app, tocá **WhatsApp**.
2. Ingresá el celular del comercio. Aceptás el número nacional de 10 dígitos,
   con espacios, guiones o paréntesis, con o sin el `0` antes del código de
   área y el `15` después del código de área (por ejemplo
   `011 15 2345-6789`), o el formato internacional `+549` seguido de esos 10
   dígitos.
3. Opcionalmente, escribí un mensaje para que aparezca precargado en el chat.
4. Tocá **Ver etiqueta**: se genera el QR real apuntando a
   `https://wa.me/<número>?text=<mensaje>`.
5. Elegí la variante de impresión (Adhesivo, Mostrador o Tarjetero) y ajustá el
   texto corto debajo del ícono si querés.
6. Seguí con [imprimir con WePrint](/qr-generator/guia-de-uso/imprimir-con-weprint/).

## Para tener en cuenta

- La app valida el **formato** del número, no si existe o tiene WhatsApp activo.
  Escaneá el QR una vez con otro celular antes de entregar el cartel.
- Si hay más de una forma posible de interpretar un número con `15`, la app no
  adivina: ingresalo sin el `0` inicial ni el `15`.
- Los números fijos y los de otros países quedan fuera de esta versión.
