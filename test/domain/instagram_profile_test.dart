import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/src/domain/instagram_profile.dart';

void main() {
  group('normalizeInstagramProfile', () {
    for (final input in [
      'https://www.instagram.com/usuario/',
      'instagram.com/usuario?igsh=abc',
      '@usuario',
      'usuario',
      '  @usuario  ',
      'https://instagram.com/usuario/?igsh=abc#bio',
    ]) {
      test('normalizes $input', () {
        expect(
          normalizeInstagramProfile(input),
          'https://instagram.com/usuario',
        );
      });
    }
    for (final username in ['a', 'A.b_09', 'a' * 30]) {
      test('accepts valid username $username', () {
        expect(
          normalizeInstagramProfile(username),
          'https://instagram.com/$username',
        );
      });
    }
    for (final input in [
      '',
      ' ',
      '@',
      'a' * 31,
      'two words',
      'user-name',
      'usuário',
      'user/name',
      '@@user',
      'https://example.com/user',
      'https://instagram.com.evil.com/user',
      'https://instagram.com/',
      'https://instagram.com/user/post',
      'https://user:password@instagram.com/user',
      'ftp://instagram.com/user',
      'https://instagram.com:8080/user',
    ]) {
      test('rejects invalid input $input', () {
        expect(() => normalizeInstagramProfile(input), throwsFormatException);
      });
    }
  });
}
