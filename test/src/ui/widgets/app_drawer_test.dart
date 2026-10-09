import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/ui/widgets/app_drawer.dart';
import 'package:qr_generator/src/ui/whatsapp_screen.dart';
import 'package:qr_generator/src/ui/instagram_screen.dart';

void main() {
  testWidgets('selecting a type from the drawer replaces the stack with it', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const WhatsAppScreen()),
                ),
                child: const Text('ir a WhatsApp'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ir a WhatsApp'));
    await tester.pumpAndSettle();
    expect(find.byType(WhatsAppScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Menú de tipos de QR'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Instagram'));
    await tester.pumpAndSettle();

    expect(find.byType(InstagramScreen), findsOneWidget);
    expect(find.byType(WhatsAppScreen), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(InstagramScreen), findsNothing);
    expect(find.byType(WhatsAppScreen), findsNothing);
  });

  testWidgets('tapping the current type just closes the drawer', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: WhatsAppScreen()),
    );
    await tester.tap(find.byTooltip('Menú de tipos de QR'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AppDrawer),
        matching: find.text('WhatsApp'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AppDrawer), findsNothing);
    expect(find.byType(WhatsAppScreen), findsOneWidget);
  });

  testWidgets('marks the current type as selected for screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(home: WhatsAppScreen()));
    await tester.tap(find.byTooltip('Menú de tipos de QR'));
    await tester.pumpAndSettle();

    SemanticsNode tileFor(String label) => tester.getSemantics(
      find.ancestor(
        of: find.descendant(
          of: find.byType(AppDrawer),
          matching: find.text(label),
        ),
        matching: find.byType(ListTile),
      ),
    );

    expect(
      tileFor('WhatsApp').getSemanticsData().flagsCollection.isSelected,
      Tristate.isTrue,
      reason: 'WhatsApp es la pantalla actual: debe anunciarse seleccionado',
    );
    expect(
      tileFor('Instagram').getSemanticsData().flagsCollection.isSelected,
      Tristate.isFalse,
    );

    handle.dispose();
  });
}
