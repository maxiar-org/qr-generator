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

  /// Dato de ejemplo para previsualizar el QR mientras no exista el flujo
  /// real de cada tipo (ver issues #2, #3, #6 y #7).
  String get sampleQrData => switch (this) {
    QrLabelType.whatsapp => 'https://wa.me/5491122334455',
    QrLabelType.instagram => 'https://instagram.com/tu_negocio',
    QrLabelType.googleReviews => 'https://g.page/r/example/review',
    QrLabelType.mercadoPago => 'https://link.mercadopago.com.ar/example',
  };
}
