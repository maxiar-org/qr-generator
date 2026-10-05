/// Builds a review link locally. Syntax checks cannot verify that a place exists.
String buildGoogleReviewUrl(String input) {
  const guidance =
      'Pegá el Place ID del comercio obtenido en Place ID Finder '
      'o una URL de Maps con query_place_id. Los links cortos necesitan ese paso manual.';
  var placeId = input.trim();
  final uri = Uri.tryParse(placeId);
  if (uri != null && uri.hasScheme) {
    final isMaps =
        (uri.host == 'www.google.com' || uri.host == 'google.com') &&
        (uri.path == '/maps' || uri.path.startsWith('/maps/'));
    final isReview =
        uri.host == 'search.google.com' && uri.path == '/local/writereview';
    if (uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort ||
        (!isMaps && !isReview)) {
      throw const FormatException(guidance);
    }
    final values =
        uri.queryParametersAll[isMaps ? 'query_place_id' : 'placeid'];
    if (values == null || values.length != 1) {
      throw const FormatException(guidance);
    }
    placeId = values.single;
  }
  // Do not assume the common ChIJ prefix or a fixed length. Reject CIDs and
  // characters that indicate a pasted name, URL, or extra query parameters.
  if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(placeId) ||
      RegExp(r'^\d+$').hasMatch(placeId)) {
    throw const FormatException(guidance);
  }
  return Uri.https('search.google.com', '/local/writereview', {
    'placeid': placeId,
  }).toString();
}
