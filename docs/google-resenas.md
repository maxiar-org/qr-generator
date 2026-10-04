# QR de Google Reseñas

## Decisión

Usamos **Place ID Finder de Google de forma manual**, sin clave propia, backend ni cobros de API en esta app. Maxi confirma nombre y dirección en Finder y pega el ID. También aceptamos una URL HTTPS de `google.com/maps` o `www.google.com/maps` que incluya `query_place_id`, y el enlace de reseña `https://search.google.com/local/writereview?placeid=...`.

Esto no es una conversión automática de cualquier link de Maps. No encontramos una interfaz documentada sin credenciales que convierta todos los links cortos a Place ID. El paso manual permite implementar una alternativa confiable dentro del alcance sin contratar servicios.

## Comparación

| Lo que tiene Maxi / método | Cómo obtiene el ID | Clave y costo | Limitaciones / decisión |
| --- | --- | --- | --- |
| Link `maps.app.goo.gl/...`: resolver redirecciones | Abrirlo en Maps y tomar nombre y dirección; después buscar en Finder | Abrir el link no usa una clave de esta app | Expandirlo no asegura que la URL contenga un Place ID. Desde una PWA, leer redirecciones de otro origen depende de CORS. No implementamos un proxy ni scraping. |
| URL completa de Maps con `query_place_id` | Leer ese parámetro explícito | Sin clave, sin llamadas de API | Implementado para los hosts y rutas indicados arriba. URLs documentadas por Google [2]. |
| URL completa con `cid`, coordenadas o `data=...` | Usar el negocio visible como referencia para Finder | Manual, sin clave propia | CID e identificadores hexadecimales no son Place IDs. No inferimos conversiones de parámetros internos. |
| Nombre y dirección: Place ID Finder | Buscar, elegir el comercio correcto y copiar el ID | Herramienta pública alojada por Google; no requiere configurar nuestra clave | Elegido. El widget público depende de disponibilidad de Google. Embeber nuestra propia copia del mapa sería otra integración. [1] |
| Nombre: Places API (New), Text Search | Consultar por nombre y ubicación y obtener `places.id` | Requiere proyecto, facturación y credenciales. IDs Only tiene uso gratuito ilimitado; pedir otros campos puede cambiar el SKU | Automatizable, pero introduce configuración y riesgo de cargos. No implementado. [3][4] |
| Dueño con acceso al Perfil de Empresa | Pedirle su enlace o QR oficial para solicitar reseñas | Sin clave de API de esta app | Alternativa operativa: puede usar directamente ese QR; no necesariamente expone el Place ID. Links cortos del perfil no se importan en esta versión. [5] |
| Extractores de terceros / scraping de Maps | Parsear HTML, tokens internos o usar un proveedor | Variable; puede requerir pago o credenciales | Sin contrato estable de conversión verificado; no elegidos. |

### Costos de Places API

Consulta de precios globales: **4 de octubre de 2026**, USD, por 1.000 eventos, primer tramo pago hasta 100.000 eventos mensuales [3]:

- Text Search Essentials (IDs Only): sin cargo, cupo gratuito ilimitado.
- Text Search Pro: 5.000 eventos gratis al mes; luego USD 32 / 1.000.
- Place Details Essentials (IDs Only): sin cargo, cupo gratuito ilimitado.
- Place Details Essentials: 10.000 gratis al mes; luego USD 5 / 1.000.
- Place Details Pro: 5.000 gratis al mes; luego USD 17 / 1.000.

El precio depende de los campos solicitados, el volumen y el SKU. “IDs Only gratis” no significa “sin credenciales ni cuenta de facturación”. Revisar tarifas y restricciones antes de una futura integración [3][4].

## Cómo lo usa Maxi

1. Si tenés un link corto o una URL sin ID explícito, abrilo en Maps y anotá el nombre y la dirección de la sucursal.
2. Abrí [Place ID Finder de Google][1], buscá ese nombre y dirección y seleccioná el comercio. Confirmá que sea la sucursal correcta. Copiá el Place ID mostrado, no el CID ni la URL del navegador.
3. En la app, entrá en **Google Reseñas**, pegá el ID y tocá **Generar QR**. Si ya tenés una URL compatible, podés pegarla directamente.
4. Escaneá el QR desde otro dispositivo. Debe abrir la reseña del comercio elegido; Google puede pedir iniciar sesión. Verificá el nombre antes de imprimir. No hace falta publicar una reseña para probar.

El QR contiene `https://search.google.com/local/writereview?placeid=<PLACE_ID>` (formato solicitado en el issue). El procesamiento es local y no se guarda una lista de negocios.

## Validación y límites

- Prueba local: `flutter pub get`, `flutter run -d chrome`; alternativamente `docker compose up --build` y http://localhost:8080.
- Tests: `flutter test test/domain/google_reviews_test.dart` y `flutter test test/widget_test.dart`. Cubren construcción, espacios externos, IDs de distintos prefijos, URLs compatibles, entradas inválidas, hosts ajenos, parámetros duplicados, navegación y limpieza del QR al editar.
- La validación es sintáctica: no confirma existencia, identidad ni disponibilidad de reseñas. No exige el prefijo `ChIJ` ni longitud fija. Un texto alfanumérico puede pasar como ID: copiá siempre el valor de Finder.
- Google puede cambiar IDs; volver a verificar antes de reimprimir cartelería antigua [1]. Un negocio cerrado o sin reseñas habilitadas puede no abrir el formulario esperado.
- La apertura real en iPhone, el inicio de sesión y la impresión con WePrint requieren prueba manual; los tests automatizados no los verifican.

## Fuentes oficiales

[1]: https://developers.google.com/maps/documentation/places/web-service/place-id
[2]: https://developers.google.com/maps/documentation/urls/get-started
[3]: https://developers.google.com/maps/billing-and-pricing/pricing
[4]: https://developers.google.com/maps/documentation/places/web-service/get-api-key
[5]: https://support.google.com/business/answer/16816815

- [Place IDs y Finder][1]
- [Maps URLs][2]
- [Tarifas globales][3]
- [Configuración de Places API][4]
- [Reseñas en el Perfil de Empresa][5]
