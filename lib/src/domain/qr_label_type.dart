/// Tipos de QR que Maxi vende para sus clientes.
enum QrLabelType { whatsapp, instagram, googleReviews, mercadoPago }

extension QrLabelTypeDetails on QrLabelType {
  String get displayName => switch (this) {
    QrLabelType.whatsapp => 'WhatsApp',
    QrLabelType.instagram => 'Instagram',
    QrLabelType.googleReviews => 'Google Reseñas',
    QrLabelType.mercadoPago => 'Mercado Pago',
  };

  /// Texto corto sugerido debajo del QR; el comercio puede editarlo.
  String get defaultText => switch (this) {
    QrLabelType.whatsapp => '¡Escribinos por WhatsApp!',
    QrLabelType.instagram => '¡Seguinos en Instagram!',
    QrLabelType.googleReviews => '¡Dejanos tu reseña!',
    QrLabelType.mercadoPago => '¡Pagá con Mercado Pago!',
  };
}
