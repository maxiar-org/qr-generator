import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:qr/qr.dart';
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
    testWidgets('renders ${variant.name} with its exact size', (tester) async {
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

  testWidgets('only produces pure black or pure white pixels', (tester) async {
    await tester.runAsync(() async {
      final bytes = await renderer.render(
        qrData: QrLabelType.instagram.sampleQrData,
        type: QrLabelType.instagram,
        variant: PrintVariant.sticker,
        text: QrLabelType.instagram.defaultText,
      );

      final image = await _decode(bytes);
      final pixels = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
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

  for (final variant in PrintVariant.values) {
    testWidgets('reserves the QR quiet zone for ${variant.name}', (
      tester,
    ) async {
      const type = QrLabelType.whatsapp;
      final qrData = type.sampleQrData;
      late Uint8List pixels;
      late int imageWidth;
      await tester.runAsync(() async {
        final bytes = await renderer.render(
          qrData: qrData,
          type: type,
          variant: variant,
          text: type.defaultText,
        );
        final image = await _decode(bytes);
        final byteData = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        pixels = byteData!.buffer.asUint8List();
        imageWidth = image.width;
      });

      bool isWhite(int x, int y) {
        final offset = (y * imageWidth + x) * 4;
        return pixels[offset] == 255 &&
            pixels[offset + 1] == 255 &&
            pixels[offset + 2] == 255;
      }

      final size = printVariantSizes[variant]!;
      final width = size.width.toDouble();
      final height = size.height.toDouble();
      final margin = width * 0.06;
      final contentWidth = width - margin * 2;
      final gap = height * 0.03;
      final textHeight = height * 0.12;
      final iconHeight = height * 0.14;
      final qrSize = math.min(
        contentWidth,
        height - textHeight - iconHeight - gap * 2 - margin * 2,
      );
      final qrLeft = (width - qrSize) / 2;

      final qrCode = QrCode.fromData(
        data: qrData,
        errorCorrectLevel: QrErrorCorrectLevel.M,
      );
      final moduleCount = QrImage(qrCode).moduleCount;
      final cellSize = qrSize / (moduleCount + 2 * qrQuietZoneModules);
      // floor (no ceil): el límite real entre la zona blanca y el primer
      // módulo cae en un píxel fraccionario; redondear para arriba pisaría
      // ese módulo por el antialiasing del renderer.
      final quietZonePx = (cellSize * qrQuietZoneModules).floor();

      final left = qrLeft.round();
      final top = margin.round();
      final right = (qrLeft + qrSize).round() - 1;
      final bottom = (margin + qrSize).round() - 1;

      // Recorre los pixeles en Dart puro y recién llama a expect() si
      // encuentra una falla: pasar cientos de miles de chequeos por el
      // framework de matchers uno por uno es demasiado lento.
      String? failure;
      for (var x = left; x <= right && failure == null; x++) {
        for (var dy = 0; dy < quietZonePx; dy++) {
          if (!isWhite(x, top + dy)) {
            failure =
                'pixel ($x, ${top + dy}) no es blanco '
                '(zona de seguridad superior)';
            break;
          }
          if (!isWhite(x, bottom - dy)) {
            failure =
                'pixel ($x, ${bottom - dy}) no es blanco '
                '(zona de seguridad inferior)';
            break;
          }
        }
      }
      for (var y = top; y <= bottom && failure == null; y++) {
        for (var dx = 0; dx < quietZonePx; dx++) {
          if (!isWhite(left + dx, y)) {
            failure =
                'pixel (${left + dx}, $y) no es blanco '
                '(zona de seguridad izquierda)';
            break;
          }
          if (!isWhite(right - dx, y)) {
            failure =
                'pixel (${right - dx}, $y) no es blanco '
                '(zona de seguridad derecha)';
            break;
          }
        }
      }

      expect(failure, isNull);
    });
  }
}
