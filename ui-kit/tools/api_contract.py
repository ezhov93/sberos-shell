#!/usr/bin/env python3
"""Maintain the source-backed API inventory; no Qt or third-party packages needed."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / 'docs'
MODULES = {'core': 'Sber.Core', 'controls': 'Sber.Controls', 'theme': 'Sber.Theme',
           'utils': 'Sber.Utils', 'widgets': 'Sber.Widgets'}


def mask(text):
    # Keep offsets/newlines; hide comments and strings before counting braces.
    return re.sub(r'//[^\n]*|/\*[\s\S]*?\*/|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|`(?:\\.|[^`\\])*`',
                  lambda m: ''.join('\n' if c == '\n' else ' ' for c in m[0]), text)


def qml_api(path):
    text = path.read_text()
    clean = mask(text)
    depth = 0
    depths = []
    for c in clean:
        depths.append(depth)
        depth += (c == '{') - (c == '}')
    root = re.search(r'^([\w.]+)\s*\{', clean, re.M)
    if not root:
        raise ValueError(f'No root QML object: {path}')
    declarations = []
    pattern = (r'\b(?:(?:readonly|default|required)\s+)*property\s+[\w.<>]+\s+\w+'
               r'|\bsignal\s+\w+\s*\([^)]*\)'
               r'|\bfunction\s+\w+\s*\([^)]*\)'
               r'|\benum\s+\w+\s*\{[^}]*\}')
    for m in re.finditer(pattern, clean):
        if depths[m.start()] == 1:
            declarations.append(' '.join(text[m.start():m.end()].split()))
    return root[1], declarations


def catalog():
    out = ['# Каталог объявлений UI Kit', '',
           'Генерируется `python3 ui-kit/tools/api_contract.py --write`. Не редактировать вручную.', '',
           'Основной контракт и семантика: [API.md](API.md). Здесь перечислены собственные',
           'объявления корневых QML-объектов и экспортируемые C++-объявления верхнего уровня.',
           'Наследуемый Qt API, значения по умолчанию, вложенные объекты и детали поведения',
           'не извлекаются. Наличие объявления не гарантирует работоспособность поведения.',
           'Поля вспомогательных объектов и функции реализации не становятся рекомендуемым API.', '']
    for folder, uri in MODULES.items():
        out += [f'## {uri}', '']
        for p in sorted((ROOT / folder).glob('*.qml')):
            base, declarations = qml_api(p)
            out += [f'### {p.stem}', '', f'Базовый тип: `{base}`. Источник: `{p.relative_to(ROOT)}`.', '', '```qml']
            out += declarations or ['// Собственных объявлений нет.']
            out += ['```', '']
        for p in sorted((ROOT / folder).glob('*.h')):
            text = mask(p.read_text())
            if not re.search(r'QML_(?:ELEMENT|NAMED_ELEMENT)', text):
                continue
            decl = re.findall(r'Q_PROPERTY\([^\n]*\)|Q_INVOKABLE\s+[^;{]+|Q_ENUM(?:_NS)?\([^)]*\)', text)
            enums = re.findall(r'\benum\s+(?:class\s+)?\w+\s*\{[^}]*\}', text)
            out += [f'### C++: {p.stem}', '', f'Источник: `{p.relative_to(ROOT)}`.', '', '```cpp']
            out += [' '.join(s.split()) for s in enums + decl]
            out += ['```', '']
    return '\n'.join(out)


def tokens():
    classes = {}
    for path in sorted((ROOT / 'theme/generated').rglob('*.h')):
        text = mask(path.read_text())
        match = re.search(r'class\s+(\w+)\s*:', text)
        if match:
            classes[match[1]] = re.findall(r'Q_PROPERTY\(\s*([\w:*]+)\s+(\w+)\s+(?:READ|MEMBER)', text)
    out = ['# Каталог токенов UI Kit', '',
           'Генерируется `python3 ui-kit/tools/api_contract.py --write` из Q_PROPERTY дерева темы.',
           'Пути чувствительны к регистру. Значения зависят от выбранной темы и ресурсов.',
           'Правила использования: [API.md](API.md).', '', '| Путь | Тип |', '| --- | --- |']

    def visit(cls, prefix, seen):
        if cls in seen:
            raise ValueError('Token graph cycle: ' + cls)
        for kind, name in classes[cls]:
            path = prefix + '.' + name
            child = kind.rstrip('*')
            if child in classes:
                visit(child, path, seen | {cls})
            else:
                out.append(f'| `{path}` | `{kind}` |')

    for cls, prefix in [('PaletteClass', 'Theme.Palette'), ('SizesClass', 'Theme.Sizes'),
                        ('FontsBase', 'Theme.Fonts')]:
        visit(cls, prefix, set())
    return '\n'.join(out) + '\n'


def manifest():
    paths = []
    for folder in MODULES:
        paths += [p for p in (ROOT / folder).rglob('*')
                  if p.is_file() and (p.suffix in {'.qml', '.h', '.cpp'} or p.name == 'CMakeLists.txt')]
    paths += list((ROOT / 'resources/theme').rglob('*.json'))
    paths += [ROOT / 'CMakeLists.txt', ROOT / 'version.txt']
    return json.dumps({str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                       for p in sorted(paths)}, indent=2, ensure_ascii=False) + '\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true', help='Regenerate inventory after reviewing API.md')
    parser.add_argument('--check', action='store_true', help='Check inventory and implementation fingerprint (default)')
    args = parser.parse_args()
    if args.write and args.check:
        parser.error('Choose --write or --check')
    expected = {DOCS / 'API-catalog.md': catalog(), DOCS / 'API-tokens.md': tokens(),
                DOCS / 'api-source-manifest.json': manifest()}
    stale = []
    for path, content in expected.items():
        if args.write:
            path.write_text(content)
        elif not path.exists() or path.read_text() != content:
            stale.append(str(path.relative_to(ROOT)))
    if stale:
        print('API contract needs review: ' + ', '.join(stale), file=sys.stderr)
        print('Review API.md, then run with --write. Fingerprint changes include implementation-only edits.', file=sys.stderr)
        return 1
    print('API inventory written; review API.md separately.' if args.write else
          'API inventory and source fingerprint are current. Behavior is not tested by this check.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
