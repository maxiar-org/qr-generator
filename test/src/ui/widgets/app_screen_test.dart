import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/domain/qr_label_type.dart';
import 'package:qr_generator/src/ui/widgets/app_drawer.dart';
import 'package:qr_generator/src/ui/widgets/app_logo.dart';
import 'package:qr_generator/src/ui/widgets/app_screen.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    String? screenTitle,
    QrLabelType? currentType,
    bool pushed = false,
  }) async {
    final root = AppScreen(
      screenTitle: screenTitle,
      currentType: currentType,
      children: const [Text('contenido')],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: pushed
            ? Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => root),
                      ),
                      child: const Text('ir'),
                    ),
                  ),
                ),
              )
            : root,
      ),
    );
    if (pushed) {
      await tester.tap(find.text('ir'));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('always shows the brand logo and app name in the header', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('Generador de QR'), findsOneWidget);
  });

  testWidgets('shows the screen title as a body headline when provided', (
    tester,
  ) async {
    await pumpScreen(tester, screenTitle: 'WhatsApp');
    expect(find.text('WhatsApp'), findsOneWidget);
  });

  testWidgets('has no back action at the root of the navigation stack', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.byTooltip('Back'), findsNothing);
  });

  testWidgets('shows a back action when it can pop', (tester) async {
    await pumpScreen(tester, pushed: true);
    expect(find.byTooltip('Back'), findsOneWidget);
  });

  testWidgets('opens a drawer with the four QR types from the menu button', (
    tester,
  ) async {
    await pumpScreen(tester, currentType: QrLabelType.whatsapp);
    expect(find.byType(AppDrawer), findsNothing);
    await tester.tap(find.byTooltip('Menú de tipos de QR'));
    await tester.pumpAndSettle();
    expect(find.byType(AppDrawer), findsOneWidget);
    for (final type in QrLabelType.values) {
      expect(find.text(type.displayName), findsOneWidget);
    }
  });
}
