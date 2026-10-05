# Impresión directa en la Detonger DT01 desde iOS

Investigación del issue #8, 5 de octubre de 2026. La dependencia #4 está cerrada.

## Conclusión

**Viable como experimento nativo; compatibilidad con la DT01 de Maxi todavía no
confirmada.** Hay un puente iOS real en `flutter_dothantech_lpapi_thermal_printer`
2.7.3 y un SDK LPAPI para iOS. Se incluye un prototipo para que Eduardo haga la
prueba física. No se propone reemplazar todavía el flujo de WePrint.

El prototipo está en [`prototypes/lpapi_ios`](../prototypes/lpapi_ios): una app
separada con **iOS como único destino generado**, botón **Imprimir** detrás de
`--dart-define=LPAPI_SPIKE=true` y flag apagado por defecto. El SDK no se agrega al
`pubspec.yaml` de la aplicación principal ni se importa desde su punto de entrada;
por eso no entra en el build de la PWA. La app experimental rechaza otros sistemas
en su punto de entrada. El flag apaga la interfaz y las llamadas de impresión;
no elimina la biblioteca nativa del binario experimental de iOS.

## Qué se comprobó y qué falta

| Componente | Evidencia y alcance |
| --- | --- |
| Plugin | Se fija 2.7.3, con lockfile. Su [ficha publicada](https://pub.dev/packages/flutter_dothantech_lpapi_thermal_printer/versions/2.7.3) declara Android e iOS; solo identifica la serie P1 como probada. Una foto o parecido con la DT01 no certifica protocolo, firmware ni funcionamiento en iPhone. |
| Implementación iOS | El [puente Objective-C](https://github.com/ancill/flutter_dothantech_lpapi_thermal_printer/blob/994483374d7d51d77f1fa0a6b08a52d562fae4a6/ios/Classes/FlutterDothantechLpapiThermalPrinterPlugin.m) llama a `scanPrinters`, `openPrinter`, `printImage` y `closePrinter` de LPAPI. En iOS usa el nombre descubierto como `address`, no una MAC escrita a mano. No es un stub. |
| Enlace nativo | El [podspec](https://github.com/ancill/flutter_dothantech_lpapi_thermal_printer/blob/994483374d7d51d77f1fa0a6b08a52d562fae4a6/ios/flutter_dothantech_lpapi_thermal_printer.podspec) declara iOS 12+, CoreBluetooth y bibliotecas estáticas distintas para dispositivo y simulador. Los archivos `.a` están presentes. Esto no prueba que enlacen con el Xcode de Eduardo. El prototipo usa iOS 15+, generado por Flutter 3.47.6, y CocoaPods. |
| Fabricante | Detonger publica una [guía de LPAPI para iOS](https://en.detonger.com/software/um/德佟电子-蓝牙打印接口iOS使用快速入门-2021-05-08.pdf). Confirma la existencia del SDK, no la compatibilidad de esta combinación específica de plugin, DT01 y firmware. |
| DT01 real | Pendiente: descubrir, conectar, imprimir, medir y escanear con el equipo de Maxi. No hubo acceso a impresora, iPhone ni Xcode desde Linux. |

Se revisó el repositorio del plugin en el commit
`994483374d7d51d77f1fa0a6b08a52d562fae4a6`; la dependencia se descarga de pub.dev,
no de una rama mutable. El [header LPAPI](https://github.com/ancill/flutter_dothantech_lpapi_thermal_printer/blob/994483374d7d51d77f1fa0a6b08a52d562fae4a6/ios/Frameworks/LPAPI.h)
expone impresión de `UIImage`. El experimento convierte a base64 el PNG original
producido por `LabelImageRenderer`, sin redibujar el QR con otro motor.

## Bluetooth y permisos

El `Info.plist` del prototipo incluye `NSBluetoothAlwaysUsageDescription`, con el
texto «Usamos Bluetooth para imprimir la etiqueta de prueba en tu DT01».
[Apple exige esta clave para CoreBluetooth](https://developer.apple.com/documentation/corebluetooth).
La autorización se solicita al acceder a Bluetooth; agregá permiso en Ajustes si
lo rechazaste. Encendé Bluetooth y mantené la app en primer plano.

`NSBluetoothPeripheralUsageDescription` corresponde al soporte anterior a iOS 13;
[Apple indica agregar ambas claves si se soportan esos sistemas](https://developer.apple.com/documentation/bundleresources/information-property-list/nsbluetoothperipheralusagedescription).
No hace falta en este prototipo con mínimo iOS 15. No se solicitan ubicación ni
permisos de Android, ni se habilitan modos de Bluetooth en segundo plano.

La búsqueda se hace dentro de la app. Cerrá WePrint para liberar una conexión
previa y seleccioná explícitamente el nombre de la DT01. Si aparecen nombres
iguales, apagá las otras impresoras: el puente identifica por nombre. No se asume
que Bluetooth Classic o una impresora visible en Ajustes impliquen compatibilidad
con el SDK iOS.

## Preparar el Mac y el iPhone

Necesitás Mac, Flutter **3.47.6**, Xcode con soporte para la versión de iOS del
iPhone, herramientas de línea de comandos, plataforma iOS y CocoaPods. Seguí la
[preparación oficial de Flutter para iOS](https://docs.flutter.dev/platform-integration/ios/setup).
En el Mac:

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
sudo xcodebuild -license
xcodebuild -downloadPlatform iOS
flutter --version
flutter doctor -v
pod --version
```

Conectá el iPhone por USB, desbloquealo y aceptá confiar en el Mac. Activá Modo de
desarrollador en Ajustes → Privacidad y seguridad si la versión de iOS lo requiere,
y reiniciá cuando lo pida. La prueba de Bluetooth necesita el iPhone físico.

### Firma: cuenta gratuita frente a Apple Developer

| Opción | Qué implica para esta prueba |
| --- | --- |
| Apple Account gratuita / Personal Team | Permite instalar desde Xcode para probar. Los perfiles vencen a los **7 días desde su emisión**: hay que volver a firmar e instalar. Sirve para esta prueba con el iPhone conectado; no sirve como instalación permanente para Maxi. |
| Apple Developer Program | Membresía paga con más opciones de distribución y administración de dispositivos. No tiene la restricción del Personal Team de renovar cada 7 días, pero certificados y perfiles también vencen. No es necesario comprarla para el primer ensayo por USB. |

Fuente: [comparación de cuentas de Apple](https://developer.apple.com/help/account/basics/about-your-developer-account).
La firma y las credenciales se configuran localmente en Xcode; no se suben al repo.
Publicar en App Store queda fuera de alcance.

## Prueba de Eduardo con el iPhone de Maxi

Desde el checkout del repo:

```sh
git fetch origin
git checkout agent/8-spike-impresion-directa-con-lpapi-detong
flutter pub get
cd prototypes/lpapi_ios
flutter pub get
flutter build ios --config-only --no-codesign --dart-define=LPAPI_SPIKE=true
cd ios
pod install
cd ..
open ios/Runner.xcworkspace
```

En Xcode, agregá tu Apple Account en Settings → Accounts. En Runner → Signing &
Capabilities, activá firma automática, elegí tu Team y un Bundle Identifier único
si el propuesto no está disponible. Seleccioná el iPhone como dispositivo.
No uses `Runner.xcodeproj`: abrí el workspace con los pods instalados.

Volvé a la terminal, todavía dentro de `prototypes/lpapi_ios`:

```sh
flutter devices
flutter run --release -d <id-del-iphone> --dart-define=LPAPI_SPIKE=true
```

Reemplazá `<id-del-iphone>` por el ID listado. Si iOS pide confiar en la app de
desarrollo, hacelo en Ajustes → General → VPN y gestión de dispositivos. El modo
release permite abrirla sin mantener una sesión de depuración conectada.

1. Cargá papel en la DT01, encendela y cerrá WePrint.
2. Tocá **Buscar impresoras**, aceptá Bluetooth y elegí la DT01 de Maxi.
3. Tocá **Imprimir** una sola vez. Se envía una etiqueta de prueba de **464 × 464 px**
   con el rasterizador de #4, ícono de Instagram y QR a
   `https://example.com/lpapi-dt01`. Es un dato de prueba, no el perfil de un cliente.
4. Confirmá que salga una sola etiqueta, sin cortes laterales, con márgenes blancos
   y proporciones cuadradas. A 203 ppp, 464 puntos representan unos 58,1 mm;
   comprobá el ancho real y si LPAPI reescala. No se garantiza correspondencia 1:1.
5. Escaneá el QR y verificá que el contenido sea exactamente esa URL; no es
   necesario que la página exista. Compará tamaño y legibilidad con WePrint.
6. Probá Bluetooth apagado, permiso denegado, impresora apagada y sin papel.
   Comprobá que no quede habilitado un segundo envío durante una operación.
   Ante error, cerrá completamente y reabrí la app; ante timeout revisá primero si
   imprimió, para evitar duplicados. Cada llamada tiene límite de 30 segundos;
   la desconexión puede consumir otros 30.
7. Volvé a ejecutar sin `--dart-define=LPAPI_SPIKE=true`: debe mostrar
   «Prototipo desactivado» y no ofrecer **Imprimir**.

Anotá en el PR: modelo de iPhone/iOS, Xcode, firmware si está disponible, nombre
Bluetooth, resultado del build, descubrimiento, conexión, tiempo de impresión,
ancho/alto medidos, lectura del QR y resultados de los casos de error. Adjuntá una
foto de la etiqueta sin datos de clientes. Un error de linker o un crash nativo
es un resultado del spike; guardá el mensaje exacto antes de cambiar el SDK.

## Riesgos y siguiente paso

- **Modelo y firmware:** no hay confirmación de DT01 + iOS en la evidencia revisada.
  Si no aparece o rechaza el trabajo, consultar al fabricante por esa combinación;
  no inferir compatibilidad por la marca.
- **Binarios y mantenimiento:** el plugin incorpora bibliotecas cerradas y usa
  opciones de enlace específicas. Xcode, arquitectura y versiones nuevas de iOS
  pueden exponer problemas que los tests Dart no detectan. El simulador no valida
  la comunicación real.
- **Licencia:** el wrapper declara MIT; el header del SDK conserva copyright de
  DothanTech. Antes de distribuir una app comercial, verificar las condiciones de
  redistribución del SDK con el proveedor. No se copian sus binarios a este repo.
- **Impresión:** el puente no expone tamaño físico en `printImage`. El ancho útil,
  alimentación, escalado, densidad y lectura con papel térmico requieren prueba.
  El prototipo cubre Adhesivo; Mostrador y Tarjetero quedan para una segunda ronda.
- **Estados y callbacks:** una respuesta exitosa del SDK no prueba salida en papel.
  El timeout Dart no cancela trabajo nativo. Se bloquean reintentos después de un
  error hasta reiniciar; no hay reenvío automático ni cola persistente.
- **Operación diaria:** reinstalar cada 7 días con Personal Team es incómodo.
  Bluetooth directo necesita una app nativa; este plugin no habilita impresión
  desde Safari/PWA.

Si la prueba física pasa, el siguiente trabajo es integrar selección y estado de
impresora en el flujo real, probar las tres variantes y elegir cómo instalar la
app para uso habitual. Hasta entonces, el resultado es experimental.

## Verificación automatizada

Se escribió primero el test del contrato de impresión y del flag, y se comprobó
que fallaba sin la implementación. Luego se implementó y se formateó el código.
Desde Linux:

```sh
# Raíz del repo
flutter analyze
flutter test
# App experimental
cd prototypes/lpapi_ios
flutter analyze
flutter test
flutter test --dart-define=LPAPI_SPIKE=true
```

Los tests simulan el canal del plugin: verifican PNG/base64 sin alteraciones,
selección explícita, error de conexión/impresión, desconexión y flag en ambos
estados. No prueban los binarios nativos, firma ni Bluetooth. El build iOS y la
impresión física quedan pendientes de Eduardo en el Mac.
