import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/domain/poster_template.dart';
import 'package:qr_generator/src/ui/widgets/template_selector.dart';

const _templates = [
  PosterTemplate(
    id: 'google-resenas',
    name: 'Google Reseñas',
    image: 'assets/templates/google-resenas.png',
    tags: {'google'},
  ),
  PosterTemplate(
    id: 'instagram',
    name: 'Instagram',
    image: 'assets/templates/instagram.png',
    tags: {'instagram'},
  ),
];

void main() {
  testWidgets('muestra una miniatura por template con su nombre', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TemplateSelector(
            templates: _templates,
            selected: _templates.first,
            onSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Google Reseñas'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.image(const AssetImage('assets/templates/instagram.png')),
        findsOneWidget);
  });

  testWidgets('avisa cuál se tocó', (tester) async {
    PosterTemplate? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TemplateSelector(
            templates: _templates,
            selected: _templates.first,
            onSelected: (template) => tapped = template,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Instagram'));
    await tester.pumpAndSettle();

    expect(tapped?.id, 'instagram');
  });
}
