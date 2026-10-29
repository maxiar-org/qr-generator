import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../domain/poster_template.dart';
import '../../domain/template_frame_detector.dart';
import '../../printing/label_image_renderer.dart' show qrQuietZoneModules;

/// Resuelve el [TemplateFrame] de [template]: el explícito si lo trae, o el
/// detectado a partir de la transparencia de su PNG si no.
Future<TemplateFrame> resolveTemplateFrame(PosterTemplate template) async {
  final explicitFrame = template.frame;
  if (explicitFrame != null) return explicitFrame;
  final data = await rootBundle.load(template.image);
  return detectTransparentFrame(data.buffer.asUint8List());
}

/// Dibuja el cartel [template] con el QR de [qrData] centrado y escalado
/// dentro de su recuadro, para mostrarle al cliente cómo queda impreso.
class PosterTemplateView extends StatefulWidget {
  const PosterTemplateView({
    super.key,
    required this.template,
    required this.qrData,
    this.frameResolver = resolveTemplateFrame,
  });

  final PosterTemplate template;
  final String qrData;

  /// Permite reemplazar la resolución del recuadro en los tests por una
  /// síncrona, sin depender de decodificar el PNG real.
  final Future<TemplateFrame> Function(PosterTemplate template) frameResolver;

  @override
  State<PosterTemplateView> createState() => _PosterTemplateViewState();
}

class _PosterTemplateViewState extends State<PosterTemplateView> {
  late Future<TemplateFrame> _frameFuture;

  @override
  void initState() {
    super.initState();
    _frameFuture = widget.frameResolver(widget.template);
  }

  @override
  void didUpdateWidget(covariant PosterTemplateView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.template.id != widget.template.id) {
      _frameFuture = widget.frameResolver(widget.template);
    }
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 2 / 3,
    child: FutureBuilder<TemplateFrame>(
      future: _frameFuture,
      builder: (context, snapshot) => LayoutBuilder(
        builder: (context, constraints) {
          final frame = snapshot.data;
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(widget.template.image, fit: BoxFit.fill),
              ),
              if (frame != null)
                ..._buildQr(frame, constraints.maxWidth, constraints.maxHeight),
            ],
          );
        },
      ),
    ),
  );

  List<Widget> _buildQr(TemplateFrame frame, double width, double height) {
    final frameLeft = frame.left * width;
    final frameTop = frame.top * height;
    final frameWidth = (frame.right - frame.left) * width;
    final frameHeight = (frame.bottom - frame.top) * height;
    final qrSize = math.min(frameWidth, frameHeight);
    return [
      Positioned(
        left: frameLeft + (frameWidth - qrSize) / 2,
        top: frameTop + (frameHeight - qrSize) / 2,
        width: qrSize,
        height: qrSize,
        child: QrImageView(
          data: widget.qrData,
          size: qrSize,
          backgroundColor: Colors.white,
          padding: EdgeInsets.all(_quietZonePadding(qrSize)),
        ),
      ),
    ];
  }

  /// Ancho en píxeles de la zona de seguridad blanca que hay que reservar
  /// adentro del recuadro del QR, equivalente a [qrQuietZoneModules]
  /// módulos: la misma zona mínima que reserva el renderer de la etiqueta
  /// impresa. `QrImageView` dibuja sus módulos hasta el borde del `size`
  /// que se le pasa, así que sin este relleno el patrón queda pegado al
  /// marco del template.
  double _quietZonePadding(double qrSize) {
    final moduleCount = QrCode.fromData(
      data: widget.qrData,
      errorCorrectLevel: QrErrorCorrectLevel.L,
    ).moduleCount;
    final cellSize = qrSize / (moduleCount + 2 * qrQuietZoneModules);
    return cellSize * qrQuietZoneModules;
  }
}
