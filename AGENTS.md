# AGENTS.md: qr-generator

Generador de QR para que Maxi venda cartelería a comercios de Argentina. Tipos de QR: reseñas de Google, Instagram, WhatsApp y transferencias de Mercado Pago. Maxi imprime con una térmica Detonger DT01 (58 mm, 203 ppp, 464 px de ancho útil) desde un iPhone, importando la imagen en la app WePrint.

## Stack
- Flutter (stable). El primer objetivo es web (PWA); iOS viene después.
- La estructura de carpetas y la gestión de estado las define el issue de scaffold. Una vez definidas, respétalas.

## Verificación obligatoria antes de abrir o actualizar un PR
- `flutter analyze` sin errores ni warnings
- `flutter test` en verde

## Convenciones
- Código e identificadores en inglés. Textos de la UI, commits y PRs en español rioplatense.
- La lógica pura (normalizar números, armar URLs) va en `lib/src/domain/`, con tests unitarios. Los widgets no llevan lógica de negocio.
- Ramas `agent/<issue>-<slug>`. Un PR por issue, con `Closes #<issue>` y una sección **Entregable visible**.

## Prohibido
- Push directo a `main`, mergear PRs, o agregar secretos o claves de API al repo.
