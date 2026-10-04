import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

import '../domain/print_variant.dart';
import '../domain/qr_label_type.dart';
import 'label_icons.dart';

/// Genera el PNG en blanco y negro que se imprime en la DT01: QR, ícono del
/// tipo y un texto corto, con el tamaño exacto de la [PrintVariant] elegida.
class LabelImageRenderer {
  const LabelImageRenderer();

  Future<Uint8List> render({
    required String qrData,
    required QrLabelType type,
    required PrintVariant variant,
    required String text,
  }) async {
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

    final qrRect = Rect.fromLTWH(
      (width - qrSize) / 2,
      margin,
      qrSize,
      qrSize,
    );
    final iconTop = qrRect.bottom + gap;
    final textTop = iconTop + iconHeight + gap;
    final textRect = Rect.fromLTWH(
      margin,
      textTop,
      contentWidth,
      height - textTop - margin,
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = Colors.white,
    );
    _drawQrCode(canvas, qrData, qrRect);
    _drawIcon(canvas, labelIconFor(type), iconTop, iconHeight, width);
    _drawText(canvas, text, textRect);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width, size.height);
    final blackAndWhiteImage = await _toPureBlackAndWhite(image);
    final pngBytes = await blackAndWhiteImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return pngBytes!.buffer.asUint8List();
  }

  void _drawQrCode(Canvas canvas, String data, Rect rect) {
    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.M,
    );
    final qrImage = QrImage(qrCode);
    final cellSize = rect.width / qrImage.moduleCount;
    final darkPaint = Paint()..color = Colors.black;

    for (var row = 0; row < qrImage.moduleCount; row++) {
      for (var col = 0; col < qrImage.moduleCount; col++) {
        if (!qrImage.isDark(row, col)) continue;
        canvas.drawRect(
          Rect.fromLTWH(
            rect.left + col * cellSize,
            rect.top + row * cellSize,
            cellSize,
            cellSize,
          ),
          darkPaint,
        );
      }
    }
  }

  void _drawIcon(
    Canvas canvas,
    IconData icon,
    double top,
    double size,
    double canvasWidth,
  ) {
    final painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.black,
        ),
      ),
    )..layout();
    painter.paint(
      canvas,
      Offset((canvasWidth - painter.width) / 2, top),
    );
  }

  void _drawText(Canvas canvas, String text, Rect rect) {
    final painter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 2,
      ellipsis: '…',
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: rect.height * 0.4,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    )..layout(maxWidth: rect.width);
    painter.paint(
      canvas,
      Offset(rect.left + (rect.width - painter.width) / 2, rect.top),
    );
  }

  Future<ui.Image> _toPureBlackAndWhite(ui.Image image) async {
    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    final pixels = byteData!.buffer.asUint8List();

    for (var i = 0; i < pixels.length; i += 4) {
      final luminance =
          (pixels[i] * 299 + pixels[i + 1] * 587 + pixels[i + 2] * 114) ~/
          1000;
      final value = luminance < 128 ? 0 : 255;
      pixels[i] = value;
      pixels[i + 1] = value;
      pixels[i + 2] = value;
      pixels[i + 3] = 255;
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      image.width,
      image.height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }
}
