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
args = parser.parse_args()
args.output.mkdir(parents=True, exist_ok=True)
with tempfile.TemporaryDirectory(prefix='sber-panel-') as temporary:
    work = Path(temporary)
    config = work / 'config/sirca-shell'
    config.mkdir(parents=True)
    (work / 'data').mkdir()
    (config / 'config.json').write_text(json.dumps({
        'mode': 'light', 'panelLayout': 'unified', 'dockDodge': False,
        'dockVisibility': 'always', 'welcomed': True, 'selfTestNotify': False,
    }))
    fixture = work / 'Smoke.qml'
    fixture.write_text((ROOT / 'tests/panel/Smoke.qml').read_text().replace('OUTPUT_DIR', str(args.output.resolve())))
    env = dict(os.environ, QT_QPA_PLATFORM='offscreen', QT_QUICK_BACKEND='software',
               XDG_CONFIG_HOME=str(work / 'config'), XDG_DATA_HOME=str(work / 'data'))
    log_path = args.output / 'smoke.log'
    with log_path.open('w') as log:
        result = subprocess.run(['dbus-run-session', '--', 'timeout', '25s', str(args.binary.resolve()),
                                 '--qml-test', str(fixture)], env=env, stdout=log, stderr=subprocess.STDOUT)
    log = log_path.read_text()
    errors = [line for line in log.splitlines() if any(token in line for token in
              ['PANEL FAIL:', 'ReferenceError:', 'TypeError:', 'Binding loop', 'Cannot assign'])]
    passed = result.returncode == 0 and not errors and 'PANEL PASS:' in log
    for line in errors:
        print(line)
    print(('PASS' if passed else 'FAIL') + f': panel smoke; exit={result.returncode}; log={log_path}')
    raise SystemExit(0 if passed else 1)
