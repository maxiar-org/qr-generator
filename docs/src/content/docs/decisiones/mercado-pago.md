---
title: "Decisión: Mercado Pago"
description: Resumen del spike de opciones de QR de Mercado Pago en Argentina.
sidebar:
  order: 2
---

:::note
Este QR todavía **no está implementado** en la app: la pantalla de Mercado
Pago muestra "Próximamente". Lo que sigue es un resumen de la investigación
de opciones, no de una funcionalidad disponible.
:::

**Opciones comparadas:** transferencia por alias/CVU, link de pago de
Mercado Pago, y el QR interoperable de Transferencias 3.0 (pago con
transferencia, PCT).

**Recomendación del spike:** importar el **QR interoperable oficial** que ya
tiene el comercio (sin generarlo desde su alias), acompañado del titular y un
alias legible como alternativa manual. Es la opción más parecida a un cartel
permanente: funciona desde distintas billeteras y apps bancarias, no solo
desde Mercado Pago.

**Por qué no un QR armado desde el alias/CVU:** un alias o CVU identifica una
cuenta, no una orden de cobro — no hay garantía de que un QR con ese texto se
pueda pagar desde el lector de cualquier billetera. El QR comercial lo emite
un aceptador (Mercado Pago u otro), no se puede derivar solo del alias.

**Pendiente antes de implementar:** confirmar con Eduardo si se prioriza
pagar sin comisión (alias/CVU, transferencia manual) o cobrar con QR
interoperable (con comisión, pero funciona desde más apps), y conseguir un
comercio piloto para probar el circuito completo.

**Documento completo:** [`docs/mercado-pago.md`](https://github.com/maxiar-org/qr-generator/blob/main/docs/mercado-pago.md) —
incluye la tabla comparativa completa, tarifas de cada opción, las preguntas
abiertas para Eduardo y las fuentes oficiales citadas (Mercado Pago y BCRA).
