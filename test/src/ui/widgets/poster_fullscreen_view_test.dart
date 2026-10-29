import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_generator/src/domain/poster_template.dart';
import 'package:qr_generator/src/ui/widgets/poster_fullscreen_view.dart';

const _template = PosterTemplate(
  id: 'whatsapp',
  name: 'WhatsApp',
  image: 'assets/templates/whatsapp.png',
  tags: {'whatsapp'},
);

const _frame = TemplateFrame(left: 0.2, top: 0.3, right: 0.8, bottom: 0.7);

Future<void> _pumpFullscreen(WidgetTester tester) => tester.pumpWidget(
  MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PosterFullscreenScreen(
                  template: _template,
                  qrData: 'https://wa.me/5491122334455',
                  templateFrameResolver: (_) async => _frame,
                ),
              ),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('muestra el cartel y el QR ocupando toda la pantalla', (
    tester,
  ) async {
    await _pumpFullscreen(tester);
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.byType(PosterFullscreenScreen), findsOneWidget);
    expect(find.image(AssetImage(_template.image)), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
  });

  testWidgets('se cierra tocando la pantalla', (tester) async {
    await _pumpFullscreen(tester);
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byType(PosterFullscreenScreen), findsNothing);
  });

  testWidgets('se cierra con el botón visible', (tester) async {
    await _pumpFullscreen(tester);
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Cerrar'), findsOneWidget);
    await tester.tap(find.byTooltip('Cerrar'));
    await tester.pumpAndSettle();

    expect(find.byType(PosterFullscreenScreen), findsNothing);
  });
}
