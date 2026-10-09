import 'package:flutter/material.dart';

import '../../domain/qr_label_type.dart';
import '../coming_soon_screen.dart';
import '../google_reviews_screen.dart';
import '../instagram_screen.dart';
import '../whatsapp_screen.dart';

/// Pantalla de formulario para cada [QrLabelType], compartida entre la lista
/// de Inicio y el menú lateral para que ambos caminos lleven al mismo lugar.
Widget screenForQrType(QrLabelType type) => switch (type) {
  QrLabelType.googleReviews => const GoogleReviewsScreen(),
  QrLabelType.whatsapp => const WhatsAppScreen(),
  QrLabelType.instagram => const InstagramScreen(),
  _ => ComingSoonScreen(type: type),
};

/// Navega a [type] reemplazando el stack hasta Inicio, para que "Atrás"
/// siempre vuelva ahí sin importar desde qué pantalla se abrió el menú.
void openQrType(BuildContext context, QrLabelType type) {
  Navigator.of(context).pop();
  Navigator.of(context).popUntil((route) => route.isFirst);
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => screenForQrType(type)));
}
