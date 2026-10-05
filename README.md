# Generador de QR

App Flutter para cartelería de comercios de Argentina. Google Reseñas genera un QR
desde un Place ID o enlace compatible y permite abrir su vista previa de
impresión para la térmica DT01, con selector de variante y texto editable.
WhatsApp, Instagram y Mercado Pago abren vistas previas con datos de ejemplo.

## Probar con Docker

```sh
docker compose up --build
```

Abrí http://localhost:8080. Para detenerlo: Ctrl+C y `docker compose down`.
Necesitás Docker con el daemon activo, Compose e Internet para el primer build.

## Desarrollo

Con Flutter 3.47.6 stable:

```sh
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
```

Las plataformas generadas son web e iOS. Encontrás la estructura y las
instrucciones para iOS en [AGENTS.md](AGENTS.md).

## Normalización de celulares de WhatsApp y perfiles de Instagram

`lib/src/domain/whatsapp.dart` normaliza celulares argentinos y arma el enlace
`wa.me`; `lib/src/domain/instagram_profile.dart` valida nombres de usuario o
enlaces de perfil de Instagram y arma la URL canónica. Ninguno de los dos está
conectado todavía a la vista previa de impresión (que usa un dato de ejemplo
para cada tipo de QR).

La normalización de WhatsApp acepta 10 dígitos nacionales, opcionalmente
precedidos por `0`, o el formato internacional `+549` / `549` seguido de esos
10 dígitos. Para el formato doméstico con `15`, quita el `0` inicial y busca
`15` después de 2, 3 o 4 dígitos de área, sólo si quedan 12 dígitos antes de
quitarlo. Debe haber una única separación posible; si hay más de una, ingresá
el número sin `0` ni `15`. Un `15` dentro de un número que ya tiene 10 dígitos
se conserva. Se permiten espacios, guiones y paréntesis. El número nacional
debe comenzar con 1, 2 o 3.

Se valida la estructura: no se consulta un padrón de áreas, ni se comprueba que
el número esté asignado, sea móvil o tenga WhatsApp. Los números ingresados sin
prefijo móvil se interpretan como celulares argentinos; los fijos y otros
países quedan fuera de alcance. El formato internacional requiere
explícitamente `549`.

La normalización de Instagram acepta de 1 a 30 letras ASCII, números, puntos o
guiones bajos, ya sea como `@usuario`, `usuario` o un enlace a
`instagram.com/usuario` (con o sin `www.`, esquema o parámetros de consulta).
No se verifica que el perfil exista.

## Probar el QR de Google Reseñas

1. Entrá en **Google Reseñas** y pegá el Place ID del comercio obtenido en
   Place ID Finder, o una URL de Maps con `query_place_id`.
2. Tocá **Generar QR** y verificá el negocio escaneándolo.
3. Tocá **Vista previa de impresión** para elegir variante y editar el texto:
   la etiqueta usa el enlace generado para ese comercio.
4. Volvé al formulario y editá el dato: el resultado anterior se borra.

Los links cortos y las URLs sin ID explícito requieren buscar el comercio
manualmente en Finder, sin configurar una clave propia.
Consultá [la comparación de opciones y los pasos de prueba](docs/google-resenas.md).
