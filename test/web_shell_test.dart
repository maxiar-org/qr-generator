import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String html;

  setUpAll(() {
    html = File('web/index.html').readAsStringSync();
  });

  test('declares the iOS standalone meta tags needed for "Agregar a inicio"', () {
    expect(
      html,
      contains('<meta name="apple-mobile-web-app-capable" content="yes">'),
    );
    expect(
      html,
      contains('name="apple-mobile-web-app-status-bar-style"'),
    );
    expect(
      html,
      contains('name="apple-mobile-web-app-title" content="Generador de QR"'),
    );
  });

  test('shows a branded splash instead of a blank white page while Flutter boots', () {
    expect(html, contains('id="splash"'));
    // Papel y Sello de DESIGN.md, no blanco liso.
    expect(html, contains('#F7F6F2'));
    expect(html, contains('#0F4C5C'));
    // La misma geometría que assets/branding/logo.svg (3 módulos + etiqueta).
    expect(html, contains('<svg'));
  });

  test('fades the splash out once Flutter renders its first frame', () {
    expect(html, contains('flutter-first-frame'));
  });
}
