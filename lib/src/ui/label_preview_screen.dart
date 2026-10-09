import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../domain/print_variant.dart';
import '../domain/qr_label_type.dart';
import '../printing/label_image_renderer.dart';
import '../export/label_exporter.dart';
import 'export_actions.dart';
import 'theme/app_theme.dart';
import 'widgets/app_screen.dart';

/// Vista previa de la etiqueta a imprimir para un [QrLabelType], con
/// selector de variante y texto editable.
class LabelPreviewScreen extends StatefulWidget {
  const LabelPreviewScreen({
    super.key,
    required this.type,
    required this.qrData,
    this.renderer,
  });

  final QrLabelType type;
  final String qrData;

  /// Permite reemplazar el renderer en los tests por uno sin dependencias
  /// del motor gráfico real.
  final LabelImageRenderer? renderer;

  @override
  State<LabelPreviewScreen> createState() => _LabelPreviewScreenState();
}

class _LabelPreviewScreenState extends State<LabelPreviewScreen> {
  late final LabelImageRenderer _renderer;
  late final LabelExporter _exporter;
  late final TextEditingController _textController;
  PrintVariant _variant = PrintVariant.sticker;
  late Future<Uint8List> _imageFuture;

  @override
  void initState() {
    super.initState();
    _exporter = LabelExporter();
    _renderer = widget.renderer ?? const LabelImageRenderer();
    _textController = TextEditingController(text: widget.type.defaultText);
    _imageFuture = _render();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<Uint8List> _render() => _renderer.render(
    qrData: widget.qrData,
    type: widget.type,
    variant: _variant,
    text: _textController.text,
  );

  void _refresh() => setState(() {
    _imageFuture = _render();
  });

  @override
  Widget build(BuildContext context) {
    final size = printVariantSizes[_variant]!;
    return AppScreen(
      screenTitle: widget.type.displayName,
      currentType: widget.type,
      children: [
        SegmentedButton<PrintVariant>(
          segments: [
            for (final variant in PrintVariant.values)
              ButtonSegment(value: variant, label: Text(variant.displayName)),
          ],
          selected: {_variant},
          onSelectionChanged: (selection) {
            _variant = selection.first;
            _refresh();
          },
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _textController,
          decoration: const InputDecoration(labelText: 'Texto de la etiqueta'),
          onChanged: (_) => _refresh(),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${size.width} x ${size.height} px',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        FutureBuilder<Uint8List>(
          future: _imageFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final bytes = snapshot.data;
            if (bytes == null) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: Text('Generando…')),
              );
            }
            return Column(
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Image.memory(bytes, gaplessPlayback: true),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ExportActions(
                  bytes: snapshot.connectionState == ConnectionState.done
                      ? bytes
                      : null,
                  url: widget.qrData,
                  exporter: _exporter,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
