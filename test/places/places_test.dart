import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qr_generator/src/places/places_client.dart';

void main() {
  test(
    'nearby sends coordinates and parses selection into review link',
    () async {
      final client = PlacesClient(
        client: MockClient((request) async {
          expect(request.url.path, '/api/places/nearby');
          expect(request.body, contains('latitude'));
          expect(request.headers.containsKey('X-Goog-Api-Key'), isFalse);
          return http.Response(
            '{"places":[{"id":"ChIJ_test","displayName":{"text":"Café"},"formattedAddress":"Av. Corrientes 123"}]}',
            200,
          );
        }),
      );
      final places = await client.nearby(const BusinessLocation(-34.6, -58.4));
      expect(places.single.name, 'Café');
      expect(places.single.address, 'Av. Corrientes 123');
      expect(
        places.single.reviewUrl,
        'https://search.google.com/local/writereview?placeid=ChIJ_test',
      );
    },
  );
  test('search trims name and handles empty results', () async {
    final client = PlacesClient(
      client: MockClient((request) async {
        expect(request.url.path, '/api/places/search');
        expect(request.body, contains('"textQuery":"Café Buenos Aires"'));
        return http.Response('{}', 200);
      }),
    );
    expect(await client.search(' Café Buenos Aires '), isEmpty);
  });
  for (final status in [503, 429, 403]) {
    test('API failure $status becomes a usable error', () async {
      final client = PlacesClient(
        client: MockClient((_) async => http.Response('{}', status)),
      );
      expect(client.search('Café'), throwsA(isA<PlacesException>()));
    });
  }
}
