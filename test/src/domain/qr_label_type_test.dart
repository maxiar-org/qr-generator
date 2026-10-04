import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/domain/qr_label_type.dart';

void main() {
  test('every type has a non-empty display name and default text', () {
    for (final type in QrLabelType.values) {
      expect(type.displayName, isNotEmpty);
      expect(type.defaultText, isNotEmpty);
    }
  });

  test('google reviews defaults to the text from the issue', () {
    expect(QrLabelType.googleReviews.defaultText, '¡Dejanos tu reseña!');
  });

  test('each type has distinct default text', () {
    final texts = QrLabelType.values.map((type) => type.defaultText).toSet();
    expect(texts, hasLength(QrLabelType.values.length));
  });
}
