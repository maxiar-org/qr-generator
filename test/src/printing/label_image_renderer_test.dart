import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/domain/print_variant.dart';
import 'package:qr_generator/src/domain/qr_label_type.dart';
import 'package:qr_generator/src/printing/label_image_renderer.dart';

Future<ui.Image> _decode(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return frame.image;
}

void main() {
  const renderer = LabelImageRenderer();

  for (final variant in PrintVariant.values) {
    testWidgets('renders ${variant.name} with its exact size', (
      tester,
    ) async {
      final size = printVariantSizes[variant]!;
      late Uint8List bytes;
      await tester.runAsync(() async {
        bytes = await renderer.render(
          qrData: QrLabelType.whatsapp.sampleQrData,
          type: QrLabelType.whatsapp,
          variant: variant,
          text: QrLabelType.whatsapp.defaultText,
        );
      });

      final image = await tester.runAsync(() => _decode(bytes));
      expect(image!.width, size.width);
      expect(image.height, size.height);
    });
  }

  testWidgets('only produces pure black or pure white pixels', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final bytes = await renderer.render(
        qrData: QrLabelType.instagram.sampleQrData,
        type: QrLabelType.instagram,
        variant: PrintVariant.sticker,
        text: QrLabelType.instagram.defaultText,
      );

      final image = await _decode(bytes);
      final pixels = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      final data = pixels!.buffer.asUint8List();

      var blackCount = 0;
      var whiteCount = 0;
      for (var i = 0; i < data.length; i += 4) {
        final r = data[i];
        final g = data[i + 1];
        final b = data[i + 2];
        final a = data[i + 3];
        expect(a, 255, reason: 'la imagen no debe tener transparencia');
        final isBlack = r == 0 && g == 0 && b == 0;
        final isWhite = r == 255 && g == 255 && b == 255;
        expect(
          isBlack || isWhite,
          isTrue,
          reason: 'pixel gris encontrado: ($r, $g, $b)',
        );
        if (isBlack) blackCount++;
        if (isWhite) whiteCount++;
      }

      expect(blackCount, greaterThan(0));
      expect(whiteCount, greaterThan(0));
    });
  });
}
