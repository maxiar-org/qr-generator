import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/ui/app.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  testWidgets('shows all QR options and opens their screens', (tester) async {
    await tester.pumpWidget(const QrGeneratorApp());

    expect(find.text('Generador de QR'), findsOneWidget);
    const options = ['WhatsApp', 'Instagram', 'Google Reseñas', 'Mercado Pago'];
    for (final option in options) {
      expect(find.text(option), findsOneWidget);
    }

    for (final option in options) {
      await tester.tap(find.text(option));
      await tester.pumpAndSettle();
      expect(
        find.text(option == 'Instagram' ? 'Generar QR' : 'Próximamente'),
        findsOneWidget,
      );
      expect(find.widgetWithText(AppBar, option), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Generador de QR'), findsOneWidget);
    }
  });
  testWidgets('generates a profile QR and clears stale results on edit', (
    tester,
  ) async {
    await tester.pumpWidget(const QrGeneratorApp());
    await tester.tap(find.text('Instagram'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'instagram.com/usuario?igsh=abc',
    );
    await tester.tap(find.text('Generar QR'));
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('https://instagram.com/usuario'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'usuario inválido');
    await tester.pump();
    expect(find.byType(QrImageView), findsNothing);
    await tester.tap(find.text('Generar QR'));
    await tester.pumpAndSettle();
    expect(find.textContaining('entre 1 y 30 caracteres'), findsOneWidget);
    expect(find.byType(QrImageView), findsNothing);
    await tester.enterText(find.byType(TextField), '@otro');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('https://instagram.com/otro'), findsOneWidget);
  });
}
