import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/domain/whatsapp.dart';

void main() {
  final cases = {
    '11 2345-6789': '5491123456789',
    '+54 9 11 2345 6789': '5491123456789',
    '011 15 2345-6789': '5491123456789',
    '(0223) 15 456-7890': '5492234567890',
    '02901 15 456789': '5492901456789',
    '5491123456789': '5491123456789',
    '01123456789': '5491123456789',
    '1115234567': '5491115234567',
    '221154567890': '5492214567890',
  };
  for (final entry in cases.entries) {
    test('normalizes ${entry.key}', () {
      expect(normalizeArgentineMobile(entry.key), entry.value);
    });
  }
  for (final input in [
    '',
    '123',
    '+1 212 555 1234',
    '+54 11 2345 6789',
    '11 abc 23456789',
    '0000000000',
    '011 123456789012',
    '11+23456789',
    '123456789012',
    '011234567890',
  ]) {
    test('rejects invalid input $input', () {
      expect(() => normalizeArgentineMobile(input), throwsFormatException);
    });
  }
  test('omits empty message', () {
    expect(buildWhatsAppUrl('11 2345-6789'), 'https://wa.me/5491123456789');
    expect(
      buildWhatsAppUrl('11 2345-6789', message: '  '),
      'https://wa.me/5491123456789',
    );
  });
  test('encodes accents, newlines and reserved characters', () {
    const message = '¡Hola! café & precio?\n😀';
    final url = buildWhatsAppUrl('11 2345-6789', message: message);
    expect(
      url,
      'https://wa.me/5491123456789?text=${Uri.encodeComponent(message)}',
    );
    expect(Uri.parse(url).queryParameters['text'], message);
  });
}
