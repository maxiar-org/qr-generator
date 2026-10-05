import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'label_exporter.dart';

LabelExporter createLabelExporter() => _WebLabelExporter();

class _WebLabelExporter implements LabelExporter {
  @override
  Future<SaveResult> saveImage(Uint8List bytes) async {
    final file = web.File(
      [bytes.toJS].toJS,
      'etiqueta-qr.png',
      web.FilePropertyBag(type: 'image/png'),
    );
    final data = web.ShareData(files: [file].toJS);
    try {
      if (web.window.isSecureContext && web.window.navigator.canShare(data)) {
        // No async rendering here: Safari requires the original tap activation.
        await web.window.navigator.share(data).toDart;
        return SaveResult.shared;
      }
    } catch (error) {
      if (error.isA<web.DOMException>() &&
          (error as web.DOMException).name == 'AbortError') {
        return SaveResult.cancelled;
      }
      // Unsupported sharing or a rejected request falls back to a download.
    }
    final url = web.URL.createObjectURL(file);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = 'etiqueta-qr.png';
    web.document.body!.appendChild(anchor);
    anchor.click();
    anchor.remove();
    // Give Safari time to start consuming the blob before releasing it.
    Timer(const Duration(minutes: 1), () => web.URL.revokeObjectURL(url));
    return SaveResult.downloaded;
  }

  @override
  Future<bool> copyLink(String url) async {
    try {
      if (!web.window.isSecureContext) return false;
      await web.window.navigator.clipboard.writeText(url).toDart;
      return true;
    } catch (_) {
      return false;
    }
  }
}
