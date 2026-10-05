import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dothantech_lpapi_thermal_printer/flutter_dothantech_lpapi_thermal_printer.dart';

/// One foreground operation at a time; the screen prevents concurrent requests.
class PrinterSession {
  final _printer = LpapiThermalPrinter();
  static const _timeout = Duration(seconds: 30);

  Future<List<PrinterInfo>> discover() =>
      _printer.discoverPrinters().timeout(_timeout);

  Future<void> printImage(String address, Uint8List png) async {
    var operationFailed = false;
    try {
      if (!await _printer.connectPrinter(address).timeout(_timeout)) {
        throw StateError('No se pudo conectar con la impresora.');
      }
      if (!await _printer.printImage(base64Encode(png)).timeout(_timeout)) {
        throw StateError('La impresora rechazó la imagen.');
      }
    } catch (_) {
      operationFailed = true;
      rethrow;
    } finally {
      try {
        await _printer.disconnectPrinter().timeout(_timeout);
      } catch (_) {
        // Preserve the original operation error and its stack trace.
        if (!operationFailed) rethrow;
      }
    }
  }
}
