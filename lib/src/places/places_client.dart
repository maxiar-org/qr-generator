import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/business_place.dart';
export '../domain/business_place.dart';

class PlacesException implements Exception {
  const PlacesException(this.message);
  final String message;
}

class PlacesClient {
  PlacesClient({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  void close() => _client.close();

  Future<List<BusinessPlace>> nearby(BusinessLocation location) =>
      _request('nearby', {
        'languageCode': 'es',
        'maxResultCount': 20,
        'rankPreference': 'DISTANCE',
        'locationRestriction': {
          'circle': {
            'center': {
              'latitude': location.latitude,
              'longitude': location.longitude,
            },
            'radius': 200.0,
          },
        },
      });

  Future<List<BusinessPlace>> search(String name) {
    if (name.trim().isEmpty) {
      throw const PlacesException(
        'Ingresá el nombre y la localidad del negocio.',
      );
    }
    return _request('search', {
      'textQuery': name.trim(),
      'languageCode': 'es',
      'regionCode': 'AR',
      'pageSize': 20,
    });
  }

  Future<List<BusinessPlace>> _request(
    String endpoint,
    Map<String, Object> body,
  ) async {
    try {
      final response = await _client
          .post(
            Uri.base.resolve('/api/places/$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 503 || response.statusCode == 404) {
        throw const PlacesException(
          'La búsqueda automática no está disponible. Podés pegar el Place ID abajo.',
        );
      }
      if (response.statusCode == 429) {
        throw const PlacesException(
          'Hubo muchas búsquedas. Esperá un minuto y volvé a intentar.',
        );
      }
      if (response.statusCode != 200) throw const FormatException();
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['places'] as List<dynamic>? ?? [])
          .map(
            (item) => BusinessPlace(
              item['id'] as String,
              item['displayName']['text'] as String,
              item['formattedAddress'] as String? ?? 'Dirección no disponible',
            ),
          )
          .toList();
    } on PlacesException {
      rethrow;
    } catch (_) {
      throw const PlacesException(
        'No pudimos buscar negocios. Reintentá o pegá el Place ID abajo.',
      );
    }
  }
}
