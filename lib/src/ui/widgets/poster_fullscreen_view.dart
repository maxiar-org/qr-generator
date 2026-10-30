import 'package:flutter/material.dart';

import '../../domain/poster_template.dart';
import '../theme/app_theme.dart';
import 'poster_template_view.dart';

/// Muestra [template] con el QR de [qrData] ocupando toda la pantalla, para
/// que el comercio lo exhiba desde el celular. Se cierra tocando en
/// cualquier lado o con el botón de cerrar, siempre visible.
class PosterFullscreenScreen extends StatelessWidget {
  const PosterFullscreenScreen({
    super.key,
    required this.template,
    required this.qrData,
    this.templateFrameResolver = resolveTemplateFrame,
  });

  final PosterTemplate template;
  final String qrData;
  final Future<TemplateFrame> Function(PosterTemplate template)
  templateFrameResolver;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.of(context).pop(),
    child: Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: PosterTemplateView(
                template: template,
                qrData: qrData,
                frameResolver: templateFrameResolver,
              ),
            ),
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Cerrar',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
