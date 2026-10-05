import 'dart:typed_data';

import 'label_exporter_stub.dart'
    if (dart.library.js_interop) 'label_exporter_web.dart'
    as platform;

enum SaveResult { shared, downloaded, cancelled }

abstract interface class LabelExporter {
  factory LabelExporter() => platform.createLabelExporter();

  Future<SaveResult> saveImage(Uint8List bytes);
  Future<bool> copyLink(String url);
}
