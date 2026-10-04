import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_generator/src/ui/app.dart';

void main() {
  testWidgets('generates Google review QR and clears it on edits', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const QrGeneratorApp());
    await tester.tap(find.text('Google Reseñas'));
    await tester.pumpAndSettle();
    const id = 'ChIJgUbEo8cfqokR5lP9_Wh_DaM';
    await tester.enterText(find.byType(TextField), id);
    await tester.tap(find.text('Generar QR'));
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsOneWidget);
    expect(
      find.text('https://search.google.com/local/writereview?placeid=$id'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byType(TextField),
      'https://maps.app.goo.gl/test',
    );
    await tester.pump();
    expect(find.byType(QrImageView), findsNothing);
    await tester.tap(find.text('Generar QR'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Los links cortos necesitan'), findsOneWidget);
    expect(find.byType(QrImageView), findsNothing);
    await tester.enterText(find.byType(TextField), id);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Generador de QR'), findsOneWidget);
  });

  testWidgets('generates WhatsApp QR and clears stale results on edits', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const QrGeneratorApp());
    await tester.tap(find.text('WhatsApp'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).first,
      '(0223) 15 456-7890',
    );
    await tester.enterText(find.byType(TextFormField).last, 'Hola & café');
    await tester.tap(find.text('Generar QR'));
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsOneWidget);
    expect(
      tester.widget<SelectableText>(find.byType(SelectableText)).data,
      'https://wa.me/5492234567890?text=Hola%20%26%20caf%C3%A9',
    );
    await tester.enterText(find.byType(TextFormField).last, '');
    await tester.pump();
    expect(find.byType(QrImageView), findsNothing);
    await tester.tap(find.text('Generar QR'));
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsOneWidget);
    expect(
      tester.widget<SelectableText>(find.byType(SelectableText)).data,
      'https://wa.me/5492234567890',
    );
    await tester.enterText(find.byType(TextFormField).first, '123');
    await tester.tap(find.text('Generar QR'));
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsNothing);
    expect(find.textContaining('Ingresá un celular argentino'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Generador de QR'), findsOneWidget);
  });
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
        find.text(option != 'Mercado Pago' ? 'Generar QR' : 'Próximamente'),
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
