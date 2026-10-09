import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../domain/business_place.dart';

Future<BusinessLocation> locateBusiness() {
  final result = Completer<BusinessLocation>();
  web.window.navigator.geolocation.getCurrentPosition(
    ((web.GeolocationPosition position) {
      result.complete(
        BusinessLocation(position.coords.latitude, position.coords.longitude),
      );
    }).toJS,
    ((web.GeolocationPositionError error) {
      result.completeError(StateError('No se pudo obtener la ubicación'));
    }).toJS,
    web.PositionOptions(
      enableHighAccuracy: true,
      timeout: 10000,
      maximumAge: 0,
    ),
  );
  return result.future.timeout(const Duration(seconds: 12));
}
