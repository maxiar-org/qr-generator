#!/usr/bin/env python3
"""Verifica PNG 2:3 con un único hueco rectangular; requiere Pillow."""
import argparse
import json
import sys
from pathlib import Path
from PIL import Image, ImageChops


def validate_template(path):
    with Image.open(path) as image:
        width, height = image.size
        if image.format != 'PNG' or width < 1200 or height < 1800 or width * 3 != height * 2:
            raise ValueError('Se requiere PNG 2:3 de al menos 1200 × 1800 px')
        alpha = image.convert('RGBA').getchannel('A')
        histogram = alpha.histogram()
        if sum(histogram[1:255]):
            raise ValueError('Hay píxeles semitransparentes')
        hole = ImageChops.invert(alpha)
        bounds = hole.getbbox()
        if bounds is None:
            raise ValueError('No hay recuadro transparente')
        left, top, right, bottom = bounds
        if left == 0 or top == 0 or right == width or bottom == height:
            raise ValueError('El hueco debe estar rodeado de píxeles opacos')
        if histogram[0] != (right - left) * (bottom - top):
            raise ValueError('La transparencia no forma un único rectángulo completo')
        return {'file': str(path), 'size': [width, height], 'pixels': list(bounds),
                'relative': [left / width, top / height, right / width, bottom / height]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('images', nargs='+', type=Path)
    args = parser.parse_args()
    failed = False
    for path in args.images:
        try:
            print(json.dumps(validate_template(path), ensure_ascii=False))
        except (ValueError, OSError) as error:
            print(f'{path}: {error}', file=sys.stderr)
            failed = True
    return int(failed)


if __name__ == '__main__':
    sys.exit(main())
