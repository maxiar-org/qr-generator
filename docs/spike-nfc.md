# Spike: grabar etiquetas NFC desde la app (iPhone)

Investigación del issue #35, 29 de octubre de 2026. Consulta de fuentes
oficiales (`developer.apple.com`, `developer.chrome.com`, `developer.mozilla.org`,
`pub.dev`) y del datasheet de NXP para los tags.

## Conclusión

**Técnicamente viable, con un costo que le corresponde decidir a Eduardo.**
Grabar NDEF desde Safari/PWA no existe: hace falta Core NFC, una API nativa
de iOS. El paquete de Flutter `nfc_manager` (+ `nfc_manager_ndef`) lo expone
sin SDK propietario de terceros, a diferencia del spike de impresión directa
(#8). Pero la *capability* "Near Field Communication Tag Reading" de Xcode
**no está disponible con una cuenta gratuita (Personal Team)**: Apple la
restringe a cuentas pagas del Apple Developer Program (U$S 99/año) o
Enterprise. No hay forma de probarla ni siquiera por USB sin esa cuenta.

Mientras tanto, Chrome en Android ya tiene Web NFC sin costear nada: este PR
suma el botón "Grabar NFC" en la web, visible solo ahí, más un prototipo
nativo de iOS separado (apagado por defecto) para cuando Eduardo decida si
paga la cuenta.

## 1. Camino técnico en iOS: Core NFC

Apple expone la escritura de tags NDEF mediante `NFCNDEFReaderSession` /
`NFCNDEFTag.writeNDEF(_:completionHandler:)`. El flujo documentado es:
iniciar la sesión, confirmar con `queryNDEFStatus` que el tag admite
`readWrite`, armar un `NFCNDEFMessage` y llamar `writeNDEF`.

- **Versión mínima de iOS:** la clase de sesión existe desde iOS 11, pero el
  método que efectivamente escribe, `writeNDEF`, está disponible recién
  desde **iOS 13** — coincide con el anuncio de "Core NFC Enhancements" en
  WWDC 2019 ([sesión 715](https://developer.apple.com/videos/play/wwdc2019/715/)).
  Fuente: [`NFCNDEFTag.writeNDEF(_:completionHandler:)`](https://developer.apple.com/documentation/corenfc/nfcndeftag/writendef(_:completionhandler:)).
- **Modelos de iPhone:** Apple no publica una lista oficial; la documentación
  delega la verificación al chequeo en tiempo de ejecución de
  `NFCNDEFReaderSession.readingAvailable`
  ([framework overview](https://developer.apple.com/documentation/corenfc)).
  Prensa especializada ubica el soporte físico desde el iPhone 7 (iOS 11 en
  adelante para lectura), pero eso no está confirmado en una fuente oficial
  de Apple — no lo tomamos como dato duro.
- **Entitlement:** `com.apple.developer.nfc.readersession.formats`, con
  valor `NDEF` para este caso. Se agrega automáticamente al activar la
  capability "Near Field Communication Tag Reading" en Xcode (Signing &
  Capabilities); no hace falta (ni corresponde) escribirlo a mano. Fuente:
  [entitlement oficial](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.nfc.readersession.formats).
  No hay un entitlement distinto para lectura vs. escritura: un ingeniero de
  Apple lo confirma en el [foro de desarrolladores](https://developer.apple.com/forums/thread/793377):
  *"There is no whitelisting or other kinds of permissions or entitlements
  required to simply read and write to a writeable tag."*
- **Info.plist:** `NFCReaderUsageDescription` es obligatoria desde iOS 11
  ([referencia oficial](https://developer.apple.com/documentation/bundleresources/information-property-list/nfcreaderusagedescription)).
  No encontramos en documentación oficial la frase exacta de qué pasa si
  falta; por analogía con otras claves de privacidad de iOS, se espera que
  la app no pueda acceder al hardware NFC.
- **Paquete de Flutter:** `nfc_manager` 4.2.1 (MIT, `okadan.net`, Android +
  iOS) junto con `nfc_manager_ndef` 1.1.0, que expone la clase `Ndef` con
  `read()`, `write()`, `writeLock()`, `isWritable` y `maxSize`
  ([docs](https://pub.dev/documentation/nfc_manager_ndef/latest/nfc_manager_ndef/Ndef-class.html)).
  El README del paquete documenta exactamente los tres requisitos de arriba
  para iOS. Alternativa con mantenimiento más reciente: `flutter_nfc_kit`
  3.7.0 (`nfc.im`), con métodos `writeNDEFRecords()`; no la elegimos porque
  su "soporte Web" es en realidad WebUSB, no Web NFC, y agregaría una
  dependencia nueva sin ganar nada para el caso de uso de este spike.

El prototipo (`prototypes/nfc_ios`) arma el registro NDEF a mano con la
clase genérica `NdefRecord` de `ndef_record` (TNF *well-known*, tipo `U`),
porque el paquete no incluye un helper tipo `createUri()` como el de
Android. Los bytes del payload (código de abreviación + URL) los calcula
`encodeNdefUriPayload` en `lib/src/domain/nfc_message.dart`, con la misma
tabla de prefijos que usa Android
([`NdefRecord.URI_PREFIX_MAP`, AOSP](https://www.dre.vanderbilt.edu/~schmidt/android/android-4.0/frameworks/base/core/java/android/nfc/NdefRecord.java)),
así que el prototipo de iOS la reutiliza tal cual del paquete principal.

## 2. Requisitos de Apple: cuenta paga, no hay atajo gratuito

Esto es lo más importante del spike y lo verificamos contra la tabla oficial
de Apple, no contra un resumen:
[**Supported capabilities (iOS)**](https://developer.apple.com/help/account/reference/supported-capabilities-ios)
lista "Near Field Communication (NFC) Tag Reading" con check en las columnas
**ADP** (Apple Developer Program, pago) y **ADEP** (Enterprise), y la
columna **Apple Developer** (cuenta gratuita) vacía.

En la práctica, Xcode bloquea directamente agregar la capability con un
Personal Team. Un desarrollador reporta el mensaje textual en el
[foro de Apple](https://developer.apple.com/forums/thread/657348) (feb. 2025):

> "Personal development teams, including 'Oliver Schellhammer', do not
> support the Near Field Communication Tag Reading capability."

**Consecuencia concreta para este issue:** a diferencia del spike de
impresión directa (#8), donde Eduardo podía probar por USB con una cuenta
gratuita (perfiles de 7 días), acá **ninguna vía de instalación funciona sin
pagar los U$S 99/año**:

| Vía | ¿Sirve sin cuenta paga? |
| --- | --- |
| USB con Xcode (Personal Team) | No: Xcode rechaza agregar la capability |
| TestFlight | No: requiere cuenta ADP + build subido a App Store Connect |
| Distribución ad-hoc (UDID) | No: requiere cuenta ADP + perfil ad-hoc |

No encontramos ninguna fuente oficial que ofrezca una alternativa gratuita.
Por eso este PR **no** agrega la capability ni el entitlement al proyecto
principal (`ios/`): hacerlo obligaría a firmar con cuenta paga *cualquier*
build de iOS de la app desde ese momento, incluidas features no relacionadas
con NFC. El entitlement vive únicamente en el prototipo aislado
`prototypes/nfc_ios`, igual que el SDK de impresión del issue #8.

## 3. Qué se graba según el tipo de QR

`planNfcRecording` (`lib/src/domain/nfc_message.dart`) decide esto de forma
pura, a partir del contenido ya validado que usa el QR impreso:

- **WhatsApp, Instagram, Google Reseñas:** siempre son un link
  (`https://wa.me/...`, `https://instagram.com/...`,
  `https://search.google.com/local/writereview?placeid=...`). Se graba como
  un registro NDEF *well-known* de tipo URI: cualquier teléfono con NFC
  activado abre esa URL al acercarlo, igual que al escanear el QR impreso.
- **Mercado Pago:** depende de qué haya traído el comercio (ver
  `docs/mercado-pago.md`, issue #7). Si es un **link** de Mercado Pago
  (`https://mpago.la/...`, `https://link.mercadopago.com.ar/...`), se graba
  igual que los demás tipos. Si es el **QR interoperable** (payload EMVCo,
  TLV — ver `payment_qr.dart`), **no se graba**: ese payload no es una URL,
  sino texto codificado en formato EMVCo QR. No encontramos una fuente que
  describa un lector NFC pasivo estándar para ese formato en una billetera
  argentina: Transferencias 3.0 (`docs/mercado-pago.md`, issue #7) describe
  un circuito pensado para escanear con cámara, no para acercar un tag. Grabar
  el TLV igual en un tag no tendría con qué leerlo del otro lado.
  `planNfcRecording` devuelve `NfcUnsupportedPlan` con un mensaje explícito
  para este caso, y la UI (`NfcRecordButton` en web, el switch "Simular
  payload EMVCo" en el prototipo de iOS) lo muestra en vez del botón.

## 4. Tags recomendados: NTAG213, 215 o 216

Según el datasheet de NXP (`NTAG213_215_216.pdf`):

| Chip | Memoria de usuario (NDEF) | Alcanza para... |
| --- | --- | --- |
| NTAG213 | 144 bytes | Todas las URLs de este spike, con margen de sobra (la más larga, Google Reseñas con Place ID, ronda 80-120 caracteres) |
| NTAG215 | 504 bytes | Lo mismo, con mucho margen extra si se agrega un segundo registro (p. ej. Smart Poster con título) |
| NTAG216 | 888 bytes | Igual, rara vez necesario para este caso de uso |

**Recomendación: NTAG213** alcanza para cualquier URL que genera esta app;
no hace falta pagar de más por 215/216 salvo que a futuro se agreguen varios
registros NDEF por tag. Formato físico sugerido: sticker adhesivo circular
de 25 mm, para pegar directo detrás del cartel impreso (el otro formato
común, tarjeta PVC tipo credencial, no tiene sentido para este uso porque no
es para pegar).

**Precio:** no encontramos un número confiable en pesos argentinos — los
listados de Mercado Libre Argentina relevados variaban demasiado entre sí
para citar una cifra. En AliExpress, lotes de 10 NTAG213/215/216 en formato
sticker rondan entre USD 0,11 y USD 1,33 por unidad según el vendedor.
Cotizar al momento de comprar, no tomar esto como precio vigente.

**¿Conviene bloquearlos (solo lectura) después de grabarlos?** El lock de un
NTAG21x es permanente e irreversible a nivel de hardware (quema bits de
"latch" que solo pasan de 0 a 1). Según una guía técnica de referencia
([nfcore.app](https://nfcore.app/guides/lock-nfc-tag-permanently)), bloquear
tiene sentido para contenido que no va a cambiar (p. ej. un precio fijo en
una vidriera). **Para este caso de uso no lo recomendamos por defecto:** el
número de WhatsApp o el usuario de Instagram de una pyme chica puede cambiar
(nuevo número, cambio de cuenta, cierre del comercio), y un tag bloqueado
con un error de tipeo o un dato viejo queda inservible — hay que tirarlo y
comprar uno nuevo. El prototipo de iOS expone el lock como una opción
explícita (`Ndef.writeLock()` en `nfc_manager_ndef`), no como paso
obligatorio.

## 5. Convivencia web + iOS: misma lógica, detección en tiempo de ejecución

El botón "Grabar NFC" usa la misma lógica pura (`planNfcRecording`,
`encodeNdefUriPayload`) en los dos destinos, pero la capacidad de grabar se
resuelve distinto:

- **Web:** `lib/src/nfc/nfc_recorder.dart` sigue el mismo patrón de
  importación condicional que ya usa `label_exporter.dart` (`if
  (dart.library.js_interop)`), pero eso solo separa "web" de "nativo" — Web
  NFC (`NDEFReader`) existe *solo* en Chrome para Android (desde la versión
  89, [developer.chrome.com](https://developer.chrome.com/docs/capabilities/nfc)),
  nunca en desktop ni en Safari/iOS
  ([soporte de navegadores en caniuse.com](https://caniuse.com/webnfc); Apple
  no lo implementa y Mozilla lo marca "Harmful", así que tampoco está en
  Firefox).
  Por eso la detección real es en **tiempo de ejecución** dentro del propio
  build web: `nfc_recorder_web.dart` comprueba si `NDEFReader` existe en
  `globalContext` (más contexto seguro HTTPS). En desktop Chrome, Firefox o
  Safari esa comprobación da `false` y el botón no aparece — no rompe nada,
  coincide con el criterio de aceptación del issue.
- **iOS nativo:** no se resuelve en el build principal todavía. Por el
  costo de la cuenta de Apple Developer (punto 2), vive aislado en
  `prototypes/nfc_ios`, igual que el spike de impresión directa (#8). El
  código que sí comparte con la web es el de dominio
  (`lib/src/domain/nfc_message.dart`), importado por dependencia de path.
- Si en el futuro Eduardo decide pagar la cuenta y mergear la capability al
  proyecto principal, el punto de integración es agregar una tercera
  implementación de `NfcRecorder` (análoga a `nfc_recorder_web.dart`) detrás
  de un chequeo `Platform.isIOS`, usando `nfc_manager`/`nfc_manager_ndef`
  como en el prototipo.

Requiere, además, gesto del usuario (tocar el botón) tanto en Web NFC como
en Core NFC — ninguna de las dos API deja iniciar una grabación sin que la
persona la dispare explícitamente.

## 6. Recomendación y estimación

1. **Mergear ya** lo que no tiene costo ni riesgo: el botón "Grabar NFC" en
   la web para Chrome en Android, con la lógica de dominio con tests. Es lo
   que incluye este PR.
2. **Antes de seguir con iOS nativo, Eduardo decide** si paga el Apple
   Developer Program (U$S 99/año). Sin esa decisión no hay forma de avanzar
   — ni de probar — la capability de NFC en un iPhone real.
3. Si la respuesta es sí, el trabajo de implementación que sigue es chico:
   - Mover la capability y el entitlement del prototipo al proyecto
     principal (~0,5 día).
   - Integrar `NfcRecorder` nativo en el mismo botón ya construido para la
     web, sin tocar la UI (~0,5 día).
   - Prueba física con Maxi: grabar y leer varios tags NTAG213 reales, con
     los cuatro tipos de QR y los casos de error (tag bloqueado, sin tag,
     cancelado) — depende de conseguir los tags, no solo de código.
   - Publicar la primera build en el iPhone de Maxi: con cuenta paga, hay
     USB, ad-hoc o TestFlight disponibles; cuál conviene es una decisión de
     Eduardo según cuántos iPhones va a tener que atender.

## Prueba pendiente para Eduardo o Maxi

**Lo que se puede probar hoy, sin pagar nada:** desde un Android con Chrome
reciente y NFC activado, abrir la PWA, generar una etiqueta de WhatsApp o
Instagram y tocar "Grabar NFC" con un tag NTAG213 de prueba cerca. Repetir
con Mercado Pago: con un link de pago debería ofrecer grabar; con un QR
interoperable (EMVCo) debería explicar que no se puede.

**Lo que queda pendiente de la decisión de la cuenta paga:** compilar y
correr `prototypes/nfc_ios` en un iPhone real (instrucciones de firma en
Xcode iguales a las de `docs/impresion-directa.md`, sección "Preparar el Mac
y el iPhone"), con `flutter run --dart-define=NFC_SPIKE=true`. No se pudo
intentar el build en este contenedor: `flutter build ios` ni siquiera
aparece como subcomando de `flutter build` en Linux (el propio Flutter lo
oculta fuera de macOS), así que no hay un error de build que reportar — es
una limitación conocida del entorno, no del código.

## Verificación automatizada

TDD: para `planNfcRecording` y `encodeNdefUriPayload` se escribió primero el
test (fallando sin la función) y después la implementación; lo mismo para
`NfcRecordButton` con un `FakeNfcRecorder`. Desde este directorio:

```sh
# Raíz del repo
flutter analyze
flutter test
flutter build web --release   # confirma que el build web sigue compilando

# Prototipo de iOS (sin Xcode no corre; sí analiza y testea en Linux)
cd prototypes/nfc_ios
flutter analyze
flutter test
flutter test --dart-define=NFC_SPIKE=true
```

El prototipo de iOS no mockea `NfcManager` (usa una API generada con Pigeon,
sin un punto de inyección simple como el `MethodChannel` del spike #8): sus
tests cubren que el flag apagado no ofrece grabar y que, con el flag
prendido, el botón se habilita o se deshabilita según el tipo de QR y el
caso EMVCo. La sesión NFC real —descubrir el tag, escribir, bloquear— solo
se puede probar con un iPhone y un tag físicos.
