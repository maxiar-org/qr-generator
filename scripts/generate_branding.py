"""Rasterize the canonical SVG. Run from any directory with CairoSVG 2.9.1."""

from pathlib import Path
import xml.etree.ElementTree as ET

import cairosvg

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets/branding/logo.svg"
PAPER = "#F7F6F2"


def render(size, *, maskable=False):
    source = ET.parse(SOURCE).getroot()
    # The artwork spans 48/64. Scaling to 72% places even the corners
    # inside radius 40%: sqrt(2) * 0.375 * 0.72 = 0.382 < 0.4.
    scale = 0.72 if maskable else 1
    inset = (64 - 64 * scale) / 2
    children = "".join(ET.tostring(child, encoding="unicode") for child in source)
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
      <rect width="64" height="64" fill="{PAPER}"/>
      <g fill="{source.attrib['fill']}" transform="translate({inset} {inset}) scale({scale})">
        {children}
      </g>
    </svg>'''
    return cairosvg.svg2png(bytestring=svg.encode(), output_width=size, output_height=size)


def main():
    outputs = {"favicon.png": (32, False), "icons/apple-touch-icon.png": (180, False)}
    for size in (192, 512):
        outputs[f"icons/Icon-{size}.png"] = (size, False)
        outputs[f"icons/Icon-maskable-{size}.png"] = (size, True)
    for name, (size, maskable) in outputs.items():
        path = ROOT / "web" / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(render(size, maskable=maskable))
        print(path.relative_to(ROOT))


if __name__ == "__main__":
    main()
