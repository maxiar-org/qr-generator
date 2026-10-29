import 'dart:async';
import 'dart:typed_data';

import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';

/// One tag at a time: discovers it, writes a single well-known URI record
/// (see `encodeNdefUriPayload` in the main package) and optionally locks it.
class NfcSession {
  static const _timeout = Duration(seconds: 30);

  Future<void> writeUri(Uint8List uriPayload, {required bool lock}) async {
    final completer = Completer<void>();
    await NfcManager.instance.startSession(
      pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
      alertMessageIos: 'Acercá el tag a grabar.',
      onSessionErrorIos: (error) {
        if (!completer.isCompleted) {
          completer.completeError(StateError(error.message));
        }
      },
      onDiscovered: (tag) async {
        try {
          final ndef = Ndef.from(tag);
          if (ndef == null) {
            throw StateError('Este tag no es compatible con NDEF.');
          }
          if (!ndef.isWritable) {
            throw StateError('Este tag está bloqueado o lleno.');
          }
          await ndef.write(
            message: NdefMessage(
              records: [
                NdefRecord(
                  typeNameFormat: TypeNameFormat.wellKnown,
                  type: Uint8List.fromList('U'.codeUnits),
                  identifier: Uint8List(0),
                  payload: uriPayload,
                ),
              ],
            ),
          );
          if (lock) await ndef.writeLock();
          await NfcManager.instance.stopSession(
            alertMessageIos: 'Etiqueta grabada.',
          );
          if (!completer.isCompleted) completer.complete();
        } catch (error) {
          await NfcManager.instance.stopSession(
            errorMessageIos: 'No se pudo grabar la etiqueta.',
          );
          if (!completer.isCompleted) completer.completeError(error);
        }
      },
    );
    return completer.future.timeout(_timeout);
  }
}
