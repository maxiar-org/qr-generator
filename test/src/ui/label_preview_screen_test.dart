import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/domain/print_variant.dart';
import 'package:qr_generator/src/domain/qr_label_type.dart';
import 'package:qr_generator/src/printing/label_image_renderer.dart';
import 'package:qr_generator/src/ui/label_preview_screen.dart';
import 'package:qr_generator/src/ui/export_actions.dart';

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

class _RecordingRenderer extends LabelImageRenderer {
  final List<String> receivedData = [];

  @override
  Future<Uint8List> render({
    required String qrData,
    required QrLabelType type,
    required PrintVariant variant,
    required String text,
  }) async {
    receivedData.add(qrData);
    return _fakePngBytes;
  }
}

void main() {
  testWidgets('keeps the supplied review URL when editing the label', (
    tester,
  ) async {
    final renderer = _RecordingRenderer();
    const reviewUrl =
        'https://search.google.com/local/writereview?placeid=ChIJ_custom';
    await tester.pumpWidget(
      MaterialApp(
        home: LabelPreviewScreen(
          type: QrLabelType.googleReviews,
          qrData: reviewUrl,
          renderer: renderer,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(PrintVariant.counterStand.displayName));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Gracias por venir');
    await tester.pumpAndSettle();
    expect(renderer.receivedData, [reviewUrl, reviewUrl, reviewUrl]);
    expect(tester.widget<ExportActions>(find.byType(ExportActions)).url, reviewUrl);
  });

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

    expect(find.widgetWithText(AppBar, 'Generador de QR'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
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
