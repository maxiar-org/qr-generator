import 'qr_label_type.dart';

/// What to write to an NFC tag for a given QR, decided purely from its
/// content: a standard NDEF URI record if it's a link, or nothing otherwise.
sealed class NfcRecordPlan {
  const NfcRecordPlan();
}

/// The QR content is a link: any phone's NFC reader opens it the same way
/// it would after scanning the printed QR.
class NfcUriRecordPlan extends NfcRecordPlan {
  const NfcUriRecordPlan(this.url);
  final String url;
}

/// The QR content isn't a link, so writing it to a tag would not let a
/// wallet or browser act on it the way scanning the QR does.
class NfcUnsupportedPlan extends NfcRecordPlan {
  const NfcUnsupportedPlan(this.reason);
  final String reason;
}

/// Mercado Pago QR capture can hold either a payment link or a raw EMVCo
/// TLV payload (see `payment_qr.dart`); every other [QrLabelType] always
/// produces a link.
NfcRecordPlan planNfcRecording({
  required QrLabelType type,
  required String qrData,
}) {
  final uri = Uri.tryParse(qrData);
  final isLink =
      uri != null &&
      uri.hasScheme &&
      uri.scheme == 'https' &&
      uri.host.isNotEmpty;
  if (isLink) return NfcUriRecordPlan(qrData);
  return NfcUnsupportedPlan(
    type == QrLabelType.mercadoPago
        ? 'Este QR de Mercado Pago es un payload EMVCo, no un link: '
              'ninguna billetera lo lee desde una etiqueta NFC.'
        : 'Este contenido no es un link: no se puede grabar en una '
              'etiqueta NFC.',
  );
}
