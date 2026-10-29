import 'dart:convert';
import 'dart:typed_data';

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

/// NFC Forum "URI Record Type Definition" (section 3.2.2) abbreviation
/// codes, as implemented by Android's `NdefRecord.URI_PREFIX_MAP` (AOSP
/// `frameworks/base/core/java/android/nfc/NdefRecord.java`). Index 0 means
/// no abbreviation.
const _uriPrefixes = <String>[
  '',
  'http://www.',
  'https://www.',
  'http://',
  'https://',
  'tel:',
  'mailto:',
  'ftp://anonymous:anonymous@',
  'ftp://ftp.',
  'ftps://',
  'sftp://',
  'smb://',
  'nfs://',
  'ftp://',
  'dav://',
  'news:',
  'telnet://',
  'imap:',
  'rtsp://',
  'urn:',
  'pop:',
  'sip:',
  'sips:',
  'tftp:',
  'btspp://',
  'btl2cap://',
  'btgoep://',
  'tcpobex://',
  'irdaobex://',
  'file://',
  'urn:epc:id:',
  'urn:epc:tag:',
  'urn:epc:pat:',
  'urn:epc:raw:',
  'urn:epc:',
];

/// Encodes [url] as an NFC Forum well-known URI record payload: one
/// abbreviation-code byte, then the rest of the URL in UTF-8. Platform NDEF
/// plugins (e.g. `nfc_manager_ndef`) take this as raw bytes; Web NFC builds
/// the equivalent record itself from a plain string.
Uint8List encodeNdefUriPayload(String url) {
  var bestCode = 0;
  var bestPrefixLength = 0;
  for (var code = 1; code < _uriPrefixes.length; code++) {
    final prefix = _uriPrefixes[code];
    if (prefix.length > bestPrefixLength && url.startsWith(prefix)) {
      bestCode = code;
      bestPrefixLength = prefix.length;
    }
  }
  return Uint8List.fromList([
    bestCode,
    ...utf8.encode(url.substring(bestPrefixLength)),
  ]);
}
