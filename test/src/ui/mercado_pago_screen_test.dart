import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/ui/mercado_pago_screen.dart';
import 'package:qr_generator/src/ui/label_preview_screen.dart';

import '../../widget_test.dart' show expectPrintedUrl;

void main() {
  testWidgets('photo capture requires confirmation and prints exact content', (
    tester,
  ) async {
    const data = 'https://mpago.la/pos/demo';
    await tester.pumpWidget(
      MaterialApp(home: MercadoPagoScreen(capture: (_) async => data)),
    );
    await tester.tap(find.text('Subir foto del QR'));
    await tester.pumpAndSettle();
    expect(find.text(data), findsOneWidget);
    expect(find.byType(LabelPreviewScreen), findsNothing);
    await tester.tap(find.text('Confirmar y ver etiqueta'));
    await tester.pumpAndSettle();
    await expectPrintedUrl(tester, data);
  });
  testWidgets('unknown code warns and cannot proceed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MercadoPagoScreen(capture: (_) async => 'https://example.com'),
      ),
    );
    await tester.tap(find.text('Escanear QR del comercio'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No reconocemos'), findsOneWidget);
    expect(find.text('Confirmar y ver etiqueta'), findsNothing);
  });
  testWidgets('cancel and camera error allow retry', (tester) async {
    var count = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: MercadoPagoScreen(
          capture: (_) async {
            if (count++ == 0) return null;
            throw const FormatException(
              'No pudimos abrir la cámara. Subí una foto.',
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Escanear QR del comercio'));
    await tester.pumpAndSettle();
    expect(find.text('Confirmar y ver etiqueta'), findsNothing);
    await tester.tap(find.text('Escanear QR del comercio'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No pudimos abrir'), findsOneWidget);
  });
}
