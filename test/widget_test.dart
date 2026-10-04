import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/ui/app.dart';

void main() {
  testWidgets('shows all QR options and opens their placeholder screens', (
    tester,
  ) async {
    await tester.pumpWidget(const QrGeneratorApp());

    expect(find.text('Generador de QR'), findsOneWidget);
    const options = ['WhatsApp', 'Instagram', 'Google Reseñas', 'Mercado Pago'];
    for (final option in options) {
      expect(find.text(option), findsOneWidget);
    }

    for (final option in options) {
      await tester.tap(find.text(option));
      await tester.pumpAndSettle();
      expect(find.text('Próximamente'), findsOneWidget);
      expect(find.widgetWithText(AppBar, option), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Generador de QR'), findsOneWidget);
    }
  });
}
