/// Converts a username or Instagram profile URL to a canonical profile URL.
/// Throws [FormatException] when the input is not a valid profile reference.
String normalizeInstagramProfile(String input) {
  var username = input.trim();
  if (username.startsWith('@')) {
    username = username.substring(1);
  } else if (username.contains('/')) {
    final uri = Uri.tryParse(
      username.contains('://') ? username : 'https://$username',
    );
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        !['instagram.com', 'www.instagram.com'].contains(uri.host) ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort ||
        !RegExp(r'^/[^/]+/?$').hasMatch(uri.path)) {
      throw const FormatException(
        'Ingresá un enlace a un perfil de Instagram válido.',
      );
    }
    username = uri.pathSegments.first;
  }
  if (!RegExp(r'^[a-zA-Z0-9._]{1,30}$').hasMatch(username)) {
    throw const FormatException(
      'El usuario debe tener entre 1 y 30 caracteres: letras, números, puntos o guiones bajos.',
    );
  }
  return 'https://instagram.com/$username';
}
