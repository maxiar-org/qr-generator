@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/nfc/nfc_recorder.dart';
import 'package:qr_generator/src/nfc/nfc_recorder_web.dart';

@JS('eval')
external JSAny? evaluate(JSString code);

void main() {
  test(
    'passes a real abort signal, cancels pending write, and can retry',
    () async {
      evaluate(
        '''
      globalThis.NDEFReader = class {
        write(message, options) {
          globalThis.lastSignal = options?.signal;
          globalThis.lastUrl = message.records[0].data;
          return new Promise((resolve, reject) => {
            globalThis.finishWrite = resolve;
            options?.signal.addEventListener('abort', () =>
              reject(new DOMException('Cancelled', 'AbortError')));
          });
        }
      };
    '''
            .toJS,
      );
      final recorder = createNfcRecorder();
      final first = recorder.writeUri('https://example.com/old');
      expect(globalContext.getProperty<JSAny?>('lastSignal'.toJS), isNotNull);
      recorder.cancel();
      expect(await first, NfcWriteResult.cancelled);
      final retry = recorder.writeUri('https://example.com/new');
      expect(
        globalContext.getProperty<JSString>('lastUrl'.toJS).toDart,
        'https://example.com/new',
      );
      globalContext.callMethod<JSAny?>('finishWrite'.toJS);
      expect(await retry, NfcWriteResult.written);
      recorder.cancel();
      evaluate('delete globalThis.NDEFReader'.toJS);
    },
  );
}
