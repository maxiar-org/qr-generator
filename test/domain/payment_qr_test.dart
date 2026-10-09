import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/domain/payment_qr.dart';

void main() {
  test('recognizes exact Mercado Pago HTTPS hosts and preserves payload', () {
    for (final value in [
      'https://mpago.la/pos/demo',
      'https://mpago.la/s/qr/demo',
      'https://link.mercadopago.com.ar/demo',
    ]) {
      expect(validatePaymentQr(value).recognized, isTrue);
    }
  });
  test(
    'rejects lookalikes, credentials, unsafe schemes and unrelated codes',
    () {
      for (final value in [
        'https://mpago.la.evil.test/pos/demo',
        'https://mpago.la@evil.test/pos/demo',
        'http://mpago.la/pos/demo',
        'https://evil.test/?next=mercadopago.com.ar',
        'https://mpago.la/',
        'javascript:alert(1)',
        'alias.comercio',
        '',
      ]) {
        expect(validatePaymentQr(value).recognized, isFalse, reason: value);
      }
    },
  );
  const official =
      '00020101021143540016com.mercadolibre0130https://mpago.la/pos/10368058550150011273265943055204970053030325802AR5906Prueba6004CABA6304FA22';
  test('recognizes official EMVCo sample and checks checksum', () {
    expect(validatePaymentQr(official).recognized, isTrue);
    expect(
      validatePaymentQr(official.replaceFirst('Prueba', 'Otraaa')).recognized,
      isFalse,
    );
    expect(validatePaymentQr('${official}00').recognized, isFalse);
    expect(validatePaymentQr(official.substring(0, 70)).recognized, isFalse);
  });
}
