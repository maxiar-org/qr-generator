import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/label_size.dart';
import '../domain/poster_template.dart';
import '../domain/qr_label_type.dart';
import '../printing/label_image_renderer.dart';
import '../export/label_exporter.dart';
import 'export_actions.dart';
import 'theme/app_theme.dart';
import 'widgets/app_screen.dart';
import 'widgets/poster_fullscreen_view.dart';
import 'widgets/poster_template_view.dart';
import 'widgets/template_selector.dart';

/// El catálogo no cambia durante la vida de la app: se carga una sola vez y
/// se reutiliza en cada pantalla, en vez de releer y reparsear el JSON cada
/// vez que el comercio abre una previsualización.
Future<List<PosterTemplate>>? _bundledTemplateCatalog;

Future<List<PosterTemplate>> _loadBundledTemplateCatalog() =>
    _bundledTemplateCatalog ??= loadPosterTemplateCatalog(
      loadString: rootBundle.loadString,
    );

/// Vista previa de la etiqueta a imprimir para un [QrLabelType], con el
/// cartel de cartelería real que le corresponde y texto editable.
class LabelPreviewScreen extends StatefulWidget {
  const LabelPreviewScreen({
    super.key,
    required this.type,
    required this.qrData,
    this.renderer,
    this.loadTemplateCatalog,
    this.templateFrameResolver = resolveTemplateFrame,
  });

  final QrLabelType type;
  final String qrData;

  /// Permite reemplazar el renderer en los tests por uno sin dependencias
  /// del motor gráfico real.
  final LabelImageRenderer? renderer;

  /// Permite reemplazar la carga del catálogo de templates en los tests,
  /// sin depender de `rootBundle`.
  final Future<List<PosterTemplate>> Function()? loadTemplateCatalog;

  /// Permite reemplazar la resolución del recuadro de cada template en los
  /// tests por una síncrona, sin depender de decodificar el PNG real.
  final Future<TemplateFrame> Function(PosterTemplate template)
  templateFrameResolver;

  @override
  State<LabelPreviewScreen> createState() => _LabelPreviewScreenState();
}

class _LabelPreviewScreenState extends State<LabelPreviewScreen> {
  late final LabelImageRenderer _renderer;
  late final LabelExporter _exporter;
  late final TextEditingController _textController;
  late Future<Uint8List> _imageFuture;
  late final Future<List<PosterTemplate>> _templatesFuture;
  PosterTemplate? _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _exporter = LabelExporter();
    _renderer = widget.renderer ?? const LabelImageRenderer();
    _textController = TextEditingController(text: widget.type.defaultText);
    _imageFuture = _render();
    _templatesFuture = (widget.loadTemplateCatalog ?? _loadBundledTemplateCatalog)()
        .then((all) => templatesForType(all, widget.type))
        .then((filtered) {
          if (mounted && filtered.isNotEmpty) {
            setState(() => _selectedTemplate = filtered.first);
          }
          return filtered;
        });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<Uint8List> _render() => _renderer.render(
    qrData: widget.qrData,
    type: widget.type,
    text: _textController.text,
  );

  void _refresh() => setState(() {
    _imageFuture = _render();
  });

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      screenTitle: widget.type.displayName,
      currentType: widget.type,
      children: [
        FutureBuilder<List<PosterTemplate>>(
          future: _templatesFuture,
          builder: (context, snapshot) {
            final templates = snapshot.data ?? const [];
            if (templates.isEmpty) return const SizedBox.shrink();
            final selected = _selectedTemplate ?? templates.first;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Así queda en el cartel',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                TemplateSelector(
                  templates: templates,
                  selected: selected,
                  onSelected: (template) =>
                      setState(() => _selectedTemplate = template),
                ),
                const SizedBox(height: AppSpacing.md),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: PosterTemplateView(
                    template: selected,
                    qrData: widget.qrData,
                    frameResolver: widget.templateFrameResolver,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        fullscreenDialog: true,
                        builder: (_) => PosterFullscreenScreen(
                          template: selected,
                          qrData: widget.qrData,
                          templateFrameResolver: widget.templateFrameResolver,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.fullscreen),
                    label: const Text('Ver en pantalla completa'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            );
          },
        ),
        TextField(
          controller: _textController,
          decoration: const InputDecoration(labelText: 'Texto de la etiqueta'),
          onChanged: (_) => _refresh(),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '$labelPixelSize x $labelPixelSize px',
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
                  isPaymentPayload: widget.type == QrLabelType.mercadoPago,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
