import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/domain/print_variant.dart';
import 'package:qr_generator/src/domain/qr_label_type.dart';
import 'package:qr_generator/src/printing/label_image_renderer.dart';
import 'package:qr_generator/src/ui/label_preview_screen.dart';
import 'package:qr_generator/src/ui/export_actions.dart';
import 'package:qr_generator/src/ui/theme/app_theme.dart';

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
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final loader = FontLoader('IBM Plex Sans')
      ..addFont(rootBundle.load('assets/fonts/IBMPlexSans-Variable.ttf'));
    await loader.load();
  });

  for (final width in [320.0, 390.0, 1280.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('variant names stay whole at width $width and scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: const LabelPreviewScreen(
              type: QrLabelType.mercadoPago,
              qrData: 'https://mpago.la/demo',
              renderer: _FakeRenderer(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        for (final selected in PrintVariant.values) {
          await tester.tap(find.text(selected.displayName));
          await tester.pumpAndSettle();
          expect(
            find.text('464 x ${printVariantSizes[selected]!.height} px'),
            findsOneWidget,
          );
          for (final variant in PrintVariant.values) {
            final paragraph = tester.renderObject<RenderParagraph>(
              find.text(variant.displayName),
            );
            final boxes = paragraph.getBoxesForSelection(
              TextSelection(
                baseOffset: 0,
                extentOffset: variant.displayName.length,
              ),
            );
            expect(
              boxes.map((box) => box.top).toSet(),
              hasLength(1),
              reason: '${variant.displayName} must occupy one line',
            );
            expect(paragraph.didExceedMaxLines, isFalse);
            expect(
              paragraph.getMaxIntrinsicWidth(double.infinity),
              lessThanOrEqualTo(paragraph.size.width + 0.01),
            );
          }
          expect(tester.takeException(), isNull);
        }
      });
    }
  }

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
    expect(
      tester.widget<ExportActions>(find.byType(ExportActions)).url,
      reviewUrl,
    );
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
