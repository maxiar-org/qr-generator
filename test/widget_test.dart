import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/domain/qr_label_type.dart';
import 'package:qr_generator/src/ui/app.dart';

void main() {
  testWidgets('shows all QR options and opens their label preview', (
    tester,
  ) async {
    await tester.pumpWidget(const QrGeneratorApp());

    expect(find.text('Generador de QR'), findsOneWidget);
    for (final type in QrLabelType.values) {
      expect(find.text(type.displayName), findsOneWidget);
    }

    for (final type in QrLabelType.values) {
      await tester.tap(find.text(type.displayName));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, type.displayName), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Generador de QR'), findsOneWidget);
    }
  });
}
