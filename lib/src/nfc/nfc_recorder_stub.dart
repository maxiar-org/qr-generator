import 'nfc_recorder.dart';

NfcRecorder createNfcRecorder() => const _UnavailableNfcRecorder();

/// Covers every non-web target this app compiles for today. iOS native
/// recording (Core NFC) is a separate prototype, not bundled here: see
/// `docs/spike-nfc.md` for why.
class _UnavailableNfcRecorder implements NfcRecorder {
  const _UnavailableNfcRecorder();

  @override
  void cancel() {}

  @override
  bool get isAvailable => false;

  @override
  Future<NfcWriteResult> writeUri(String url) {
    throw UnsupportedError('Grabar NFC no está disponible en este build.');
  }
}
