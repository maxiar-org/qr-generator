const invalidMobileMessage =
    'Ingresá un celular argentino con código de área, por ejemplo '
    '11 2345-6789 o +54 9 11 2345 6789.';

/// Accepts ten national digits, or a domestic 15 after a 2–4 digit area code.
/// Ten-digit numbers are never split: a subscriber's own 15 is preserved.
/// This validates structure, not allocation or WhatsApp registration.
String normalizeArgentineMobile(String input) {
  final value = input.trim();
  if (!RegExp(r'^\+?[0-9\s()\-]+$').hasMatch(value)) {
    throw const FormatException(invalidMobileMessage);
  }
  var digits = value.replaceAll(RegExp(r'\D'), '');
  if (value.startsWith('+') || digits.startsWith('549')) {
    if (!digits.startsWith('549') || digits.length != 13) {
      throw const FormatException(invalidMobileMessage);
    }
    digits = digits.substring(3);
  } else {
    if (digits.startsWith('0')) digits = digits.substring(1);
    if (digits.length == 12) {
      final candidates = <String>[];
      for (var areaLength = 2; areaLength <= 4; areaLength++) {
        if (digits.substring(areaLength, areaLength + 2) == '15') {
          candidates.add(
            digits.substring(0, areaLength) + digits.substring(areaLength + 2),
          );
        }
      }
      if (candidates.length != 1) {
        throw const FormatException(invalidMobileMessage);
      }
      digits = candidates.single;
    }
  }
  if (!RegExp(r'^[1-3][0-9]{9}$').hasMatch(digits)) {
    throw const FormatException(invalidMobileMessage);
  }
  return '549$digits';
}

String buildWhatsAppUrl(String phone, {String message = ''}) {
  final number = normalizeArgentineMobile(phone);
  final query = message.trim().isEmpty
      ? ''
      : '?text=${Uri.encodeComponent(message)}';
  return 'https://wa.me/$number$query';
}
