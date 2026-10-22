#!/usr/bin/env python3
"""Generate isolated KDE/GTK palettes from UI Kit resources; never apply them.

Source hex colours are RRGGBBAA (not Qt's runtime AARRGGBB). Translucent
foregrounds are composited over each target surface, producing opaque output.
SPDX-License-Identifier: GPL-3.0-or-later
"""
import argparse
import configparser
import hashlib
import io
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_RESOURCES = ROOT.parents[1] / 'ui-kit' / 'resources'
ROLES = {
    'window': 'Background.Default.Primary',
    'view': 'Background.Default.Secondary',
    'alternate': 'Background.Default.Tertiary',
    'button': 'Surface.Default.TransparentSecondary',
    'hover': 'Surface.Default.TransparentSecondaryHover',
    'pressed': 'Surface.Default.TransparentSecondaryActive',
    'selection': 'Surface.Default.Accent',
    'selectionHover': 'Surface.Default.AccentHover',
    'selectionPressed': 'Surface.Default.AccentActive',
    'text': 'Text.Default.Primary',
    'muted': 'Text.Default.Secondary',
    'disabled': 'Text.Default.Tertiary',
    'link': 'Text.Default.Info',
    'positive': 'Text.Default.Positive',
    'warning': 'Text.Default.Warning',
    'negative': 'Text.Default.Negative',
    'border': 'Outline.Default.SolidSecondary',
    'focus': 'Outline.Default.Accent',
    'onLight': 'Text.OnLight.Primary',
    'onDark': 'Text.OnDark.Primary',
}


def lookup(obj, path):
    for key in path.split('.'):
        obj = obj[key]
    return obj


def rgba(value):
    if not re.fullmatch(r'#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?', value):
        raise ValueError(f'Unsupported UI Kit colour: {value!r}')
    parts = tuple(int(value[i:i + 2], 16) for i in range(1, len(value), 2))
    return parts if len(parts) == 4 else parts + (255,)


def opaque(foreground, background):
    if background[3] != 255:
        raise ValueError('Compositing requires an opaque background')
    a = foreground[3]
    return tuple((foreground[i] * a + background[i] * (255 - a) + 127) // 255
                 for i in range(3)) + (255,)


def hex_color(color):
    return '#' + ''.join(f'{v:02x}' for v in color[:3])


def luminance(color):
    channels = [v / 255 for v in color[:3]]
    linear = [v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4
              for v in channels]
    return sum(v * w for v, w in zip(linear, (0.2126, 0.7152, 0.0722)))


class Tokens:
    def __init__(self, resources):
        self.resources = resources
        self.inputs = {}
        self.theme = self.read('theme/sdds_os.json')

    def read(self, relative):
        data = (self.resources / relative).read_bytes()
        self.inputs[relative] = hashlib.sha256(data).hexdigest()
        return json.loads(data)

    def resolve(self, mode, path):
        value = lookup(self.theme[mode], path)
        match = re.fullmatch(r'\[(\w+)\.(\w+)\.(\d+)\]', value)
        if match:
            group, palette, shade = match.groups()
            # Match ThemeFunctions::UploadTheme filename-to-camelCase convention.
            candidates = sorted((self.resources / 'theme/colors' / group).glob('*.json'))
            for candidate in candidates:
                parts = candidate.stem.split('_')
                name = parts[0] + ''.join(p[:1].upper() + p[1:] for p in parts[1:])
                if name == palette:
                    value = self.read(candidate.relative_to(self.resources).as_posix())[shade]
                    break
            else:
                raise ValueError(f'Unresolved UI Kit reference: {value}')
        return rgba(value)


def palette(tokens, mode):
    colors = {role: tokens.resolve(mode, path) for role, path in ROLES.items()}
    for role in ('window', 'view', 'alternate', 'button', 'hover', 'pressed',
                 'selection', 'selectionHover', 'selectionPressed'):
        if colors[role][3] != 255:
            raise ValueError(f'{mode}: surface {ROLES[role]} must be opaque')
    return colors


def on_surface(p, role, surface):
    return opaque(p[role], p[surface])


def selection_text(p):
    # Pick one documented text role for all accent states, maximising the worst
    # contrast ratio. No invented foreground colour and no per-hover text jump.
    def worst(role):
        ratios = []
        for surface in ('selection', 'selectionHover', 'selectionPressed'):
            a, b = sorted((luminance(on_surface(p, role, surface)), luminance(p[surface])))
            ratios.append((b + 0.05) / (a + 0.05))
        return min(ratios)
    return max(('onLight', 'onDark'), key=worst)


def kde_scheme(p, name):
    config = configparser.ConfigParser(interpolation=None)
    config.optionxform = str
    def rgb(c):
        return ','.join(str(v) for v in c[:3])
    for group, surface in {
        'Window': 'window', 'View': 'view', 'Button': 'button',
        'Selection': 'selection', 'Tooltip': 'alternate',
        'Complementary': 'alternate', 'Header': 'window',
        'Header][Inactive': 'window',
    }.items():
        values = {
            'BackgroundNormal': rgb(p[surface]),
            'BackgroundAlternate': rgb(p['alternate'] if group == 'View' else p[surface]),
            'DecorationFocus': rgb(on_surface(p, 'focus', surface)),
            'DecorationHover': rgb(on_surface(p, 'focus', surface)),
        }
        for key, role in {
            'Normal': selection_text(p) if group == 'Selection' else 'text',
            'Inactive': selection_text(p) if group == 'Selection' else 'muted',
            'Active': 'text', 'Link': 'link', 'Visited': 'muted',
            'Positive': 'positive', 'Neutral': 'warning', 'Negative': 'negative',
        }.items():
            values[f'Foreground{key}'] = rgb(on_surface(p, role, surface))
        config[f'Colors:{group}'] = values
    config['General'] = {'Name': name, 'ColorScheme': name, 'shadeSortColumn': 'true'}
    config['WM'] = {
        'activeBackground': rgb(p['window']), 'inactiveBackground': rgb(p['window']),
        'activeForeground': rgb(on_surface(p, 'text', 'window')),
        'inactiveForeground': rgb(on_surface(p, 'muted', 'window')),
        'activeBlend': rgb(on_surface(p, 'text', 'window')),
        'inactiveBlend': rgb(on_surface(p, 'muted', 'window')),
    }
    out = io.StringIO()
    config.write(out, space_around_delimiters=False)
    return '# Generated from SberOS UI Kit; do not edit.\n' + out.getvalue()


def gtk_css(p):
    color = lambda role, surface='window': hex_color(on_surface(p, role, surface))
    definitions = {}
    for prefix, surface in {
        'window': 'window', 'view': 'view', 'headerbar': 'window',
        'sidebar': 'alternate', 'secondary_sidebar': 'alternate',
        'card': 'alternate', 'dialog': 'window', 'popover': 'alternate',
        'thumbnail': 'alternate',
    }.items():
        definitions[f'{prefix}_bg_color'] = color(surface)
        definitions[f'{prefix}_fg_color'] = color('text', surface)
    definitions.update({
        'accent_color': color('focus'), 'accent_bg_color': color('selection'),
        'accent_fg_color': color(selection_text(p), 'selection'),
        'borders': color('border'), 'headerbar_border_color': color('border'),
        'headerbar_backdrop_color': color('window'),
        'sidebar_backdrop_color': color('alternate'),
    })
    for status, role in {'success': 'positive', 'warning': 'warning',
                         'error': 'negative', 'destructive': 'negative'}.items():
        definitions[f'{status}_color'] = color(role)
    css = '/* Generated from SberOS UI Kit; do not edit. */\n'
    css += ''.join(f'@define-color {k} {v};\n' for k, v in definitions.items())
    # Conservative GTK 3/4 common subset; preserve toolkit geometry and glyphs.
    for selectors, surface in {
        'window, headerbar, .background': 'window',
        '.view, textview text, entry': 'view',
        '.sidebar, .navigation-sidebar, popover > contents, menu, tooltip': 'alternate',
        'button': 'button', 'button:hover': 'hover', 'button:active': 'pressed',
        'row:selected, selection, button.suggested-action': 'selection',
        'button.suggested-action:hover': 'selectionHover',
        'button.suggested-action:active': 'selectionPressed',
    }.items():
        fg = selection_text(p) if surface.startswith('selection') else 'text'
        css += (f'{selectors} {{ background-image: none; background-color: {color(surface)}; '
                f'color: {color(fg, surface)}; }}\n')
    css += f'button:disabled {{ color: {color("disabled", "button")}; }}\n'
    css += f'entry:disabled {{ color: {color("disabled", "view")}; }}\n'
    css += f'link, button.link {{ color: {color("link")}; }}\n'
    css += f'entry:focus, button:focus {{ outline-color: {color("focus")}; }}\n'
    return css


def generate(resources, output):
    tokens = Tokens(resources)
    files = {}
    manifest = {'schema': 1, 'roles': ROLES, 'modes': {}}
    for mode, name in [('Light', 'SberOSLight'), ('Dark', 'SberOSDark')]:
        p = palette(tokens, mode)
        files[f'kde/{name}.colors'] = kde_scheme(p, name)
        for version in ('3.0', '4.0'):
            files[f'gtk/{mode.lower()}/gtk-{version}.css'] = gtk_css(p)
        manifest['modes'][mode.lower()] = {
            'colors': {k: '#'+''.join(f'{v:02x}' for v in c) for k, c in p.items()},
            'selectionTextRole': ROLES[selection_text(p)],
        }
    manifest['sources'] = dict(sorted(tokens.inputs.items()))
    files['manifest.json'] = json.dumps(manifest, indent=2, sort_keys=True) + '\n'
    # Resolve and validate both modes before creating output files.
    for relative, contents in files.items():
        path = output / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(contents, encoding='utf-8')
    return files


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--resources', type=Path, default=DEFAULT_RESOURCES,
                        help='UI Kit resources directory')
    parser.add_argument('--output', type=Path, required=True,
                        help='Output directory; no installation or session changes')
    args = parser.parse_args()
    try:
        files = generate(args.resources, args.output)
    except (OSError, ValueError, KeyError, TypeError) as error:
        parser.exit(1, f'Cannot generate SberOS theme: {error}\n')
    print(f'Generated {len(files)} files in {args.output}')


if __name__ == '__main__':
    main()
