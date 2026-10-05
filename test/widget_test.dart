import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr/qr.dart';
import 'package:qr_generator/src/ui/app.dart';
import 'package:qr_generator/src/ui/export_actions.dart';
import 'package:qr_generator/src/ui/label_preview_screen.dart';

// Check the actual printed QR pixels, not just the route arguments.
Future<void> expectPrintedUrl(WidgetTester tester, String url) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
    if (find.byType(ExportActions).evaluate().isNotEmpty) break;
  }
  final actions = tester.widget<ExportActions>(find.byType(ExportActions));
  expect(actions.url, url);
  expect(actions.bytes, isNotNull);
  await tester.runAsync(() async {
    final codec = await ui.instantiateImageCodec(actions.bytes!);
    final image = (await codec.getNextFrame()).image;
    final pixels = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
        .buffer
        .asUint8List();
    final qr = QrImage(
      QrCode.fromData(data: url, errorCorrectLevel: QrErrorCorrectLevel.M),
    );
    final margin = image.width * 0.06;
    final qrSize = math.min(
      image.width - margin * 2,
      image.height * 0.68 - margin * 2,
    );
    final cell = qrSize / (qr.moduleCount + 8);
    for (var row = 0; row < qr.moduleCount; row++) {
      for (var col = 0; col < qr.moduleCount; col++) {
        final x = ((image.width - qrSize) / 2 + (col + 4.5) * cell).floor();
        final y = (margin + (row + 4.5) * cell).floor();
        expect(
          pixels[(y * image.width + x) * 4] == 0,
          qr.isDark(row, col),
          reason: 'QR module ($row, $col) must encode $url',
        );
      }
    }
    image.dispose();
    codec.dispose();
  });
}

void main() {
  for (final message in ['', 'Hola, quiero consultar']) {
    testWidgets('WhatsApp from home to printable real QR: "$message"', (
      tester,
    ) async {
      await tester.pumpWidget(const QrGeneratorApp());
      await tester.tap(find.text('WhatsApp'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(TextFormField, 'Celular argentino'),
        findsOneWidget,
      );
      await tester.enterText(
        find.byType(TextFormField).first,
        '011 15 2345-6789',
      );
      await tester.enterText(find.byType(TextFormField).last, message);
      await tester.tap(find.text('Ver etiqueta'));
      await tester.pumpAndSettle();
      expect(find.byType(LabelPreviewScreen), findsOneWidget);
      await expectPrintedUrl(
        tester,
        'https://wa.me/5491123456789${message.isEmpty ? '' : '?text=Hola%2C%20quiero%20consultar'}',
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('011 15 2345-6789'), findsOneWidget);
    });
  }

  for (final input in [
    '@mi_comercio',
    'https://www.instagram.com/mi_comercio/',
  ]) {
    testWidgets('Instagram from home to printable real QR: $input', (
      tester,
    ) async {
      await tester.pumpWidget(const QrGeneratorApp());
      await tester.tap(find.text('Instagram'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(TextField, 'Usuario o enlace de Instagram'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField), input);
      await tester.tap(find.text('Ver etiqueta'));
      await tester.pumpAndSettle();
      expect(find.byType(LabelPreviewScreen), findsOneWidget);
      await expectPrintedUrl(tester, 'https://instagram.com/mi_comercio');
    });
  }

  for (final name in ['Google Reseñas', 'Mercado Pago']) {
    testWidgets('$name remains coming soon', (tester) async {
      await tester.pumpWidget(const QrGeneratorApp());
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
      expect(find.text('Próximamente'), findsOneWidget);
      expect(find.byType(LabelPreviewScreen), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Generador de QR'), findsOneWidget);
    });
  }
}
