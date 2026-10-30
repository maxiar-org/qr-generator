import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/domain/nfc_message.dart';
import 'package:qr_generator/src/domain/qr_label_type.dart';

void main() {
  test('plans a URI record for WhatsApp, Instagram and Google Reviews', () {
    for (final (type, url) in [
      (QrLabelType.whatsapp, 'https://wa.me/5491112345678'),
      (QrLabelType.instagram, 'https://instagram.com/comercio'),
      (
        QrLabelType.googleReviews,
        'https://search.google.com/local/writereview?placeid=abc123',
      ),
    ]) {
      final plan = planNfcRecording(type: type, qrData: url);
      expect(plan, isA<NfcUriRecordPlan>());
      expect((plan as NfcUriRecordPlan).url, url);
    }
  });

  test('plans a URI record for a Mercado Pago payment link', () {
    final url = File(
      'test/fixtures/mercado_pago/link.txt',
    ).readAsStringSync();
    final plan = planNfcRecording(type: QrLabelType.mercadoPago, qrData: url);
    expect(plan, isA<NfcUriRecordPlan>());
    expect((plan as NfcUriRecordPlan).url, url);
  });

  test(
    'rejects a Mercado Pago EMVCo payload: it is not a URL a tag reader can open',
    () {
      for (final fixture in ['interoperable.txt', 'emv.txt']) {
        final data = File(
          'test/fixtures/mercado_pago/$fixture',
        ).readAsStringSync();
        final plan = planNfcRecording(
          type: QrLabelType.mercadoPago,
          qrData: data,
        );
        expect(plan, isA<NfcUnsupportedPlan>(), reason: fixture);
        expect(
          (plan as NfcUnsupportedPlan).reason,
          contains('EMVCo'),
          reason: fixture,
        );
      }
    },
  );

  test('rejects schemes that a phone would not open as a link', () {
    for (final value in ['javascript:alert(1)', 'alias.comercio', '']) {
      final plan = planNfcRecording(
        type: QrLabelType.whatsapp,
        qrData: value,
      );
      expect(plan, isA<NfcUnsupportedPlan>(), reason: value);
    }
  });

  test('encodes the NFC Forum well-known URI record payload', () {
    expect(
      encodeNdefUriPayload('https://wa.me/5491112345678'),
      [0x04, ...'wa.me/5491112345678'.codeUnits],
    );
    expect(
      encodeNdefUriPayload('http://example.com'),
      [0x03, ...'example.com'.codeUnits],
    );
    expect(
      encodeNdefUriPayload('https://www.instagram.com/comercio'),
      [0x02, ...'instagram.com/comercio'.codeUnits],
    );
  });

  test('falls back to no abbreviation for a scheme outside the table', () {
    expect(
      encodeNdefUriPayload('custom-scheme://thing'),
      [0x00, ...'custom-scheme://thing'.codeUnits],
    );
  });
}
