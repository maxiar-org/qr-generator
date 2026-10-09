# Issue #26 — Diseño: mejorar la apariencia de la app

Evidencia del rediseño: contexto de diseño (`impeccable init`), diagnóstico
inicial (`impeccable critique`/`audit`), dirección visual (`frontend-design`)
y capturas antes/después con Playwright.

## Cómo reproducir las capturas

```sh
flutter build web --release
python3 -m http.server 8765 --directory build/web
```

Abrí `http://localhost:8765` y esperá ~5 segundos a que cargue Flutter. La
app renderiza sobre `<canvas>` (CanvasKit): para que Playwright pueda ubicar
botones y campos por su texto hace falta activar el árbol de semántica de
Flutter primero, haciendo click (o `dispatchEvent('click')`) sobre el
`<flt-semantics-placeholder>` invisible que agrega la app al cargar. Después
de eso, los textos y roles ARIA aparecen en el DOM y se puede navegar como
cualquier sitio. Recorrido: Inicio → WhatsApp (formulario → etiqueta) →
Instagram (formulario → etiqueta) → Google Reseñas (buscar cerca, buscar por
nombre, Place ID manual → QR → etiqueta), en desktop (1280×900) y celular
(390×844).

## Diagnóstico inicial

**Método:** pase manual en un solo contexto (sin sub-agentes aislados para
Assessment A/B como pide `critique.md` en su modo dual-agente), aplicando la
rúbrica de heurísticas de Nielsen de `reference/critique.md` y las categorías
de `reference/audit.md` sobre las capturas "antes" y el código fuente.
`⚠️ DEGRADED: single-context (sin tool de sub-agentes dedicada para A/B en
este flujo de issue)`, como indica el propio `critique.md` para este caso.

**Detector automático (`impeccable detect`):** no sirve sobre esta app.
Contra archivos `.dart` corre sin error pero no analiza nada (`[]`, exit 0:
no reconoce el formato, no es un no-op con hallazgos reales). Contra la URL
servida (`http://localhost:8765`) necesita lanzar un browser con sandbox, que
este contenedor no tiene habilitado; aun si lo tuviera, Flutter web con
CanvasKit pinta todo en un `<canvas>` sin HTML/CSS semántico real (ver más
abajo), así que un detector pensado para antipatrones de HTML/CSS no tendría
nada que inspeccionar. Confirma lo que ya advertía `AGENTS.md`.

### Salud del diseño (heurísticas de Nielsen, antes del cambio)

| # | Heurística | Score | Hallazgo clave |
|---|---|---|---|
| 1 | Visibilidad del estado del sistema | 3 | Hay `LinearProgressIndicator` al buscar negocios y mensajes de error, pero el `FutureBuilder` de la etiqueta sólo dice "Generando…" en texto plano, sin indicador visual |
| 2 | Lenguaje natural | 4 | Textos en español rioplatense, claros y directos |
| 3 | Control y libertad | 3 | Hay botón atrás en todas las pantallas; falta cancelar una búsqueda de negocio en curso |
| 4 | Consistencia | 2 | Los tres formularios (WhatsApp, Instagram, Google) repiten el mismo patrón a mano (`OutlineInputBorder`, `SizedBox(height: 16)`, `FilledButton`) sin un componente ni tema compartido: cualquier ajuste futuro hay que repetirlo tres veces |
| 5 | Prevención de errores | 3 | Validación clara de celular/usuario/Place ID antes de generar |
| 6 | Reconocimiento antes que recuerdo | 2 | Los cuatro tipos de QR en Inicio son indistinguibles entre sí salvo por el texto: mismo ícono (ninguno), mismo color, mismo peso visual. Maxi, parada con el dueño del comercio al lado, tiene que leer la lista entera cada vez |
| 7 | Flexibilidad y eficiencia | n/a | No aplica: es una herramienta de un solo flujo por pantalla, sin atajos de power user relevantes para el caso de uso |
| 8 | Diseño estético y minimalista | 1 | Paleta `ColorScheme.fromSeed(seedColor: Colors.teal)` literal (el ejemplo de la documentación de Flutter) y tipografía del sistema sin escala propia: cero decisiones de diseño tomadas, se nota como demo generada |
| 9 | Ayuda a reconocer y recuperarse de errores | 2 | Los errores de formulario se ven bien (`errorText` bajo el campo), pero "No pudimos obtener tu ubicación…" se muestra como texto plano del mismo peso que cualquier otro párrafo, sin color ni ícono de alerta |
| 10 | Ayuda y documentación | 3 | Hay guía de WePrint dentro de la app y guía completa en `docs/`, aunque no linkeada desde la pantalla de Google Reseñas salvo el texto de Place ID Finder |

**Total: 23/32** (dos heurísticas no aplican) → **Aceptable**: mejoras
significativas necesarias antes de que la herramienta transmita la confianza
profesional que Maxi necesita frente a un comercio.

### Veredicto de especificidad de diseño

El resultado actual es genérico al punto de ser intercambiable con cualquier
demo "Hello Flutter": `ColorScheme.fromSeed(seedColor: Colors.teal)` es,
literalmente, el valor que usa la plantilla por defecto de Flutter. No hay una
sola decisión tipográfica, de paleta o de espaciado tomada para esta app en
particular. Nada en pantalla comunica "cartelería profesional para
comercios" ni ayuda a Maxi a diferenciar de un vistazo si está en el flujo de
WhatsApp, Instagram o Google.

### Qué funciona bien

- La jerarquía de información dentro de cada formulario (instrucción → campo
  → acción) es simple y directa, sin pasos de más.
- Los mensajes de error de validación (celular, usuario de Instagram, Place
  ID) son específicos y en el idioma del usuario, no códigos técnicos.
- El WYSIWYG de la vista previa de impresión (lo que se ve es exactamente lo
  que se exporta) ya está resuelto a nivel funcional; el trabajo de diseño no
  necesita tocar esa lógica, sólo el marco alrededor.

### Problemas prioritarios

- **[P1] Sin paleta ni tipografía propias** — *Por qué importa:* la app se ve
  como una demo sin terminar, lo que no transmite la confianza profesional
  que Maxi necesita al mostrársela a un comercio. *Arreglo:* definir paleta,
  tipografía y escala con `frontend-design`, aplicados al `ThemeData`.
  *Comando sugerido:* `$impeccable typeset` + `$impeccable colorize`.
- **[P1] Estilos de formulario repetidos a mano en cada pantalla** —
  *Por qué importa:* viola heurística de consistencia y encarece cualquier
  cambio futuro (hay que tocar WhatsApp, Instagram y Google Reseñas por
  separado). *Arreglo:* mover el estilo a `ThemeData`
  (`InputDecorationTheme`, `FilledButtonTheme`) y widgets compartidos.
  *Comando sugerido:* `$impeccable extract`.
- **[P2] Los cuatro tipos de QR son visualmente idénticos en Inicio** —
  *Por qué importa:* Maxi tiene que leer el texto completo de cada fila cada
  vez que arma una etiqueta; un ícono o acento de color por tipo bajaría la
  carga cognitiva y aceleraría el flujo parada en el mostrador. *Arreglo:*
  ícono/acento de color por tipo de QR en la lista de Inicio. *Comando
  sugerido:* `$impeccable layout`.
- **[P2] Mensajes de error y estados de carga sin jerarquía visual** — *Por
  qué importa:* "No pudimos obtener tu ubicación…" tiene el mismo peso que
  cualquier párrafo informativo, así que es fácil pasarlo por alto.
  *Arreglo:* color/ícono de advertencia consistentes para mensajes de error
  fuera de los campos de formulario. *Comando sugerido:* `$impeccable
  clarify`.
- **[P3] El formulario de Google Reseñas es denso** — *Por qué importa:* la
  búsqueda automática, el campo manual y el texto de ayuda compiten con el
  mismo peso visual; no es bloqueante pero pide más orden. *Arreglo:*
  agrupar visualmente "buscar negocio" vs. "pegar Place ID" como dos
  caminos alternativos, no una lista plana. *Comando sugerido:* `$impeccable
  layout`.

### Red flags por persona

**Casey (usuaria de celular, apurada):** en mobile (390×844) los botones
`FilledButton` ya cumplen el mínimo de 48dp de alto, así que el toque
funciona; pero la paleta sin contraste deliberado entre superficie y fondo
(ambos verdosos muy claros) hace que, con el celular al sol en la vereda de
un comercio, cueste distinguir dónde termina una tarjeta y empieza el fondo.

**Sam (depende de buen contraste):** el texto principal tiene buen contraste
sobre el fondo, pero el texto secundario ("Encontrá tu negocio" subtítulo,
ayuda de Place ID) usa el gris por defecto de Material, más cerca del límite
de AA que del texto principal — ver sección de accesibilidad más abajo para
los valores concretos ya corregidos.

## Dirección visual aplicada

Contexto completo en [`PRODUCT.md`](../../PRODUCT.md) y [`DESIGN.md`](../../DESIGN.md)
(raíz del repo). Resumen: paleta propia (Sello `#0F4C5C` + acento Marigold
`#E2A33B`, siempre con texto tinta encima, nunca blanco), tipografía IBM Plex
Sans con una escala de 5 roles, esquinas 12px en vez de píldoras, y
profundidad por borde de 1px en vez de sombra. Todo vive en
`lib/src/ui/theme/app_theme.dart` (`ThemeData`, `AppColors`, `AppSpacing`,
`AppRadius`) y en el widget compartido `lib/src/ui/widgets/app_screen.dart`;
ninguna pantalla declara un color o tamaño de fuente suelto.

## Qué aportó cada skill

**`impeccable`:**
- `init` (adaptado): escribió `PRODUCT.md` sin entrevista en vivo (sesión
  autónoma) infiriendo de `AGENTS.md`/`README.md`/`docs/` ya existentes;
  queda señalado en el propio archivo como sustitución documentada de la
  entrevista.
- `critique`/`audit` (pase manual en un solo contexto, sin los dos
  sub-agentes aislados que pide el flujo dual del comando): heurísticas de
  Nielsen sobre las capturas "antes" — **23/32, Aceptable**. El hallazgo más
  accionable fue la falta total de paleta/tipografía propia
  (`ColorScheme.fromSeed(seedColor: Colors.teal)` literal) y la repetición de
  estilos de formulario pantalla por pantalla; ambos quedaron resueltos al
  mover todo a `ThemeData` + `AppScreen`. Detalle completo arriba, en
  "Diagnóstico inicial".
- **Detector automático (`impeccable detect`):** no sirve sobre esta app.
  Confirmado con dos pruebas: contra archivos `.dart` corre sin error pero no
  analiza nada (no reconoce el formato); contra la URL servida necesita un
  browser con sandbox que este contenedor no habilita, y aunque lo tuviera,
  Flutter web con CanvasKit pinta todo en un `<canvas>` sin HTML/CSS
  semántico, así que no habría nada que un detector de antipatrones de
  HTML/CSS pudiera inspeccionar.
- `document` (adaptado): el `DESIGN.md` final no se generó escaneando un
  sistema incumbente (no había ninguno coherente, sólo defaults de Material),
  así que se escribió directamente con los tokens recién decididos con
  `frontend-design`, siguiendo el formato canónico de 8 secciones de
  `document.md` (frontmatter de tokens + Overview/Colors/Typography/Layout/
  Elevation & Depth/Shapes/Components/Do's and Don'ts).

**`frontend-design`:** aportó las decisiones de fondo detrás de los tokens,
no sólo la lista de colores:
- Rechazar los dos defaults más obvios para una app Flutter: el teal de
  `ColorScheme.fromSeed` y el terracota/`#D97757` que la skill marca
  explícitamente como una "tell" de diseño generado por IA.
- Partir del contexto real del producto (una app que arma literalmente una
  etiqueta de papel para pegar en un comercio) para justificar el fondo
  "papel" tibio en vez de un gris de dashboard genérico.
- La regla de un acento único (Marigold) usado con moderación y siempre con
  texto tinta encima — motivada por el propio chequeo de contraste (blanco
  sobre Marigold da 3.8:1, no llega a AA).
- Esquinas moderadas (12px) en vez de las píldoras por defecto de
  `FilledButton`, y profundidad por borde fino en vez de la sombra blanda
  pareja de "SaaS card kit" que la skill señala como otro cliché recurrente.
- Reusar el ícono de cada tipo de QR (`label_icons.dart`, ya usado en la
  etiqueta impresa) como chip de color en Inicio: no es decoración, es la
  misma información que después va a imprimirse, aplicada como estructura.

## Capturas "antes"

![Inicio](before/d01-inicio.png)
![WhatsApp, formulario vacío](before/d02-whatsapp-vacio.png)
![WhatsApp, formulario completo](before/d03-whatsapp-completo.png)
![WhatsApp, etiqueta](before/d04-whatsapp-etiqueta.png)
![Instagram, formulario vacío](before/d05-instagram-vacio.png)
![Instagram, formulario completo](before/d06-instagram-completo.png)
![Instagram, etiqueta](before/d07-instagram-etiqueta.png)
![Google Reseñas, formulario](before/d08-google-form.png)
![Google Reseñas, buscar cerca (sin ubicación)](before/d09-google-buscar-cerca.png)
![Google Reseñas, buscar por nombre (sin proxy)](before/d10-google-buscar-nombre.png)
![Google Reseñas, QR generado](before/d11-google-qr.png)
![Google Reseñas, etiqueta](before/d12-google-etiqueta.png)
![Inicio en celular](before/m01-inicio.png)
![WhatsApp en celular, etiqueta](before/m03-whatsapp-etiqueta.png)
![Google Reseñas en celular, formulario](before/m04-google-form.png)

## Capturas "después"

![Inicio](after/d01-inicio.png)
![WhatsApp, formulario vacío](after/d02-whatsapp-vacio.png)
![WhatsApp, formulario completo](after/d03-whatsapp-completo.png)
![WhatsApp, etiqueta](after/d04-whatsapp-etiqueta.png)
![Instagram, formulario vacío](after/d05-instagram-vacio.png)
![Instagram, formulario completo](after/d06-instagram-completo.png)
![Instagram, etiqueta](after/d07-instagram-etiqueta.png)
![Google Reseñas, formulario](after/d08-google-form.png)
![Google Reseñas, buscar cerca (sin ubicación)](after/d09-google-buscar-cerca.png)
![Google Reseñas, buscar por nombre (sin proxy)](after/d10-google-buscar-nombre.png)
![Google Reseñas, QR generado](after/d11-google-qr.png)
![Google Reseñas, etiqueta](after/d12-google-etiqueta.png)
![Inicio en celular](after/m01-inicio.png)
![WhatsApp en celular, etiqueta](after/m03-whatsapp-etiqueta.png)
![Google Reseñas en celular, formulario](after/m04-google-form.png)

La etiqueta impresa (QR, tamaño y contenido del PNG que arma
`label_image_renderer.dart`) no cambió: comparar `d04`/`d12` y sus
equivalentes en `before/` contra `after/` a nivel de la imagen del cartel en
sí. El código de `lib/src/printing/`, `lib/src/domain/`, `lib/src/export/` y
`lib/src/places/` no tiene diffs en este cambio (sólo se tocó `lib/src/ui/`).
