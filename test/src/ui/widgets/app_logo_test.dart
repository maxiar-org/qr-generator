import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/ui/widgets/app_logo.dart';

void main() {
  testWidgets('renders at the requested size with a brand semantics label', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppLogo(size: 28))),
    );
    final renderBox = tester.renderObject<RenderBox>(find.byType(AppLogo));
    expect(renderBox.size, const Size(28, 28));
    expect(find.bySemanticsLabel('Generador de QR'), findsOneWidget);
  });

  testWidgets('repaints only when the color actually changes', (
    tester,
  ) async {
    const painterRed = AppLogoPainter(color: Colors.red);
    const painterRedAgain = AppLogoPainter(color: Colors.red);
    const painterBlue = AppLogoPainter(color: Colors.blue);
    expect(painterRed.shouldRepaint(painterRedAgain), isFalse);
    expect(painterRed.shouldRepaint(painterBlue), isTrue);
  });
}
