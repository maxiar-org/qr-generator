import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../export/label_exporter.dart';
import 'weprint_help_screen.dart';

class ExportActions extends StatefulWidget {
  const ExportActions({
    super.key,
    required this.bytes,
    required this.url,
    required this.exporter,
  });

  final Uint8List? bytes;
  final String url;
  final LabelExporter exporter;

  @override
  State<ExportActions> createState() => _ExportActionsState();
}

class _ExportActionsState extends State<ExportActions> {
  bool _saving = false;
  bool _showLink = false;
  String? _message;

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      final result = await widget.exporter.saveImage(widget.bytes!);
      if (!mounted) return;
      setState(
        () => _message = switch (result) {
          SaveResult.shared =>
            'Elegí Guardar imagen para llevar el PNG a Fotos.',
          SaveResult.downloaded =>
            'Abrí el PNG en Descargas de Safari y tocá '
                'Compartir → Guardar imagen para llevarlo a Fotos.',
          SaveResult.cancelled => null,
        },
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => _message =
              'No se pudo guardar la imagen. Probá de nuevo desde Safari.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _copy() async {
    final copied = await widget.exporter.copyLink(widget.url);
    if (!mounted) return;
    setState(() {
      _showLink = !copied;
      _message = copied
          ? 'Link copiado'
          : 'Mantené presionado el link para seleccionarlo y copiarlo.';
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FilledButton.icon(
        onPressed: widget.bytes == null || _saving ? null : _save,
        icon: const Icon(Icons.save_alt),
        label: const Text('Guardar imagen'),
      ),
      OutlinedButton.icon(
        onPressed: _copy,
        icon: const Icon(Icons.copy),
        label: const Text('Copiar link'),
      ),
      if (_message != null) Text(_message!, semanticsLabel: _message),
      if (_showLink) SelectableText(widget.url),
      TextButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const WePrintHelpScreen()),
        ),
        child: const Text('Cómo imprimir con WePrint'),
      ),
    ],
  );
}
