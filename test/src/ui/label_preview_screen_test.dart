import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/domain/print_variant.dart';
import 'package:qr_generator/src/domain/qr_label_type.dart';
import 'package:qr_generator/src/printing/label_image_renderer.dart';
import 'package:qr_generator/src/ui/label_preview_screen.dart';

/// PNG mínimo (1x1) para no depender del motor gráfico real en estos tests;
/// el contenido exacto del PNG ya está cubierto por label_image_renderer_test.
final Uint8List _fakePngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChAI9CyfxuAAAAABJRU5ErkJggg==',
);

class _FakeRenderer extends LabelImageRenderer {
  const _FakeRenderer();

  @override
  Future<Uint8List> render({
    required String qrData,
    required QrLabelType type,
    required PrintVariant variant,
    required String text,
  }) async => _fakePngBytes;
}

void main() {
  testWidgets('shows a variant selector, the default text and a preview', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LabelPreviewScreen(
          type: QrLabelType.whatsapp,
          qrData: 'https://instagram.com/comercio',
          renderer: _FakeRenderer(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'WhatsApp'), findsOneWidget);
    for (final variant in PrintVariant.values) {
      expect(find.text(variant.displayName), findsOneWidget);
    }
    expect(find.text(QrLabelType.whatsapp.defaultText), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('switching the variant keeps showing a preview', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LabelPreviewScreen(
          type: QrLabelType.instagram,
          qrData: 'https://instagram.com/comercio',
          renderer: _FakeRenderer(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(PrintVariant.counterStand.displayName));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('editing the text replaces the default in the preview', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LabelPreviewScreen(
          type: QrLabelType.googleReviews,
          qrData: 'https://instagram.com/comercio',
          renderer: _FakeRenderer(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Gracias por tu visita');
    await tester.pumpAndSettle();

    expect(find.text('Gracias por tu visita'), findsOneWidget);
    expect(find.text(QrLabelType.googleReviews.defaultText), findsNothing);
  });
}
