import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dothantech_lpapi_thermal_printer/flutter_dothantech_lpapi_thermal_printer.dart';
// This separate spike reuses the exact rasterizer accepted in issue #4.
// ignore: implementation_imports
import 'package:qr_generator/src/domain/print_variant.dart';
// ignore: implementation_imports
import 'package:qr_generator/src/domain/qr_label_type.dart';
// ignore: implementation_imports
import 'package:qr_generator/src/printing/label_image_renderer.dart';

import 'printer_session.dart';

const directPrintEnabled = bool.fromEnvironment('LPAPI_SPIKE');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Platform.isIOS) {
    throw UnsupportedError('Este prototipo requiere un iPhone.');
  }
  runApp(const MaterialApp(home: SpikeScreen()));
}

class SpikeScreen extends StatefulWidget {
  const SpikeScreen({super.key});

  @override
  State<SpikeScreen> createState() => _SpikeScreenState();
}

class _SpikeScreenState extends State<SpikeScreen> {
  final _session = PrinterSession();
  List<PrinterInfo> _printers = [];
  PrinterInfo? _selected;
  Uint8List? _png;
  bool _busy = false;
  bool _failed = false;
  String _status = 'Encendé la DT01 y cerrá WePrint antes de buscar.';

  Future<void> _run(Future<void> Function() operation) async {
    setState(() => _busy = true);
    try {
      await operation();
    } catch (error) {
      // A Dart timeout does not cancel the native operation. Do not retry
      // in the same session: a late callback could complete a newer request.
      if (mounted) {
        _failed = true;
        _status =
            'Error: $error\nCerrá y volvé a abrir la app para reintentar. '
            'Revisá el papel antes de repetir una impresión.';
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _discover() => _run(() async {
    final printers = await _session.discover();
    if (!mounted) return;
    _printers = printers;
    _selected = null;
    _status = printers.isEmpty
        ? 'No encontramos impresoras. Revisá Bluetooth, permisos y WePrint.'
        : 'Elegí la DT01 de Maxi en la lista.';
  });

  Future<void> _print() => _run(() async {
    final selected = _selected!;
    final png = await const LabelImageRenderer().render(
      qrData: 'https://example.com/lpapi-dt01',
      type: QrLabelType.instagram,
      variant: PrintVariant.sticker,
      text: 'Prueba DT01 — 464 px',
    );
    if (!mounted) return;
    setState(() {
      _png = png;
      _status = 'Enviando a ${selected.name}…';
    });
    await _session.printImage(selected.address, png);
    if (!mounted) return;
    _status = 'El SDK confirmó el envío. Revisá la etiqueta y escaneá el QR.';
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba DT01 · iOS')),
      body: !directPrintEnabled
          ? const Center(child: Text('Prototipo desactivado (LPAPI_SPIKE).'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Etiqueta de prueba: 464 × 464 px. QR de ejemplo.'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy || _failed ? null : _discover,
                  child: const Text('Buscar impresoras'),
                ),
                for (final printer in _printers)
                  ListTile(
                    title: Text(printer.name),
                    subtitle: Text(printer.address),
                    selected: identical(printer, _selected),
                    trailing: identical(printer, _selected)
                        ? const Icon(Icons.check)
                        : null,
                    onTap: _busy || _failed
                        ? null
                        : () => setState(() => _selected = printer),
                  ),
                FilledButton(
                  onPressed: _busy || _failed || _selected == null
                      ? null
                      : _print,
                  child: const Text('Imprimir'),
                ),
                if (_busy) const LinearProgressIndicator(),
                const SizedBox(height: 16),
                Text(_status),
                if (_png != null) Image.memory(_png!),
              ],
            ),
    );
  }
}
