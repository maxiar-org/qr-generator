---
title: "Decisión: Impresión directa"
description: Resumen del spike de impresión directa por Bluetooth a la DT01 desde iOS.
sidebar:
  order: 3
---

:::note
Esto es un spike experimental, no un flujo disponible en la app principal.
Hoy se imprime guardando la imagen y abriéndola desde **WePrint** — ver
[Imprimir con WePrint](/qr-generator/guia-de-uso/imprimir-con-weprint/).
:::

**Qué se investigó:** si se puede imprimir directo por Bluetooth a la
Detonger DT01 desde una app iOS nativa, sin pasar por WePrint, usando el
plugin `flutter_dothantech_lpapi_thermal_printer` (puente al SDK LPAPI).

**Conclusión:** viable como experimento nativo — el puente iOS existe y
llama de verdad a las funciones de LPAPI (buscar, conectar, imprimir) — pero
la compatibilidad concreta con la DT01 de Maxi **todavía no está confirmada**
con el equipo físico. No se probó desde Linux por falta de acceso a Mac,
iPhone y Xcode.

**Dónde está el prototipo:** [`prototypes/lpapi_ios`](https://github.com/maxiar-org/qr-generator/tree/main/prototypes/lpapi_ios),
una app Flutter separada (no comparte `pubspec.yaml` con la app principal),
con destino único iOS y el botón **Imprimir** detrás de un flag apagado por
defecto (`--dart-define=LPAPI_SPIKE=true`).

**Qué falta para decidir si reemplaza a WePrint:** la prueba física con el
iPhone y la DT01 de Maxi (descubrimiento por Bluetooth, impresión, medición
del ancho real, lectura del QR, y los casos de error: sin papel, impresora
apagada, Bluetooth rechazado).

**Documento completo:** [`docs/impresion-directa.md`](https://github.com/maxiar-org/qr-generator/blob/main/docs/impresion-directa.md) —
incluye la tabla de evidencia revisada, cómo preparar el Mac y el iPhone, el
instructivo paso a paso para la prueba física, y los riesgos pendientes.
