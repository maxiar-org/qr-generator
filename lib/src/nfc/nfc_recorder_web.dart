import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'nfc_recorder.dart';

NfcRecorder createNfcRecorder() => const _WebNfcRecorder();

@JS('NDEFReader')
extension type _NdefReader._(JSObject _) implements JSObject {
  external _NdefReader();
  external JSPromise<JSAny?> write(JSAny message);
}

JSObject _urlRecord(String url) =>
    JSObject()
      ..setProperty('recordType'.toJS, 'url'.toJS)
      ..setProperty('data'.toJS, url.toJS);

JSObject _message(String url) =>
    JSObject()..setProperty('records'.toJS, [_urlRecord(url)].toJS);

/// Web NFC (`NDEFReader`): shipped in Chrome for Android since v89, never in
/// Safari/desktop browsers, so feature-detecting the constructor is enough
/// to tell Chrome-on-Android apart from every other web target.
class _WebNfcRecorder implements NfcRecorder {
  const _WebNfcRecorder();

  @override
  bool get isAvailable =>
      web.window.isSecureContext && globalContext.has('NDEFReader');

  @override
  Future<NfcWriteResult> writeUri(String url) async {
    try {
      // No async rendering here: the write must happen on the original tap,
      // same constraint as sharing (see label_exporter_web.dart).
      await _NdefReader().write(_message(url)).toDart;
      return NfcWriteResult.written;
    } catch (error) {
      if (error.isA<web.DOMException>() &&
          (error as web.DOMException).name == 'AbortError') {
        return NfcWriteResult.cancelled;
      }
      rethrow;
    }
  }
}
