import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_ios_spike/main.dart';

void main() {
  testWidgets('default flag hides recording and shows no NFC prompt', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SpikeScreen()));
    expect(find.text('Grabar NFC'), findsNothing);
    expect(find.textContaining('desactivado'), findsOneWidget);
  }, skip: nfcSpikeEnabled);

  group('enabled flag', () {
    testWidgets('offers to record the demo link for every linkable type', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SpikeScreen()));
      for (final label in ['WhatsApp', 'Instagram', 'Google Reseñas']) {
        await tester.tap(find.text(label));
        await tester.pump();
        expect(
          tester
              .widget<FilledButton>(find.widgetWithText(FilledButton, 'Grabar NFC'))
              .onPressed,
          isNotNull,
          reason: label,
        );
        expect(find.textContaining('Se va a grabar: https://'), findsOneWidget);
      }
    }, skip: !nfcSpikeEnabled);

    testWidgets(
      'refuses to record Mercado Pago EMVCo content but allows its link',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: SpikeScreen()));
        await tester.tap(find.text('Mercado Pago'));
        await tester.pump();
        expect(
          tester
              .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Grabar NFC'),
              )
              .onPressed,
          isNotNull,
        );
        await tester.tap(find.text('Simular payload EMVCo (no un link)'));
        await tester.pump();
        expect(
          tester
              .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Grabar NFC'),
              )
              .onPressed,
          isNull,
        );
        expect(find.textContaining('ninguna billetera lo lee'), findsOneWidget);
      },
      skip: !nfcSpikeEnabled,
    );
  });
}
