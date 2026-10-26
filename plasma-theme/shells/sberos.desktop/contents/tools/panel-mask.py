#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
"""Write a content-addressed KSvg mask for the actual panel surfaces."""
import hashlib
import json
import math
import os
from pathlib import Path
import sys

payload = json.loads(sys.argv[1])
width, height = [float(payload[key]) for key in ('width', 'height')]
if not all(math.isfinite(value) and 0 < value <= 32768 for value in (width, height)):
    raise SystemExit('Invalid panel extent')
rects = []
for item in payload['rects']:
    x, y, w, h, radius = [float(item[key]) for key in ('x', 'y', 'width', 'height', 'radius')]
    if not all(math.isfinite(value) for value in (x, y, w, h, radius)) or w <= 0 or h <= 0:
        continue
    rects.append(f'<rect x="{x:g}" y="{y:g}" width="{w:g}" height="{h:g}" rx="{min(radius,w/2,h/2):g}" fill="white"/>')
if not rects:
    raise SystemExit('No panel surfaces')
extent = f'<rect width="{width:g}" height="{height:g}" fill="none"/>'
shape = extent + ''.join(rects)
svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{width:g}" height="{height:g}" viewBox="0 0 {width:g} {height:g}">'
       f'<g id="center">{shape}</g><g id="mask-center">{shape}</g></svg>\n')
folder = Path(os.environ.get('XDG_CACHE_HOME', str(Path.home()/'.cache'))) / 'sberos-plasma' / 'panel-masks'
folder.mkdir(parents=True, exist_ok=True, mode=0o700)
path = folder / (hashlib.sha256(svg.encode()).hexdigest() + '.svg')
if not path.exists():
    temp = folder / (path.name + f'.{os.getpid()}.tmp')
    temp.write_text(svg)
    temp.replace(path)
print(json.dumps({'path': str(path)}))
