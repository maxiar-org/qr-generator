import 'dart:convert';

import 'qr_label_type.dart';

/// Recuadro donde se pega la etiqueta térmica, en coordenadas relativas
/// (0 a 1) al tamaño de la imagen del template.
class TemplateFrame {
  const TemplateFrame({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  factory TemplateFrame.fromRelativeList(List<dynamic> values) {
    if (values.length != 4) {
      throw const FormatException('frame debe tener 4 valores');
    }
    final numbers = values.map((v) => (v as num).toDouble()).toList();
    return TemplateFrame(
      left: numbers[0],
      top: numbers[1],
      right: numbers[2],
      bottom: numbers[3],
    );
  }

  final double left;
  final double top;
  final double right;
  final double bottom;

  @override
  bool operator ==(Object other) =>
      other is TemplateFrame &&
      other.left == left &&
      other.top == top &&
      other.right == right &&
      other.bottom == bottom;

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() => 'TemplateFrame($left, $top, $right, $bottom)';
}

/// Un cartel impreso de `assets/templates/` donde Maxi pega la etiqueta.
class PosterTemplate {
  const PosterTemplate({
    required this.id,
    required this.name,
    required this.image,
    required this.tags,
    this.frame,
  });

  factory PosterTemplate.fromJson(Map<String, dynamic> json) =>
      PosterTemplate(
        id: json['id'] as String,
        name: json['name'] as String,
        image: json['image'] as String,
        tags: Set<String>.from(json['tags'] as List<dynamic>),
        frame: json['frame'] == null
            ? null
            : TemplateFrame.fromRelativeList(json['frame'] as List<dynamic>),
      );

  final String id;
  final String name;
  final String image;

  /// Tipos de QR y, opcionalmente, formatos (adhesivo, mostrador, tarjetero)
  /// a los que aplica este template.
  final Set<String> tags;

  /// `null` cuando el recuadro se detecta solo a partir de la transparencia
  /// del PNG (ver [detectTransparentFrame] en `template_frame_detector.dart`).
  final TemplateFrame? frame;

  bool appliesTo(QrLabelType type) => tags.contains(type.templateTag);
}

/// Parsea el catálogo de `assets/templates/templates.json`.
List<PosterTemplate> parsePosterTemplateCatalog(String source) =>
    (jsonDecode(source) as List<dynamic>)
        .map((entry) => PosterTemplate.fromJson(entry as Map<String, dynamic>))
        .toList();

/// Templates de [templates] que aplican al tipo de QR [type].
List<PosterTemplate> templatesForType(
  List<PosterTemplate> templates,
  QrLabelType type,
) => templates.where((template) => template.appliesTo(type)).toList();
