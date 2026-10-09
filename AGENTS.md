# AGENTS.md: qr-generator

Generador de QR para que Maxi venda cartelería a comercios de Argentina. Tipos de QR: reseñas de Google, Instagram, WhatsApp y transferencias de Mercado Pago. Maxi imprime con una térmica Detonger DT01 (58 mm, 203 ppp, 464 px de ancho útil) desde un iPhone, importando la imagen en la app WePrint.

## Stack
- Flutter (stable). El primer objetivo es web (PWA); iOS viene después.
- Flutter 3.47.6 (stable), fijado también en CI y Docker.
- Widgets sin estado para el scaffold; navegación con `Navigator` y `MaterialPageRoute`. Si aparece estado local, usá `StatefulWidget`; no hay gestor de estado global.

## Verificación obligatoria antes de abrir o actualizar un PR
- `flutter analyze` sin errores ni warnings
- `flutter test` en verde

## Convenciones
- Código e identificadores en inglés. Textos de la UI, commits y PRs en español rioplatense.
- La lógica pura (normalizar números, armar URLs) va en `lib/src/domain/`, con tests unitarios. Los widgets no llevan lógica de negocio.
- Ramas `agent/<issue>-<slug>`. Un PR por issue, con `Closes #<issue>` y una sección **Entregable visible**.

## Probar la UI (Playwright)
Para recorrer la app con las herramientas de Playwright, sírvela localmente dentro del contenedor:

```bash
flutter build web --release
python3 -m http.server 8765 --directory build/web >/dev/null 2>&1 &
```

Abre `http://localhost:8765`, espera unos 5 segundos a que cargue Flutter y recorre los flujos. Flujos principales que nunca deben romperse:
- **WhatsApp:** inicio → WhatsApp → ingresar el número → ver la etiqueta con el QR real → guardar o copiar.
- **Instagram:** inicio → Instagram → ingresar el usuario → ver la etiqueta con el QR real → guardar o copiar.

## Skills
- Las skills del proyecto viven en **`.agents/skills/`** (ruta genérica: Codex la lee directo). `.claude/skills` es un enlace simbólico a esa carpeta, para que Claude vea las mismas.
- **Diseño de UI:** usá `frontend-design` (dirección estética, tipografía, color) e `impeccable` (vocabulario y comandos de diseño: `init`, `critique`, `audit`, `typeset`, `polish`…).
  - Las dos están pensadas para web. En Flutter, aplicá sus criterios al `ThemeData`, los widgets y los tokens de diseño.
  - De `impeccable`, preferí las referencias `*.native.md` cuando existan. Su detector automático analiza HTML/CSS y puede no servir sobre una app Flutter: si no aplica, decilo en el PR.
  - Su contexto de diseño (`PRODUCT.md` y `DESIGN.md` en la raíz) es parte del entregable cuando se lo pida el issue.
- **No instales, actualices ni modifiques skills** (`.agents/skills/`, `.claude/`) desde un issue: las agregan Eduardo o Claude Code con un PR revisado.

## Prohibido
- Push directo a `main`, mergear PRs, o agregar secretos o claves de API al repo.

## Estructura
- `lib/main.dart`: punto de entrada.
- `lib/src/ui/`: aplicación, pantalla inicial y pantalla Próximamente.
- `lib/src/domain/`: reservado para lógica pura, independiente de Flutter.
- `test/`: tests; la navegación inicial está en `widget_test.dart`.
- `web/`: manifest PWA, página de arranque e íconos por defecto.
- `ios/`: proyecto nativo generado por Flutter (compilar en macOS con Xcode).

## Desarrollo y verificación
```sh
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
flutter build web --release
```
Para iOS, desde macOS con Xcode y un simulador o dispositivo configurado:
```sh
flutter devices
flutter run -d <id-del-dispositivo-ios>
```

## Contenedor de prueba
Con Docker y Docker Compose instalados y el daemon activo:
```sh
docker compose up --build
```
Abrí http://localhost:8080. WhatsApp, Instagram y Mercado Pago abren vistas previas
de impresión con datos de ejemplo. Google Reseñas genera el QR desde un Place ID
o enlace compatible (ver docs/google-resenas.md) y permite previsualizar la etiqueta
con ese enlace. Todas permiten volver al inicio. El build usa Flutter y la imagen final sirve los archivos con
nginx. La primera compilación necesita Internet para descargar SDK y dependencias.
Para detenerlo, usá Ctrl+C y `docker compose down`.
