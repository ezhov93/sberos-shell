#!/usr/bin/env python3
"""Exercise the real settings QML with isolated in-memory shell services."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--ui-kit-build', type=Path, default=ROOT / '../../ui-kit/_build')
parser.add_argument('--output', type=Path, default=Path('/tmp/sber-settings-check'))
parser.add_argument('--baseline', type=Path, help='Capture an earlier Settings.qml instead of running regression tests')
args = parser.parse_args()
args.output.mkdir(parents=True, exist_ok=True)
with tempfile.TemporaryDirectory(prefix='sber-settings-') as temporary:
    work = Path(temporary)
    (work / 'data').mkdir()
    (work / 'config').mkdir()
    module = work / 'SircaShell'
    module.mkdir()
    for name in ['Shell.qml']:
        shutil.copy(ROOT / 'tests/settings' / name, module / name)
    shutil.copy(ROOT / 'qml/Config.qml', module / 'Config.qml')
    (module / 'UserWidgets.qml').write_text('pragma Singleton\nimport QtQuick\nQtObject { property var names: []; function label(name) { return name } }\n')
    (module / 'qmldir').write_text('module SircaShell\nsingleton Shell 1.0 Shell.qml\nsingleton Config 1.0 Config.qml\nsingleton UserWidgets 1.0 UserWidgets.qml\n')
    shutil.copy(args.baseline or ROOT / 'qml/Settings.qml', work / 'Settings.qml')
    shutil.copy(ROOT / 'tests/settings/wallpaper.svg', work / 'wallpaper.svg')
    if args.baseline:
        shutil.copytree(ROOT / 'qml/Glass', work / 'Glass')
    test = (ROOT / 'tests/settings/tst_settings.qml').read_text().replace('CAPTURE_DIR', str(args.output.resolve()))
    if args.baseline:
        test = """import QtQuick
import QtTest
import SircaShell
TestCase {
    name: "BaselineCapture"
    when: windowShown
    function test_capture() {
        const component = Qt.createComponent("Settings.qml")
        compare(component.status, Component.Ready, component.errorString())
        const settings = component.createObject(null)
        verify(settings !== null)
        for (const mode of ["light", "dark"]) {
            Shell.saveConfigKey("mode", mode)
            settings.openIt(0)
            wait(500)
            grabImage(settings.contentItem).save("CAPTURE_DIR/settings-" + mode + "-0.png")
        }
        settings.close()
        settings.destroy()
    }
}
""".replace('CAPTURE_DIR', str(args.output.resolve()))
    (work / 'tst_settings.qml').write_text(test)
    env = dict(os.environ, QT_QPA_PLATFORM='offscreen', QSG_RHI_BACKEND='software', QT_QUICK_BACKEND='software',
               XDG_DATA_HOME=str(work / 'data'), XDG_CONFIG_HOME=str(work / 'config'),
               QML_IMPORT_PATH=str(args.ui_kit_build.resolve() / 'qml'))
    result = subprocess.run(['/usr/lib/qt6/bin/qmltestrunner', '-input', str(work), '-import', str(work)], env=env)
    raise SystemExit(result.returncode)
