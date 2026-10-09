# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Stack

Flutter (stable), con web como primer objetivo (PWA). Existe un proyecto iOS generado por Flutter para una etapa posterior, pero hoy no hay una build ni un lenguaje visual nativo distintos: es el mismo árbol de widgets.

## Users

- **Maxi**, usuaria primaria: vende cartelería con códigos QR a comercios de Argentina. Usa la app parada en el local del comercio, desde su iPhone, para armar la etiqueta en el momento, mostrársela al dueño y después imprimirla.
- **El comercio** (dueño o encargado del local): no usa la app directamente. Recibe la etiqueta ya impresa y pegada; su única interacción es escanear o ver el QR como cliente final más adelante.

## Product Purpose

A partir de un número de WhatsApp, un usuario de Instagram o el Place ID de un comercio en Google Maps, la app arma una etiqueta lista para imprimir (QR real, ícono del tipo de contacto y un texto corto editable) en el tamaño exacto que necesita la impresora térmica Detonger DT01. Éxito = Maxi arma y exporta la etiqueta correcta en un par de minutos, parada en el comercio, sin errores en el QR ni en el tamaño de impresión.

## Positioning

No es un generador de QR genérico: arma directamente la etiqueta final (QR + ícono + texto) en el tamaño exacto de la DT01 (58 mm, 203 ppp, 464 px de ancho útil), lista para pasar a WePrint e imprimir, sin que Maxi tenga que medir, recortar ni componer nada aparte.

## Operating Context

- Maxi opera parada en el mostrador del comercio, con el dueño al lado, desde un iPhone y con conexión de datos variable. La app tiene que responder rápido y dejar claro en todo momento qué va a terminar impreso.
- El flujo completo: elegir tipo de QR → completar el dato (celular, usuario de Instagram o negocio de Google) → ver la etiqueta con el QR real → elegir variante de impresión (Adhesivo 464×464, Mostrador 464×640, Tarjetero 464×560) → editar el texto corto si hace falta → guardar la imagen o copiar el link → imprimir desde WePrint en la DT01.
- Google Reseñas admite buscar el negocio por ubicación o por nombre (API de Google Places vía un proxy propio), o pegar el Place ID a mano cuando la búsqueda automática no está disponible.
- Después de imprimir, Maxi pega el cartel en el comercio (puerta, mostrador, caja o tarjetero) y el flujo de la app termina ahí; no hay cuenta, historial ni backend de datos del comercio.

## Capabilities and Constraints

- Tipos de QR: WhatsApp, Instagram y Google Reseñas están implementados; Mercado Pago todavía muestra "Próximamente".
- La etiqueta impresa (tamaño exacto, contenido y disposición del QR, ícono y texto dentro del PNG renderizado para la DT01) es un contrato fijo para esta tarea de diseño: no cambia con este trabajo, sólo la interfaz que lleva hasta ahí.
- Sin gestor de estado global; widgets sin estado salvo estado local. Sin build específica para iOS todavía.
- Sin cuentas de usuario ni backend propio de datos: la única llamada a un servicio externo es el proxy de Google Places, y falla con gracia mostrando el flujo manual cuando no hay clave configurada.

## Brand Commitments

Sin identidad de marca propia definida todavía (sin logo ni paleta documentada antes de este trabajo); "Generador de QR" es el nombre funcional actual. No hay restricciones de marca heredadas que preservar.

## Evidence on Hand

- Guía de uso y decisiones técnicas documentadas en `docs/` (sitio Starlight) y en `AGENTS.md`.
- Capturas de los flujos actuales (antes de este trabajo) en `docs/issue-26/before/`.
- Sin testimonios, casos de uso de otros vendedores ni datos de uso real más allá de Maxi: no inventar otros usuarios o métricas.

## Product Principles

1. Lo que se ve en pantalla predice fielmente lo que va a salir impreso: WYSIWYG estricto sobre tamaño, QR y texto.
2. La herramienta es de Maxi, no del comercio: prioriza velocidad y confianza para ella por sobre explicarle el producto a un visitante nuevo.
3. Cada flujo (WhatsApp, Instagram, Google Reseñas) resuelve un dato distinto con el mínimo de pasos y errores posibles, parada en el local.
4. Confiabilidad ante fallas de red o de la API de Google: siempre hay un camino manual de respaldo (pegar el Place ID).

## Accessibility & Inclusion

Uso real a una mano, en un iPhone, parada en el mostrador de un comercio: botones y campos tienen que ser cómodos de tocar sin precisión de laboratorio, y el texto tiene que leerse con luz de local, no de escritorio.

---

**Nota de proceso (issue #26):** este archivo se escribió sin una entrevista en vivo (sesión autónoma, sin alguien respondiendo en tiempo real). Los hechos de producto están inferidos de `AGENTS.md`, `README.md` y `docs/` existentes, que ya documentaban a Maxi, los comercios, el flujo y la DT01 con bastante precisión; no se inventó ningún dato que no estuviera ya respaldado por el repo. Queda señalado acá en vez de en un PRODUCT.md "silencioso" para que quede claro que es una sustitución de la entrevista de `init`, no una confirmación de Eduardo.
