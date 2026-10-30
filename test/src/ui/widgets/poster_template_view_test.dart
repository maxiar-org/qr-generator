import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_generator/src/domain/poster_template.dart';
import 'package:qr_generator/src/printing/label_image_renderer.dart'
    show qrQuietZoneModules;
import 'package:qr_generator/src/ui/widgets/poster_template_view.dart';

const _template = PosterTemplate(
  id: 'whatsapp',
  name: 'WhatsApp',
  image: 'assets/templates/whatsapp.png',
  tags: {'whatsapp'},
);

const _frame = TemplateFrame(left: 0.2, top: 0.3, right: 0.8, bottom: 0.7);

void main() {
  Future<void> pumpView(WidgetTester tester, {Size size = const Size(300, 450)}) =>
      tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: size.width,
              child: PosterTemplateView(
                template: _template,
                qrData: 'https://wa.me/5491122334455',
                frameResolver: (_) async => _frame,
              ),
            ),
          ),
        ),
      );

  testWidgets('dibuja el fondo del template y el QR', (tester) async {
    await pumpView(tester);
    await tester.pumpAndSettle();

    expect(find.image(AssetImage(_template.image)), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
  });

  testWidgets('centra y escala el QR dentro del recuadro del template', (
    tester,
  ) async {
    await pumpView(tester);
    await tester.pumpAndSettle();

    final viewRect = tester.getRect(find.byType(PosterTemplateView));
    final qrRect = tester.getRect(find.byType(QrImageView));

    final expectedFrameWidth = (_frame.right - _frame.left) * viewRect.width;
    final expectedFrameHeight = (_frame.bottom - _frame.top) * viewRect.height;
    final expectedSize = expectedFrameWidth < expectedFrameHeight
        ? expectedFrameWidth
        : expectedFrameHeight;
    final expectedCenterX =
        viewRect.left + (_frame.left + _frame.right) / 2 * viewRect.width;
    final expectedCenterY =
        viewRect.top + (_frame.top + _frame.bottom) / 2 * viewRect.height;

    expect(qrRect.width, closeTo(expectedSize, 0.5));
    expect(qrRect.height, closeTo(expectedSize, 0.5));
    expect(qrRect.center.dx, closeTo(expectedCenterX, 0.5));
    expect(qrRect.center.dy, closeTo(expectedCenterY, 0.5));
  });

  Future<void> expectQuietZoneReserved(
    WidgetTester tester, {
    required String qrData,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 300,
            child: PosterTemplateView(
              template: _template,
              qrData: qrData,
              frameResolver: (_) async => _frame,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final viewRect = tester.getRect(find.byType(PosterTemplateView));
    final qrRect = tester.getRect(find.byType(QrImageView));
    final qrWidget = tester.widget<QrImageView>(find.byType(QrImageView));

    final expectedFrameWidth = (_frame.right - _frame.left) * viewRect.width;
    final expectedFrameHeight = (_frame.bottom - _frame.top) * viewRect.height;
    final qrSize = expectedFrameWidth < expectedFrameHeight
        ? expectedFrameWidth
        : expectedFrameHeight;

    final moduleCount = QrCode.fromData(
      data: qrData,
      errorCorrectLevel: qrWidget.errorCorrectionLevel,
    ).moduleCount;
    final cellSize = qrSize / (moduleCount + 2 * qrQuietZoneModules);
    final expectedQuietZone = cellSize * qrQuietZoneModules;

    // La zona de seguridad se reserva adentro del QrImageView (relleno
    // blanco), no agrandando el recuadro que ocupa en el cartel.
    expect(qrRect.width, closeTo(qrSize, 0.5));
    expect(qrRect.height, closeTo(qrSize, 0.5));
    expect(qrWidget.padding.left, closeTo(expectedQuietZone, 0.5));
    expect(qrWidget.padding.top, closeTo(expectedQuietZone, 0.5));
    expect(qrWidget.padding.right, closeTo(expectedQuietZone, 0.5));
    expect(qrWidget.padding.bottom, closeTo(expectedQuietZone, 0.5));
  }

  testWidgets(
    'reserva la zona de seguridad blanca del QR dentro del recuadro',
    (tester) => expectQuietZoneReserved(
      tester,
      qrData: 'https://wa.me/5491122334455',
    ),
  );

  testWidgets(
    'reserva la zona de seguridad también con QR de muchos módulos '
    '(datos largos, versión alta)',
    (tester) => expectQuietZoneReserved(
      tester,
      qrData: 'https://mpago.la/${'a' * 500}',
    ),
  );

  testWidgets('no dibuja el QR mientras no se resolvió el recuadro', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 300,
            child: PosterTemplateView(
              template: _template,
              qrData: 'https://wa.me/5491122334455',
              frameResolver: (_) => Completer<TemplateFrame>().future,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(QrImageView), findsNothing);
  });
}
