# Documentación: sitio Starlight

Sitio de documentación del Generador de QR, armado con [Astro](https://astro.build)
y [Starlight](https://starlight.astro.build). Se publica en
<https://maxiar-org.github.io/qr-generator/> en cada push a `main` que toque
`docs/` (ver [`.github/workflows/docs.yml`](../.github/workflows/docs.yml)).

## Desarrollo

```sh
npm install
npm run dev      # servidor local en http://localhost:4321/qr-generator/
npm run build    # compila a docs/dist/
npm run preview  # sirve docs/dist/ para revisar el build de producción
```

## Estructura

- `src/content/docs/`: páginas del sitio en Markdown/MDX. El sidebar se
  autogenera a partir de las carpetas `guia-de-uso/`, `arquitectura/` y
  `decisiones/`.
- `astro.config.mjs`: configuración de Starlight (idioma, sidebar, `base` y
  `site` para GitHub Pages) y de [`astro-mermaid`](https://github.com/wizd/astro-mermaid)
  para los diagramas.
- Los archivos sueltos en `docs/` (`google-resenas.md`, `mercado-pago.md`,
  `impresion-directa.md`, `issue-17/`) son anteriores a este sitio y no forman
  parte del build de Astro: las páginas de **Decisiones** los resumen y
  enlazan directamente al archivo en el repositorio.
