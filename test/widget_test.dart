import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_generator/src/ui/label_preview_screen.dart';
import 'package:qr_generator/src/domain/qr_label_type.dart';
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
    await tester.tap(find.text('Vista previa de impresión'));
    await tester.pumpAndSettle();
    final preview = tester.widget<LabelPreviewScreen>(
      find.byType(LabelPreviewScreen),
    );
    expect(
      preview.qrData,
      'https://search.google.com/local/writereview?placeid=$id',
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'https://maps.app.goo.gl/test',
    );
    await tester.pump();
    expect(find.byType(QrImageView), findsNothing);
    expect(find.text('Vista previa de impresión'), findsNothing);
    await tester.tap(find.text('Generar QR'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Los links cortos necesitan'), findsOneWidget);
    expect(find.byType(QrImageView), findsNothing);
    expect(find.text('Vista previa de impresión'), findsNothing);
    await tester.enterText(find.byType(TextField), id);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Generador de QR'), findsOneWidget);
  });

  testWidgets('shows all QR options and opens their screens', (tester) async {
    await tester.pumpWidget(const QrGeneratorApp());

    expect(find.text('Generador de QR'), findsOneWidget);
    for (final type in QrLabelType.values) {
      expect(find.text(type.displayName), findsOneWidget);
    }

    for (final type in QrLabelType.values) {
      await tester.tap(find.text(type.displayName));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, type.displayName), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Generador de QR'), findsOneWidget);
    }
  });
}
