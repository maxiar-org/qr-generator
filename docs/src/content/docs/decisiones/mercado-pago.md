---
title: "Decisión: Mercado Pago"
description: Resumen del spike de opciones de QR de Mercado Pago en Argentina.
sidebar:
  order: 2
---

:::note
El issue #20 implementa la decisión de Eduardo: escanear el QR que ya tiene
el comercio, o cargar una foto, confirmar el contenido y regenerar la etiqueta.
La validación reconoce el formato; no verifica titular ni vigencia del cobro.
La prueba física en iPhone y DT01 sigue pendiente. Ver el
[recorrido y las capturas](https://github.com/maxiar-org/qr-generator/tree/agent/20-mercado-pago-escanear-con-la-camara-el-q/docs/evidence/issue-20).
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

**Pendiente para el piloto:** probar el circuito completo con el QR vigente
de un comercio, desde Safari en iPhone hasta la impresión y lectura del papel.

**Documento completo:** [`docs/mercado-pago.md`](https://github.com/maxiar-org/qr-generator/blob/main/docs/mercado-pago.md) —
incluye la tabla comparativa completa, tarifas de cada opción, las preguntas
abiertas para Eduardo y las fuentes oficiales citadas (Mercado Pago y BCRA).
