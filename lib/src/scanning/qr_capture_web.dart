import 'dart:js_interop';

@JS('qrCapture')
external JSPromise<JSString?> _capture(JSBoolean camera);
@JS('cancelQrCapture')
external void cancelQrCapture();

Future<String?> captureQr(bool camera) async {
  try {
    return (await _capture(camera.toJS).toDart)?.toDart;
  } catch (_) {
    throw const FormatException(
      'No pudimos leer el QR. Probá otra foto o habilitá la cámara en Safari.',
    );
  }
}
