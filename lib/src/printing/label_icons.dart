import 'package:flutter/material.dart';

import '../domain/qr_label_type.dart';

/// Ícono que representa cada tipo de QR en la etiqueta impresa.
IconData labelIconFor(QrLabelType type) => switch (type) {
  QrLabelType.whatsapp => Icons.chat_bubble,
  QrLabelType.instagram => Icons.camera_alt,
  QrLabelType.googleReviews => Icons.star,
  QrLabelType.mercadoPago => Icons.payments,
};
