#!/usr/bin/env python3
"""Keep KPackages standalone while sharing Smart Panel tokens and source artwork."""
import argparse
import base64
import hashlib
import json
import re
import copy
from pathlib import Path
import xml.etree.ElementTree as ET

ET.register_namespace("", "http://www.w3.org/2000/svg")

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--check', action='store_true')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
mock = root.parent / 'docs/mock/smart-panel/assets'
packages = ['panel', 'sbermenu', 'smarttasks', 'applications', 'filesearch', 'controlcenter', 'clockcalendar']
outputs = {}
for name in packages:
    ui = root / f'plasmoids/sberos.{name}/contents/ui'
    outputs[ui / 'SmartPanelTheme.qml'] = (root / 'shared/SmartPanelTheme.qml').read_bytes()
    outputs[ui / 'SmartPanelIcon.qml'] = (root / 'shared/SmartPanelIcon.qml').read_bytes()
    if name in ['sbermenu', 'filesearch', 'controlcenter', 'clockcalendar']:
        outputs[ui / 'SmartPopupPlacement.qml'] = (root / 'shared/SmartPopupPlacement.qml').read_bytes()
        outputs[ui.parent / 'assets/smart-panel/popup-frame.svg'] = (root / 'shared/SmartPopupFrame.svg').read_bytes()
    if name in ['applications', 'filesearch']:
        outputs[ui / 'OskaAvatar.qml'] = (root / 'shared/OskaAvatar.qml').read_bytes()
outputs[root / 'plasmoids/sberos.sbermenu/contents/assets/smart-panel/power-popup-frame.svg'] = (root / 'shared/SmartPowerPopupFrame.svg').read_bytes()
outputs[root / 'plasmoids/sberos.filesearch/contents/assets/smart-panel/search-popup-frame.svg'] = (root / 'shared/SmartSearchPopupFrame.svg').read_bytes()
icons = {
    'sbermenu': ['sber', 'settings', 'terminal', 'power', 'down'],
    'controlcenter': ['controls', 'battery', 'capture', 'speaker', 'sun', 'wifi', 'bluetooth', 'night', 'moon', 'plane', 'bellOff', 'left', 'right'],
    'clockcalendar': ['left', 'right', 'down'],
    'filesearch': ['file', 'fileExcel', 'fileImage', 'filePdf', 'filePowerpoint', 'fileWord'],
}
for package, names in icons.items():
    for name in names:
        # Preserve path geometry, remove source-editor IDs,
        # and use a local coordinate system for the Qt SVG renderer.
        svg = ET.parse(mock / f'icons/{name}.svg').getroot()
        x, y, width, height = map(float, svg.get('viewBox').split())
        for parent in list(svg.iter()):
            for child in list(parent):
                if child.tag.endswith('defs'):
                    parent.remove(child)
            for key in ['id', 'clip-path', 'customFrame']:
                parent.attrib.pop(key, None)
        svg.set('viewBox', f'0 0 {width:g} {height:g}')
        group = ET.Element('{http://www.w3.org/2000/svg}g', {'transform': f'translate({-x:g},{-y:g})'})
        for child in list(svg):
            svg.remove(child)
            group.append(child)
        svg.append(group)
        outputs[root / f'plasmoids/sberos.{package}/contents/assets/smart-panel/{name}.svg'] = ET.tostring(svg, encoding='utf-8', xml_declaration=True)
        if package != 'filesearch':
            for tint in ['484c5b', 'e5e8ed', '9296a6', '959ba8', 'ffffff']:
                variant = copy.deepcopy(svg)
                for element in variant.iter():
                    for attribute in ['fill', 'stroke']:
                        if attribute in element.attrib and element.get(attribute) != 'none':
                            element.set(attribute, '#' + tint)
                outputs[root / f'plasmoids/sberos.{package}/contents/assets/smart-panel/{name}-{tint}.svg'] = ET.tostring(variant, encoding='utf-8', xml_declaration=True)

for symbol in ['vpn', 'bell']:
    shape = re.search(symbol + r": '([^']+)'", (mock.parent / 'mock.js').read_text()).group(1)
    for tint in ['', '484c5b', 'e5e8ed', '9296a6', '959ba8', 'ffffff']:
        color = '#' + (tint or '484c5b')
        suffix = '-' + tint if tint else ''
        outputs[root / f'plasmoids/sberos.controlcenter/contents/assets/smart-panel/{symbol}{suffix}.svg'] = (
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="' + color + '" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">' + shape + '</svg>\n').encode()
outputs[root / 'plasmoids/sberos.applications/contents/assets/launchpad.svg'] = (mock / 'launchpad.svg').read_bytes()
# QtSvg does not render the source's pattern/use indirection correctly. Preserve
# the embedded bitmap and its circular crop, without redrawing the character.
source = ET.parse(mock / 'avatar.svg').getroot()
png = source.find('.//{http://www.w3.org/2000/svg}image').get('{http://www.w3.org/1999/xlink}href')
base64.b64decode(png.split(',', 1)[1], validate=True)
avatar = ('<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="40" height="40" viewBox="0 0 40 40">'
          '<defs><clipPath id="crop"><circle cx="20" cy="20" r="20"/></clipPath></defs>'
          '<image width="40" height="40" clip-path="url(#crop)" xlink:href="' + png + '"/></svg>\n').encode()
for name in ['applications', 'filesearch']:
    outputs[root / f'plasmoids/sberos.{name}/contents/assets/oska-avatar.svg'] = avatar
manifest = {str(path.relative_to(root)): hashlib.sha256(data).hexdigest() for path, data in outputs.items()}
manifest['source/avatar.svg'] = hashlib.sha256((mock / 'avatar.svg').read_bytes()).hexdigest()
outputs[root / 'shared/artwork-manifest.json'] = (json.dumps(manifest, ensure_ascii=False, indent=2) + '\n').encode()
failures = []
for path, data in outputs.items():
    if args.check:
        if not path.exists() or path.read_bytes() != data:
            failures.append(str(path.relative_to(root)))
    else:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
if failures:
    raise SystemExit('Out of sync: ' + ', '.join(failures))
print(f'{len(outputs)} Smart Panel resources ' + ('verified' if args.check else 'synchronized'))
