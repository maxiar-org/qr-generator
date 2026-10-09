---
name: Generador de QR
description: Cartelería con códigos QR para comercios argentinos, armada para imprimir en una térmica de 58 mm.
colors:
  primary: "#0F4C5C"
  primary-deep: "#0B3844"
  accent: "#E2A33B"
  paper: "#F7F6F2"
  surface: "#FFFFFF"
  ink: "#1B2430"
  ink-muted: "#4B5563"
  border: "#D8DEDC"
  error: "#B3261E"
typography:
  display:
    fontFamily: "IBM Plex Sans"
    fontSize: "22px"
    fontWeight: 600
    lineHeight: 1.2
  headline:
    fontFamily: "IBM Plex Sans"
    fontSize: "20px"
    fontWeight: 600
    lineHeight: 1.25
  title:
    fontFamily: "IBM Plex Sans"
    fontSize: "17px"
    fontWeight: 600
    lineHeight: 1.3
  body:
    fontFamily: "IBM Plex Sans"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "IBM Plex Sans"
    fontSize: "15px"
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: "0.1px"
rounded:
  sm: "8px"
  md: "12px"
  lg: "16px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
  xxl: "48px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "#FFFFFF"
    rounded: "{rounded.md}"
    padding: "16px 24px"
  button-primary-pressed:
    backgroundColor: "{colors.primary-deep}"
  card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.md}"
    padding: "16px"
  input:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.md}"
---

# Design System: Generador de QR

## Overview

**Creative North Star: "La etiqueta misma, antes de imprimirse"**

La app arma algo físico: una etiqueta de papel que termina pegada en la
puerta o el mostrador de un comercio real. La pantalla adopta ese carácter en
vez de pedirle prestado el suyo a un dashboard genérico: fondo color papel
tibio, tarjetas blancas que se leen como recortes sobre ese papel, tipografía
humanista de alta legibilidad a tamaño chico (la misma exigencia que tiene
leer un cartel al sol), y un solo acento cálido (marigold) reservado para lo
que ayuda a Maxi a diferenciar un tipo de QR de otro de un vistazo. Nada de
`ColorScheme.fromSeed(seedColor: Colors.teal)` ni de componentes Material sin
tocar: cada color, radio y peso tipográfico está elegido para esta
herramienta.

Es una superficie de **Operate** (Maxi completa una tarea, parada en el
local), no de Persuade: la escaneabilidad y la consistencia importan más que
la expresión. La marca vive en los detalles precisos — el acento marigold en
los chips de tipo de QR, el "papel" de fondo — no en gestos grandes.

Rechazos visuales confirmados contra esta app: sin el teal de `Colors.teal`
por defecto de Flutter; sin tarjetas con sombra blanda idéntica en todos
lados (cliché de "SaaS card kit"); sin botones estilo píldora/stadium
(leían más a app de consumo que a herramienta profesional).

**Key Characteristics:**
- Fondo "papel" tibio, tarjetas blancas planas con borde fino en vez de sombra.
- Un acento marigold, usado con moderación y siempre con texto tinta encima (nunca blanco encima del acento: falla contraste).
- Una sola familia tipográfica (IBM Plex Sans) con una escala deliberada de 5 roles.
- Esquinas redondeadas moderadas (12px) en vez de píldoras, para leer "herramienta confiable" en vez de "app de consumo".

## Colors

Paleta de pocos colores con roles claros: un azul-verdoso profundo como
color de marca y acción, un marigold cálido como único acento funcional, y
neutros cálidos (no grises fríos) para fondo y texto.

### Primary
- **Sello** (`#0F4C5C`): color de marca y de toda acción primaria (`FilledButton`, segmento seleccionado, ícono de resultado de búsqueda). Deliberadamente un azul-verdoso oscuro y desaturado — transmite confianza/profesionalismo sin caer en el teal brillante por defecto de Material.
- **Sello Profundo** (`#0B3844`): estado presionado/hover del primario.

### Secondary
- **Marigold** (`#E2A33B`): único acento cálido. Se usa nada más en los chips de tipo de QR en Inicio y en indicadores de selección puntuales. **The One Accent Rule.** El marigold nunca lleva texto blanco encima (3.8:1 de contraste, no alcanza AA): siempre texto tinta (`#1B2430`) sobre marigold, nunca al revés.

### Neutral
- **Papel** (`#F7F6F2`): fondo de toda la app. Evoca el papel de la etiqueta que se va a imprimir, no un gris de dashboard.
- **Superficie** (`#FFFFFF`): tarjetas, campos de formulario y la vista previa de la etiqueta, siempre como "recortes" sobre el papel.
- **Tinta** (`#1B2430`): texto principal. Azul-negro cálido, no negro puro.
- **Tinta Media** (`#4B5563`): texto secundario/ayuda (6.99:1 sobre papel, AA de sobra).
- **Borde** (`#D8DEDC`): línea fina de 1px que separa tarjetas y campos del papel, en vez de sombra.
- **Error** (`#B3261E`): validación de formulario y mensajes de error fuera de campo (6.04:1 sobre papel).

### Named Rules
**The Paper Rule.** El fondo siempre lee como el papel de la etiqueta; las tarjetas y campos son blancos y están "sobre" ese papel, nunca al revés.

## Typography

**Display/Body/Label Font:** IBM Plex Sans (variable, pesos 400/500/600/700), con `Roboto` y la pila sans-serif del sistema como fallback.

**Character:** una sans humanista pensada para paneles de instrumentos y fintech: muy legible a tamaño chico, con personalidad suficiente para no leerse como el Roboto por defecto, sin la frialdad de una grotesca geométrica. Una sola familia para todo — nunca hace falta una segunda.

### Hierarchy
- **Display** (600, 22px, 1.2): títulos de `AppBar` ("WhatsApp", "Google Reseñas").
- **Headline** (600, 20px, 1.25): encabezados de sección dentro de una pantalla ("Encontrá tu negocio").
- **Title** (600, 17px, 1.3): títulos de fila en listas y tarjetas (tipos de QR en Inicio).
- **Body** (400, 16px, 1.5): texto de instrucciones, ayuda y contenido de formularios.
- **Label** (600, 15px, 1.3, +0.1px): texto de botones y labels de campos de formulario.

### Named Rules
**The One Family Rule.** Una sola tipografía para toda la app; la jerarquía se construye con peso y tamaño, nunca mezclando familias.

## Layout

Columna central de ancho máximo 600px (ya existente), con la grilla de
espaciado de 4px de la cabecera (`xs` 4 · `sm` 8 · `md` 16 · `lg` 24 · `xl`
32 · `xxl` 48). Separación entre bloques relacionados: `md` (16px); entre
secciones distintas de una misma pantalla (ej. "buscar negocio" vs. "pegar
Place ID a mano"): `lg`/`xl` con un `Divider` sutil, para que se lean como
caminos alternativos y no como una lista plana. En celular, el mismo ritmo
de espaciado se mantiene; no hay un layout de escritorio distinto, sólo más
aire alrededor en pantallas anchas.

## Elevation & Depth

**The Flat-by-Default Rule.** Sin sombras en ningún estado de reposo. La
profundidad se transmite con el contraste papel/superficie y un borde fino
de 1px (`#D8DEDC`) alrededor de tarjetas y campos, nunca con
`box-shadow`/`elevation` de Material. Encaja con el modo Operate: la app es
una herramienta, no una vidriera.

## Shapes

Esquinas redondeadas moderadas y consistentes: 12px (`rounded.md`) en
tarjetas, campos y botones; 8px (`rounded.sm`) en chips e indicadores
chicos. Nunca full-pill/stadium (el `FilledButton` de Material por defecto):
leía a app de consumo, no a herramienta profesional. Sin bordes
decorativos; el único borde es el hairline de 1px que ya separa superficies
en vez de usar sombra.

## Components

### Buttons
- **Shape:** rectángulo redondeado, 12px de radio.
- **Primary (`FilledButton`):** fondo Sello (`#0F4C5C`), texto blanco, alto mínimo 48dp, padding horizontal 24px. Es la única acción primaria visible por pantalla.
- **Pressed:** fondo Sello Profundo (`#0B3844`).
- **Secondary (`OutlinedButton`):** borde Tinta Media 1px, texto Sello, mismo radio y alto que el primario.
- **Texto solo (`TextButton`):** texto Sello, sin fondo; para acciones de apoyo ("Cómo imprimir con WePrint").

### Chips (tipo de QR en Inicio)
- **Style:** círculo de 40dp con el ícono del tipo de QR en tinta blanca, fondo con el tono de marca de cada canal (WhatsApp, Instagram, Google, Mercado Pago) en una versión atenuada — información funcional para que Maxi identifique la fila de un vistazo, no decoración.
- **State:** Mercado Pago (todavía "Próximamente") usa una versión desaturada del chip para marcar que no está disponible.

### Cards / Containers
- **Corner Style:** 12px.
- **Background:** Superficie (`#FFFFFF`) sobre Papel (`#F7F6F2`).
- **Shadow Strategy:** ninguna; ver Elevation & Depth.
- **Border:** 1px Borde (`#D8DEDC`).
- **Internal Padding:** `md` (16px).

### Inputs / Fields
- **Style:** fondo Superficie, borde 1px Tinta Media en reposo, radio 12px, label en estilo Label arriba del campo (no flotante encima del texto).
- **Focus:** borde 2px Sello.
- **Error:** borde y texto de ayuda en color Error, ícono de alerta antes del mensaje cuando el error no cuelga de un campo (ej. "No pudimos obtener tu ubicación…").

### Navigation
- **AppBar:** fondo Papel (no un color de marca sólido, para no competir con el contenido), título en estilo Display, flecha "Atrás" en Tinta.

## Do's and Don'ts

### Do:
- **Do** usar Sello sólo para la acción primaria de cada pantalla; si hay una acción secundaria, que sea `OutlinedButton` o `TextButton`, nunca un segundo `FilledButton` compitiendo.
- **Do** mantener el acento Marigold minoritario y funcional (chips de tipo de QR, selección puntual), nunca como color de fondo grande.
- **Do** usar siempre texto Tinta sobre Marigold, nunca blanco.
- **Do** conservar el layout, tamaño y contenido exacto del PNG que arma `label_image_renderer.dart`: ese archivo es el contrato de impresión de la DT01 y no se toca en trabajo de diseño de interfaz.

### Don't:
- **Don't** usar sombras (`elevation`/`boxShadow`) en tarjetas, campos o botones en reposo.
- **Don't** usar bordes full-pill/stadium en botones.
- **Don't** introducir una segunda familia tipográfica.
- **Don't** repetir estilos de formulario a mano por pantalla: todo pasa por `ThemeData` y los widgets compartidos.
