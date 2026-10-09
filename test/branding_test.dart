import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'installation metadata uses the brand palette and dedicated Apple icon',
    () {
      final manifest = jsonDecode(File('web/manifest.json').readAsStringSync());
      expect(manifest['background_color'], '#F7F6F2');
      expect(manifest['theme_color'], '#0F4C5C');
      expect(
        File('web/index.html').readAsStringSync(),
        contains('href="icons/apple-touch-icon.png"'),
      );
      expect(File('assets/branding/logo.svg').existsSync(), isTrue);
    },
  );

  test(
    'installation icons have correct dimensions, opacity and safe artwork',
    () async {
      final sizes = {
        'favicon.png': 32,
        'icons/Icon-192.png': 192,
        'icons/Icon-512.png': 512,
        'icons/Icon-maskable-192.png': 192,
        'icons/Icon-maskable-512.png': 512,
        'icons/apple-touch-icon.png': 180,
      };
      for (final entry in sizes.entries) {
        final codec = await ui.instantiateImageCodec(
          File('web/${entry.key}').readAsBytesSync(),
        );
        final image = (await codec.getNextFrame()).image;
        expect(image.width, entry.value, reason: entry.key);
        expect(image.height, entry.value, reason: entry.key);
        final bytes = (await image.toByteData())!;
        var inkPixels = 0;
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            final offset = (y * image.width + x) * 4;
            expect(bytes.getUint8(offset + 3), 255, reason: entry.key);
            if (bytes.getUint8(offset) < 120) {
              inkPixels++;
              if (entry.key.contains('maskable')) {
                final dx = x + 0.5 - image.width / 2;
                final dy = y + 0.5 - image.height / 2;
                expect(
                  dx * dx + dy * dy,
                  lessThanOrEqualTo(image.width * image.width * 0.16),
                  reason: 'Artwork must fit the central 80% circle',
                );
              }
            }
          }
        }
        expect(inkPixels, greaterThan(image.width * image.height * 0.1));
        image.dispose();
        codec.dispose();
      }
    },
  );
}
