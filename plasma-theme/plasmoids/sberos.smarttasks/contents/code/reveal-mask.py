#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
"""Cache all native blur/input frame steps for one applications island geometry."""
import hashlib
import json
import os
from pathlib import Path
import sys


def make_svg(geometry):
    host_width, host_height, compact_width, compact_height, grid_width, grid_height = geometry['sizes']
    if not all(0 < value <= 32768 for value in geometry['sizes']):
        raise ValueError('Invalid island dimensions')
    child = geometry.get('child', [])
    parts = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{host_width}" height="{host_height}" viewBox="0 0 {host_width} {host_height}">']
    for step in range(65):
        reveal = step / 64
        width = compact_width + (grid_width - compact_width) * reveal
        height = compact_height + (grid_height - compact_height) * reveal
        radius = min(24, compact_height / 3)
        parts.append(f'<g id="reveal-{step}-center"><rect width="{host_width}" height="{host_height}" fill="none"/>')
        parts.append(f'<rect y="{host_height-height:g}" width="{width:g}" height="{height:g}" rx="{radius:g}" fill="white"/>')
        if child:
            x, y, width, height = child
            parts.append(f'<rect x="{x:g}" y="{y:g}" width="{width:g}" height="{height:g}" rx="24" fill="white"/>')
        parts.append('</g>')
        for side in ['left', 'top', 'right', 'bottom']:
            parts.append(f'<rect id="reveal-{step}-hint-{side}-margin" width="0.001" height="0.001"/>')
    for side in ['left', 'top', 'right', 'bottom']:
        parts.append(f'<rect id="hint-{side}-margin" width="0.001" height="0.001"/>')
    parts.append('</svg>')
    return '\n'.join(parts) + '\n'


if __name__ == '__main__':
    geometry = json.loads(sys.argv[1])
    svg = make_svg(geometry)
    key = hashlib.sha256(svg.encode()).hexdigest()
    cache = Path(os.environ.get('XDG_CACHE_HOME', str(Path.home() / '.cache'))) / 'sberos-shell/applications-reveal'
    cache.mkdir(parents=True, exist_ok=True)
    path = cache / (key + '.svg')
    if not path.exists():
        temporary = cache / (key + f'.{os.getpid()}.tmp')
        temporary.write_text(svg)
        temporary.replace(path)
    print(json.dumps({'path': str(path)}))
