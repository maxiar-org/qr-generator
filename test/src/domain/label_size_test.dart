import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/domain/label_size.dart';

void main() {
  test('la etiqueta impresa usa el ancho útil de 464px de la DT01', () {
    expect(labelPixelSize, 464);
  });
}
