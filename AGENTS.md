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
Abrí http://localhost:8080. Instagram genera un QR al perfil ingresado y WhatsApp, un QR
con un celular argentino y un mensaje opcional. Google Reseñas y Mercado Pago
llevan a Próximamente. Todas permiten volver al inicio. El build usa Flutter y la imagen final sirve los archivos con
nginx. La primera compilación necesita Internet para descargar SDK y dependencias.
Para detenerlo, usá Ctrl+C y `docker compose down`.
