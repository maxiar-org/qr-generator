import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Logo + nombre de la app, usado como título de marca constante en la
/// cabecera de `AppScreen` y en el encabezado del menú lateral.
class AppBrandTitle extends StatelessWidget {
  const AppBrandTitle({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      AppLogo(size: 24),
      SizedBox(width: AppSpacing.sm),
      Flexible(
        child: Text('Generador de QR', overflow: TextOverflow.ellipsis),
      ),
    ],
  );
}

/// Marca de la app: tres módulos cuadrados y una etiqueta diagonal, dibujada
/// con la misma geometría que `assets/branding/logo.svg` (viewBox 64x64),
/// sin depender de un paquete de SVG ni de assets rasterizados.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 28, this.color = AppColors.sello});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Generador de QR',
    image: true,
    child: SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: AppLogoPainter(color: color)),
    ),
  );
}

/// Replica `assets/branding/logo.svg`: tres `rect` de 22x22 (radio 3) en las
/// esquinas superior izquierda, superior derecha e inferior izquierda de un
/// viewBox de 64x64, más un `rect` de 26x12 (radio 2) rotado -45° como
/// etiqueta diagonal.
class AppLogoPainter extends CustomPainter {
  const AppLogoPainter({required this.color});

  final Color color;

  static const _viewBoxSize = 64.0;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewBoxSize;
    canvas.save();
    canvas.scale(scale);
    final paint = Paint()..color = color;

    void square(double x, double y) => canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, 22, 22),
        const Radius.circular(3),
      ),
      paint,
    );

    square(8, 8);
    square(34, 8);
    square(8, 34);

    canvas.save();
    canvas.translate(45, 45);
    canvas.rotate(-45 * 3.1415926535897932 / 180);
    canvas.translate(-45, -45);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(32, 39, 26, 12),
        const Radius.circular(2),
      ),
      paint,
    );
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(AppLogoPainter oldDelegate) => oldDelegate.color != color;
}
