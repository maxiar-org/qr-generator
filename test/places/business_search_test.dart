import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qr_generator/src/places/places_client.dart';
import 'package:qr_generator/src/ui/business_search.dart';

void main() {
  testWidgets(
    'denied location allows text search and unavailable API explains manual fallback',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BusinessSearch(
              client: PlacesClient(
                client: MockClient((request) async {
                  calls++;
                  expect(request.url.path, '/api/places/search');
                  return http.Response('{}', 503);
                }),
              ),
              locate: () async => throw StateError('denied'),
              onSelected: (_) => fail('Must not select a business'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Buscar cerca mío'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('No pudimos obtener tu ubicación'),
        findsOneWidget,
      );
      expect(calls, 0);
      await tester.tap(find.text('Buscar por nombre'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Café Buenos Aires');
      await tester.tap(find.text('Buscar negocio'));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(
        find.textContaining('La búsqueda automática no está disponible'),
        findsOneWidget,
      );
    },
  );

  testWidgets('selects the correct business from simulated nearby API', (
    tester,
  ) async {
    BusinessPlace? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BusinessSearch(
            client: PlacesClient(
              client: MockClient(
                (_) async => http.Response(
                  '{"places":[{"id":"ChIJ_first","displayName":{"text":"Otro café"},"formattedAddress":"Calle 1"},{"id":"ChIJ_selected","displayName":{"text":"Mi café"},"formattedAddress":"Calle 2"}]}',
                  200,
                ),
              ),
            ),
            locate: () async => const BusinessLocation(-34.6, -58.4),
            onSelected: (place) => selected = place,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Buscar cerca mío'));
    await tester.pumpAndSettle();
    expect(find.text('Calle 2'), findsOneWidget);
    await tester.tap(find.text('Mi café'));
    expect(
      selected!.reviewUrl,
      'https://search.google.com/local/writereview?placeid=ChIJ_selected',
    );
  });
}
