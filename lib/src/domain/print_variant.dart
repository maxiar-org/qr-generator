/// Ancho y alto inicial (en px) de una [PrintVariant].
class PrintVariantSize {
  const PrintVariantSize({required this.width, required this.height});

  final int width;
  final int height;

  @override
  bool operator ==(Object other) =>
      other is PrintVariantSize &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(width, height);

  @override
  String toString() => 'PrintVariantSize($width x $height)';
}

/// Las tres plantillas impresas sobre las que Maxi pega la etiqueta.
enum PrintVariant { sticker, counterStand, cardHolder }

extension PrintVariantLabel on PrintVariant {
  String get displayName => switch (this) {
    PrintVariant.sticker => 'Adhesivo',
    PrintVariant.counterStand => 'Mostrador',
    PrintVariant.cardHolder => 'Tarjetero',
  };
}

/// Medidas iniciales por variante, en px, a 203 ppp sobre la DT01 (58 mm).
///
/// Eduardo va a confirmar las medidas reales de cada plantilla con Maxi;
/// hasta entonces estos son los únicos valores a cambiar.
const Map<PrintVariant, PrintVariantSize> printVariantSizes = {
  PrintVariant.sticker: PrintVariantSize(width: 464, height: 464),
  PrintVariant.counterStand: PrintVariantSize(width: 464, height: 640),
  PrintVariant.cardHolder: PrintVariantSize(width: 464, height: 560),
};
