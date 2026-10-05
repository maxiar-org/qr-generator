import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/domain/print_variant.dart';

void main() {
  test('defines the three label variants with their initial size in px', () {
    expect(printVariantSizes.keys.toSet(), PrintVariant.values.toSet());

    expect(
      printVariantSizes[PrintVariant.sticker],
      const PrintVariantSize(width: 464, height: 464),
    );
    expect(
      printVariantSizes[PrintVariant.counterStand],
      const PrintVariantSize(width: 464, height: 640),
    );
    expect(
      printVariantSizes[PrintVariant.cardHolder],
      const PrintVariantSize(width: 464, height: 560),
    );
  });

  test('every variant uses the DT01 useful width of 464px', () {
    for (final size in printVariantSizes.values) {
      expect(size.width, 464);
    }
  });
}
