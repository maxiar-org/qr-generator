import 'google_reviews.dart';

class BusinessLocation {
  const BusinessLocation(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

class BusinessPlace {
  const BusinessPlace(this.id, this.name, this.address);
  final String id;
  final String name;
  final String address;
  String get reviewUrl => buildGoogleReviewUrl(id);
}
