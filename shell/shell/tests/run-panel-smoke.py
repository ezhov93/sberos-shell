#!/usr/bin/env python3
"""Check panel composition using the built shell, offscreen and a private D-Bus session."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--binary', type=Path, default=Path('/tmp/sberos-shell-build/bin/sirca-shell'))
parser.add_argument('--output', type=Path, default=Path('/tmp/sber-panel-check'))
parser.add_argument('--wayland', action='store_true', help='Use the current Wayland session (temporary config, no shortcut ownership)')
parser.add_argument('--layout', action='store_true', help='Check the five-zone layout at 1920 px')
args = parser.parse_args()
if args.wayland and not args.layout:
    parser.error("--wayland requires --layout (Wayland image capture is not available)")
args.output.mkdir(parents=True, exist_ok=True)
with tempfile.TemporaryDirectory(prefix='sber-panel-') as temporary:
    work = Path(temporary)
    config = work / 'config/sirca-shell'
    config.mkdir(parents=True)
    (work / 'data').mkdir()
    (config / 'config.json').write_text(json.dumps({
        'mode': 'light', 'panelLayout': 'unified', 'dockDodge': False,
        'dockVisibility': 'always', 'welcomed': True, 'selfTestNotify': False, 'ownWallpaper': False,
    }))
    screen_config = work / 'screen.json'
    screen_config.write_text(json.dumps({'screens': [{'name': 'panel-test', 'width': 1920, 'height': 1080, 'logicalDpi': 96, 'logicalBaseDpi': 96}]}))
    stress_launchers = ['applications:' + p.name for p in sorted(Path('/usr/share/applications').glob('*.desktop'))[:30]]
    fixture = work / 'Smoke.qml'
    fixture.write_text((ROOT / ('tests/panel/Layout.qml' if args.layout else 'tests/panel/Smoke.qml')).read_text().replace('OUTPUT_DIR', str(args.output.resolve())).replace('CAPTURE_ENABLED', 'false' if args.wayland else 'true').replace('STRESS_LAUNCHERS', json.dumps(stress_launchers)))
    env = dict(os.environ, QT_QPA_PLATFORM='wayland' if args.wayland else f'offscreen:configfile={screen_config}', QT_QUICK_BACKEND='software',
               XDG_CONFIG_HOME=str(work / 'config'), XDG_DATA_HOME=str(work / 'data'))
    if args.wayland:
        env.pop('QT_QUICK_BACKEND', None)
        env.pop('QSG_RHI_BACKEND', None)
    log_path = args.output / 'smoke.log'
    with log_path.open('w') as log:
        command = ['timeout', '25s', str(args.binary.resolve()), '--qml-test', str(fixture)]
        if not args.wayland:
            command = ['dbus-run-session', '--', *command]
        result = subprocess.run(command, env=env, stdout=log, stderr=subprocess.STDOUT)
    log = log_path.read_text()
    errors = [line for line in log.splitlines() if any(token in line for token in
              ['PANEL FAIL:', 'ReferenceError:', 'TypeError:', 'Binding loop', 'Cannot assign'])]
    passed = result.returncode == 0 and not errors and 'PANEL PASS:' in log
    for line in errors:
        print(line)
    print(('PASS' if passed else 'FAIL') + f': panel smoke; exit={result.returncode}; log={log_path}')
    raise SystemExit(0 if passed else 1)
