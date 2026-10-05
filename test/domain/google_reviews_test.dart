import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/domain/google_reviews.dart';

void main() {
  const id = 'ChIJgUbEo8cfqokR5lP9_Wh_DaM';
  const expected = 'https://search.google.com/local/writereview?placeid=$id';

  test('builds a review URL from a trimmed Place ID', () {
    expect(buildGoogleReviewUrl('  $id\n'), expected);
  });

  test('accepts IDs without assuming a prefix or fixed length', () {
    expect(
      buildGoogleReviewUrl('GhIJQWDl0CIeQUARxks3icF8U8A'),
      endsWith('placeid=GhIJQWDl0CIeQUARxks3icF8U8A'),
    );
  });

  test('extracts an explicit Maps Place ID and removes unrelated parameters', () {
    expect(
      buildGoogleReviewUrl(
        'https://www.google.com/maps/search/?api=1&query=Caf%C3%A9&query_place_id=$id',
      ),
      expected,
    );
    expect(buildGoogleReviewUrl('$expected&tracking=123'), expected);
  });

  test('rejects missing IDs, unsupported links and parameter injection', () {
    for (final input in [
      '',
      ' ',
      'Café de Maxi',
      'https://maps.app.goo.gl/abc',
      'https://www.google.com/maps/place/Cafe/data=!1s0x123:0x456',
      'https://www.google.com/maps/?cid=123',
      'https://evil.test/maps/?query_place_id=$id',
      'https://www.google.com.evil.test/maps/?query_place_id=$id',
      'https://www.google.com/maps/?query_place_id=',
      'https://www.google.com/maps/?query_place_id=$id&query_place_id=Other',
      'https://user@www.google.com/maps/?query_place_id=$id',
      'https://www.google.com/other?query_place_id=$id',
      '$id&other=value',
      '0x123:0x456',
      '123456789',
    ]) {
      expect(
        () => buildGoogleReviewUrl(input),
        throwsFormatException,
        reason: input,
      );
    }
  });
}
