import 'dart:async';
import 'dart:typed_data';

import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';

abstract interface class NfcWritableTag {
  Future<void> write(Uint8List payload);
  Future<void> lock();
}

abstract interface class NfcSessionDriver {
  Future<void> start({
    required Future<void> Function(NfcWritableTag) onDiscovered,
    required void Function(Object) onError,
  });
  Future<void> stop();
}

class _CoreNfcDriver implements NfcSessionDriver {
  @override
  Future<void> start({
    required Future<void> Function(NfcWritableTag) onDiscovered,
    required void Function(Object) onError,
  }) => NfcManager.instance.startSession(
    pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
    alertMessageIos: 'Acercá el tag a grabar.',
    onSessionErrorIos: (error) => onError(StateError(error.message)),
    onDiscovered: (tag) => onDiscovered(_CoreNfcTag(tag)),
  );

  @override
  Future<void> stop() => NfcManager.instance.stopSession();
}

class _CoreNfcTag implements NfcWritableTag {
  _CoreNfcTag(this.tag);
  final NfcTag tag;

  Ndef get _ndef {
    final ndef = Ndef.from(tag);
    if (ndef == null) throw StateError('Este tag no es compatible con NDEF.');
    return ndef;
  }

  @override
  Future<void> write(Uint8List payload) async {
    final ndef = _ndef;
    if (!ndef.isWritable) throw StateError('Este tag está bloqueado o lleno.');
    await ndef.write(
      message: NdefMessage(
        records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.wellKnown,
            type: Uint8List.fromList('U'.codeUnits),
            identifier: Uint8List(0),
            payload: payload,
          ),
        ],
      ),
    );
  }

  @override
  Future<void> lock() => _ndef.writeLock();
}

/// Owns the native session until cleanup completes, including error paths.
class NfcSession {
  NfcSession({
    NfcSessionDriver? driver,
    this.timeout = const Duration(seconds: 30),
  }) : _driver = driver ?? _CoreNfcDriver();
  final NfcSessionDriver _driver;
  final Duration timeout;
  bool _busy = false;

  Future<void> writeUri(Uint8List uriPayload, {required bool lock}) async {
    if (_busy) throw StateError('Ya hay una sesión NFC pendiente.');
    _busy = true;
    final completer = Completer<void>();
    var active = true;
    var discovered = false;
    Timer? timer;
    void fail(Object error) {
      if (!active) return;
      active = false;
      completer.completeError(error);
    }

    // Attach the error listener before starting: native errors can arrive
    // while start() is still completing.
    final result = completer.future;
    unawaited(result.catchError((Object _) {}));
    try {
      await _driver.start(
        onError: fail,
        onDiscovered: (tag) async {
          if (!active || discovered) return;
          discovered = true;
          try {
            await tag.write(uriPayload);
            if (!active) return;
            if (lock) await tag.lock();
            if (!active) return;
            active = false;
            completer.complete();
          } catch (error) {
            fail(error);
          }
        },
      );
      timer = Timer(
        timeout,
        () =>
            fail(TimeoutException('Se agotó el tiempo para grabar.', timeout)),
      );
      await result;
    } finally {
      active = false;
      timer?.cancel();
      // Even invalidation from the iOS sheet needs explicit stop: the plugin
      // only clears its tagSession reference through this call.
      // If cleanup fails, keep this instance busy rather than permit reuse.
      await _driver.stop();
      _busy = false;
    }
  }
}
