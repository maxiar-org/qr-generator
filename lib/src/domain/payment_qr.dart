import 'dart:convert';

class PaymentQrValidation {
  const PaymentQrValidation(this.recognized, this.message);
  final bool recognized;
  final String message;
}

/// Offline format recognition, never a verification of the payee or validity
/// of a payment. The original string must be used unchanged when printing.
PaymentQrValidation validatePaymentQr(String data) {
  const unknown = PaymentQrValidation(
    false,
    'No reconocemos un QR de Mercado Pago ni un QR interoperable argentino. '
    'Pedile al comercio su QR de cobro y volvé a escanearlo.',
  );
  // The label renderer uses byte mode with M correction (2331 bytes max).
  if (utf8.encode(data).length > 2331 || data.trim() != data) return unknown;
  final uri = Uri.tryParse(data);
  if (uri != null &&
      uri.scheme == 'https' &&
      uri.userInfo.isEmpty &&
      (!uri.hasPort || uri.port == 443) &&
      uri.path.length > 1 &&
      (uri.host == 'link.mercadopago.com.ar' ||
          (uri.host == 'mpago.la' &&
              uri.pathSegments.where((s) => s.isNotEmpty).isNotEmpty))) {
    return const PaymentQrValidation(
      true,
      'Enlace de Mercado Pago reconocido.',
    );
  }
  try {
    final fields = _parseTlv(data);
    if (fields['00'] != '01' ||
        fields['58'] != 'AR' ||
        fields['53'] != '032' ||
        !RegExp(r'^\d{4}$').hasMatch(fields['52'] ?? '') ||
        (fields['59'] ?? '').isEmpty ||
        (fields['60'] ?? '').isEmpty ||
        !RegExp(r'6304[0-9A-Fa-f]{4}$').hasMatch(data) ||
        int.tryParse(fields['63'] ?? '', radix: 16) !=
            _crc16(data.substring(0, data.length - 4))) {
      return unknown;
    }
    var account = false;
    var mercadoPago = false;
    for (var id = 26; id <= 49; id++) {
      final value = fields[id.toString()];
      if (value == null) continue;
      final nested = _parseTlv(value);
      final domain = nested['00'] ?? '';
      if (RegExp(r'^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$').hasMatch(domain) &&
          nested.entries.any(
            (entry) => entry.key != '00' && entry.value.isNotEmpty,
          )) {
        account = true;
        mercadoPago |= domain == 'com.mercadolibre';
      }
    }
    if (!account) return unknown;
    return PaymentQrValidation(
      true,
      '${mercadoPago ? 'Mercado Pago' : 'Formato interoperable argentino'}: '
      'estructura EMVCo y checksum válidos.'
      '${fields['01'] == '12' || fields.containsKey('54') ? ' Tiene importe o es dinámico: puede vencer y no servir para un cartel permanente.' : ''}',
    );
  } on FormatException {
    return unknown;
  }
}

Map<String, String> _parseTlv(String data) {
  final fields = <String, String>{};
  var offset = 0;
  while (offset < data.length) {
    if (offset + 4 > data.length ||
        !RegExp(r'^\d{4}$').hasMatch(data.substring(offset, offset + 4))) {
      throw const FormatException('Invalid TLV');
    }
    final id = data.substring(offset, offset + 2);
    final length = int.parse(data.substring(offset + 2, offset + 4));
    offset += 4;
    if (length == 0 ||
        offset + length > data.length ||
        fields.containsKey(id)) {
      throw const FormatException('Invalid TLV length or duplicate');
    }
    fields[id] = data.substring(offset, offset + length);
    offset += length;
  }
  return fields;
}

int _crc16(String data) {
  var crc = 0xffff;
  for (final byte in utf8.encode(data)) {
    crc ^= byte << 8;
    for (var bit = 0; bit < 8; bit++) {
      crc = ((crc & 0x8000) != 0 ? (crc << 1) ^ 0x1021 : crc << 1) & 0xffff;
    }
  }
  return crc;
}
