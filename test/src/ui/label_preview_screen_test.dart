import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/domain/poster_template.dart';
import 'package:qr_generator/src/domain/qr_label_type.dart';
import 'package:qr_generator/src/printing/label_image_renderer.dart';
import 'package:qr_generator/src/ui/label_preview_screen.dart';
import 'package:qr_generator/src/ui/export_actions.dart';
import 'package:qr_generator/src/ui/widgets/poster_fullscreen_view.dart';
import 'package:qr_generator/src/ui/widgets/poster_template_view.dart';
import 'package:qr_generator/src/ui/widgets/template_selector.dart';

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
    required String text,
  }) async => _fakePngBytes;
}

class _RecordingRenderer extends LabelImageRenderer {
  final List<String> receivedData = [];

  @override
  Future<Uint8List> render({
    required String qrData,
    required QrLabelType type,
    required String text,
  }) async {
    receivedData.add(qrData);
    return _fakePngBytes;
  }
}

/// Sin templates: los tests que solo ejercitan la etiqueta a imprimir no
/// necesitan depender de `rootBundle` ni del catálogo real.
Future<List<PosterTemplate>> _noTemplates() async => const [];

void main() {
  testWidgets('keeps the supplied review URL for the export actions', (
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
          loadTemplateCatalog: _noTemplates,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(renderer.receivedData, [reviewUrl]);
    expect(
      tester.widget<ExportActions>(find.byType(ExportActions)).url,
      reviewUrl,
    );
  });

  testWidgets(
    'renders the label with the default text, without showing it or the TextField',
    (tester) async {
      final renderer = _RecordingRenderer();
      await tester.pumpWidget(
        MaterialApp(
          home: LabelPreviewScreen(
            type: QrLabelType.whatsapp,
            qrData: 'https://instagram.com/comercio',
            renderer: renderer,
            loadTemplateCatalog: _noTemplates,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Generador de QR'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.text(QrLabelType.whatsapp.defaultText), findsNothing);
      expect(find.text('464 x 464 px'), findsNothing);
      expect(find.byType(Image), findsNothing);
    },
  );

  group('selector de templates', () {
    // Catálogo de prueba con la misma forma que assets/templates/templates.json,
    // con un template por tipo más uno que sirve para dos tipos a la vez.
    final fakeCatalog = [
      const PosterTemplate(
        id: 'google-resenas',
        name: 'Google Reseñas',
        image: 'assets/templates/google-resenas.png',
        tags: {'google'},
      ),
      const PosterTemplate(
        id: 'instagram',
        name: 'Instagram',
        image: 'assets/templates/instagram.png',
        tags: {'instagram'},
      ),
      const PosterTemplate(
        id: 'mercadopago',
        name: 'Mercado Pago',
        image: 'assets/templates/mercadopago.png',
        tags: {'mercadopago'},
      ),
      const PosterTemplate(
        id: 'whatsapp',
        name: 'WhatsApp',
        image: 'assets/templates/whatsapp.png',
        tags: {'whatsapp'},
      ),
      const PosterTemplate(
        id: 'generico',
        name: 'Genérico',
        image: 'assets/templates/whatsapp.png',
        tags: {'whatsapp', 'instagram'},
      ),
    ];
    Future<List<PosterTemplate>> loadFakeCatalog() async => fakeCatalog;
    Future<TemplateFrame> instantFrame(PosterTemplate template) async =>
        const TemplateFrame(left: 0.2, top: 0.3, right: 0.8, bottom: 0.7);

    const expectedNames = {
      QrLabelType.googleReviews: ['Google Reseñas'],
      QrLabelType.instagram: ['Instagram', 'Genérico'],
      QrLabelType.mercadoPago: ['Mercado Pago'],
      QrLabelType.whatsapp: ['WhatsApp', 'Genérico'],
    };

    for (final type in QrLabelType.values) {
      testWidgets(
        'con un QR de ${type.name} solo aparecen los templates de ${expectedNames[type]}',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: LabelPreviewScreen(
                type: type,
                qrData: 'contenido de prueba',
                renderer: const _FakeRenderer(),
                loadTemplateCatalog: loadFakeCatalog,
                templateFrameResolver: instantFrame,
              ),
            ),
          );
          await tester.pumpAndSettle();

          final selector = tester.widget<TemplateSelector>(
            find.byType(TemplateSelector),
          );
          expect(
            selector.templates.map((t) => t.name).toList(),
            expectedNames[type],
          );

          final allOtherNames = fakeCatalog
              .map((t) => t.name)
              .where((name) => !expectedNames[type]!.contains(name));
          for (final otherName in allOtherNames) {
            expect(find.text(otherName), findsNothing);
          }
        },
      );
    }

    for (final type in QrLabelType.values) {
      testWidgets(
        'para ${type.name} no hay TextField y están los tres botones de acción',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(400, 2200));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await tester.pumpWidget(
            MaterialApp(
              home: LabelPreviewScreen(
                type: type,
                qrData: 'contenido de prueba',
                renderer: const _FakeRenderer(),
                loadTemplateCatalog: loadFakeCatalog,
                templateFrameResolver: instantFrame,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(TextField), findsNothing);
          expect(
            find.widgetWithText(FilledButton, 'Guardar imagen'),
            findsOneWidget,
          );
          expect(
            find.widgetWithText(
              OutlinedButton,
              type == QrLabelType.mercadoPago
                  ? 'Copiar contenido'
                  : 'Copiar link',
            ),
            findsOneWidget,
          );
          expect(
            find.widgetWithText(TextButton, 'Cómo imprimir con WePrint'),
            findsOneWidget,
          );
        },
      );
    }

    testWidgets('elige el primer template que aplica por defecto', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LabelPreviewScreen(
            type: QrLabelType.whatsapp,
            qrData: 'https://wa.me/5491122334455',
            renderer: const _FakeRenderer(),
            loadTemplateCatalog: loadFakeCatalog,
            templateFrameResolver: instantFrame,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final posterView = tester.widget<PosterTemplateView>(
        find.byType(PosterTemplateView),
      );
      expect(posterView.template.id, 'whatsapp');
    });

    testWidgets('el botón de pantalla completa abre y se puede cerrar', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LabelPreviewScreen(
            type: QrLabelType.whatsapp,
            qrData: 'https://wa.me/5491122334455',
            renderer: const _FakeRenderer(),
            loadTemplateCatalog: loadFakeCatalog,
            templateFrameResolver: instantFrame,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Ver en pantalla completa'),
        200,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('appScreenScrollView')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver en pantalla completa'));
      await tester.pumpAndSettle();

      expect(find.byType(PosterFullscreenScreen), findsOneWidget);

      await tester.tap(find.byTooltip('Cerrar'));
      await tester.pumpAndSettle();

      expect(find.byType(PosterFullscreenScreen), findsNothing);
      expect(find.byType(LabelPreviewScreen), findsOneWidget);
    });
  });
}
