import 'dart:typed_data';
import 'dart:ui' as ui;

import 'poster_template.dart';

/// Calcula el [TemplateFrame] de un template cuya imagen no trae uno
/// explícito: decodifica el PNG y devuelve el rectángulo que encierra todos
/// los píxeles con alfa 0, en coordenadas relativas a su ancho y alto.
///
/// Asume el mismo contrato que valida `scripts/templates_transparent.py`
/// sobre los templates de `assets/templates/`: un único hueco rectangular,
/// sin transparencia parcial, rodeado de píxeles opacos.
Future<TemplateFrame> detectTransparentFrame(Uint8List pngBytes) async {
  final codec = await ui.instantiateImageCodec(pngBytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;
  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final pixels = byteData!.buffer.asUint8List();
  final width = image.width;
  final height = image.height;

  var left = width;
  var top = height;
  var right = -1;
  var bottom = -1;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final alpha = pixels[(y * width + x) * 4 + 3];
      if (alpha != 0) continue;
      if (x < left) left = x;
      if (x > right) right = x;
      if (y < top) top = y;
      if (y > bottom) bottom = y;
    }
  }

  if (right < left || bottom < top) {
    throw StateError('La imagen no tiene ningún recuadro transparente');
  }

  return TemplateFrame(
    left: left / width,
    top: top / height,
    right: (right + 1) / width,
    bottom: (bottom + 1) / height,
  );
}
