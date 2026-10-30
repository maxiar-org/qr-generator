"""Pruebas del contrato de transparencia de los templates."""
import json
import tempfile
import unittest
from pathlib import Path
from PIL import Image
from templates_transparent import validate_template


class TemplateTests(unittest.TestCase):
    def check_image(self, image):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'template.png'
            image.save(path)
            return validate_template(path)

    def valid_image(self):
        image = Image.new('RGBA', (1200, 1800), 'white')
        image.paste((0, 0, 0, 0), (200, 500, 1000, 1300))
        return image

    def test_rectangle_coordinates(self):
        result = self.check_image(self.valid_image())
        self.assertEqual(result['pixels'], [200, 500, 1000, 1300])
        self.assertAlmostEqual(result['relative'][0], 1 / 6)

    def test_invalid_alpha(self):
        for pixel, value in [((10, 10), 0), ((300, 600), 255),
                             ((10, 10), 128), ((200, 500), 255)]:
            with self.subTest(pixel=pixel, value=value):
                image = self.valid_image()
                image.putpixel(pixel, (0, 0, 0, value))
                with self.assertRaises(ValueError):
                    self.check_image(image)

    def test_missing_hole_or_frame(self):
        for alpha in (0, 255):
            with self.assertRaises(ValueError):
                self.check_image(Image.new('RGBA', (1200, 1800), (0, 0, 0, alpha)))

    def test_dimensions(self):
        for size in ((600, 900), (1200, 1900)):
            with self.assertRaises(ValueError):
                self.check_image(self.valid_image().resize(size))

    def test_deliverables(self):
        root = Path(__file__).resolve().parents[1] / 'assets/templates'
        for template in json.loads((root / 'templates.json').read_text()):
            with self.subTest(name=template['id']):
                validate_template(root / Path(template['image']).name)


if __name__ == '__main__':
    unittest.main()
