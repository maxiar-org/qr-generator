import 'nfc_recorder_stub.dart'
    if (dart.library.js_interop) 'nfc_recorder_web.dart'
    as platform;

enum NfcWriteResult { written, cancelled }

/// Writes a single NDEF URI record to an NFC tag, where the platform
/// supports it: Chrome on Android (Web NFC). The iOS native path (Core NFC)
/// needs its own Apple Developer Program entitlement and isn't bundled in
/// this build; see `docs/spike-nfc.md`.
abstract interface class NfcRecorder {
  factory NfcRecorder() => platform.createNfcRecorder();

  /// Whether this platform can attempt an NFC write right now. Checked at
  /// runtime, not just by target: e.g. desktop Chrome has no NFC hardware.
  bool get isAvailable;

  Future<NfcWriteResult> writeUri(String url);
}
