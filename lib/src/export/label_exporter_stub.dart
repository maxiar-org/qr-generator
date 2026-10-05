import 'package:flutter/services.dart';

import 'label_exporter.dart';

LabelExporter createLabelExporter() => _NativeLabelExporter();

class _NativeLabelExporter implements LabelExporter {
  @override
  Future<SaveResult> saveImage(Uint8List bytes) async {
    throw UnsupportedError(
      'El guardado de imágenes está disponible en la web.',
    );
  }

  @override
  Future<bool> copyLink(String url) async {
    try {
      await Clipboard.setData(ClipboardData(text: url));
      return true;
    } catch (_) {
      return false;
    }
  }
}
