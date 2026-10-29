import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/domain/poster_template.dart';
import 'package:qr_generator/src/domain/qr_label_type.dart';

const _catalogJson = '''
[
  {
    "id": "google-resenas",
    "name": "Google Reseñas",
    "image": "assets/templates/google-resenas.png",
    "tags": ["google"]
  },
  {
    "id": "instagram",
    "name": "Instagram",
    "image": "assets/templates/instagram.png",
    "tags": ["instagram", "mostrador"]
  },
  {
    "id": "con-frame",
    "name": "Con recuadro fijo",
    "image": "assets/templates/con-frame.png",
    "tags": ["whatsapp"],
    "frame": [0.1, 0.2, 0.9, 0.8]
  }
]
''';

void main() {
  group('parsePosterTemplateCatalog', () {
    test('parsea id, name, image y tags', () {
      final templates = parsePosterTemplateCatalog(_catalogJson);

      expect(templates, hasLength(3));
      final google = templates.first;
      expect(google.id, 'google-resenas');
      expect(google.name, 'Google Reseñas');
      expect(google.image, 'assets/templates/google-resenas.png');
      expect(google.tags, {'google'});
      expect(google.frame, isNull);
    });

    test('acepta tags adicionales de formato', () {
      final templates = parsePosterTemplateCatalog(_catalogJson);
      final instagram = templates.firstWhere((t) => t.id == 'instagram');
      expect(instagram.tags, {'instagram', 'mostrador'});
    });

    test('parsea el frame explícito en coordenadas relativas', () {
      final templates = parsePosterTemplateCatalog(_catalogJson);
      final withFrame = templates.firstWhere((t) => t.id == 'con-frame');
      expect(
        withFrame.frame,
        const TemplateFrame(left: 0.1, top: 0.2, right: 0.9, bottom: 0.8),
      );
    });
  });

  group('templatesForType', () {
    final templates = parsePosterTemplateCatalog(_catalogJson);

    test('solo devuelve los templates etiquetados con el tipo de QR', () {
      expect(
        templatesForType(templates, QrLabelType.googleReviews).map((t) => t.id),
        ['google-resenas'],
      );
      expect(
        templatesForType(templates, QrLabelType.instagram).map((t) => t.id),
        ['instagram'],
      );
      expect(
        templatesForType(templates, QrLabelType.whatsapp).map((t) => t.id),
        ['con-frame'],
      );
    });

    test('devuelve una lista vacía si ningún template aplica', () {
      expect(templatesForType(templates, QrLabelType.mercadoPago), isEmpty);
    });
  });
}
