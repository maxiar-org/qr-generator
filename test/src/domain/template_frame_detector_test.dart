import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/domain/poster_template.dart';
import 'package:qr_generator/src/domain/template_frame_detector.dart';

/// Genera un PNG opaco de [width]x[height] con un único recuadro
/// transparente (alfa 0) en los límites de píxel exactos de [hole],
/// igual que los templates reales de `assets/templates/`.
Future<Uint8List> _pngWithHole(int width, int height, ui.Rect hole) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(
    recorder,
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
  );
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    ui.Paint()
      ..color = const ui.Color(0xFF123456)
      ..isAntiAlias = false,
  );
  canvas.drawRect(
    hole,
    ui.Paint()
      ..blendMode = ui.BlendMode.clear
      ..isAntiAlias = false,
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

void main() {
  test('detecta el recuadro transparente como coordenadas relativas', () async {
    final png = await _pngWithHole(
      100,
      150,
      const ui.Rect.fromLTRB(20, 30, 80, 120),
    );

    final frame = await detectTransparentFrame(png);

    expect(
      frame,
      const TemplateFrame(left: 0.2, top: 0.2, right: 0.8, bottom: 0.8),
    );
  });

  test('tira un error si no hay ningún recuadro transparente', () async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 10, 10));
    canvas.drawRect(
      const ui.Rect.fromLTWH(0, 0, 10, 10),
      ui.Paint()..color = const ui.Color(0xFF000000),
    );
    final image = await recorder.endRecording().toImage(10, 10);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    expect(
      () => detectTransparentFrame(bytes!.buffer.asUint8List()),
      throwsStateError,
    );
  });
}
