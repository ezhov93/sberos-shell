#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
"""Capture +N at the fixed 1920x1080 light target in an isolated virtual KWin."""
import argparse
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import time

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--source', required=True)
parser.add_argument('--output', required=True)
parser.add_argument('--baseline', action='store_true')
args = parser.parse_args()
source = Path(args.source).resolve()
output = Path(args.output).resolve()
output.mkdir(parents=True, exist_ok=False)
for name in ['data', 'config', 'cache', 'state']:
    (output / name).mkdir()
for kind in ['plasmoids', 'shells', 'layout-templates']:
    for package in (source / kind).iterdir():
        if (package / 'metadata.json').exists():
            plugin = json.loads((package / 'metadata.json').read_text())['KPlugin']['Id']
            shutil.copytree(package, output / 'data/plasma' / kind / plugin)
shutil.copy('/usr/share/color-schemes/BreezeLight.colors', output / 'config/kdeglobals')
with (output / 'config/kdeglobals').open('a') as handle:
    handle.write('\n[Icons]\nTheme=breeze\n')
launchers = ['applications:org.kde.dolphin.desktop', 'applications:org.kde.konsole.desktop']
for path in sorted(Path('/usr/share/applications').glob('*.desktop')):
    entry = 'applications:' + path.name
    if entry not in launchers and 'NoDisplay=true' not in path.read_text(errors='replace'):
        launchers.append(entry)
launchers = launchers[:30]
assert len(launchers) == 30, '30 installed desktop entries required'
panel = output / 'data/plasma/shells/io.gitgud.wackyideas.desktop/contents/views/Panel.qml'
script = r'''
    property var overflowStates: BASELINE ? ["normal", "compact", "overflow"]
        : ["normal", "compact", "overflow", "overflow-open", "child-menu", "child-dismiss", "collapse", "model-shrink"]
    property int overflowStep: -1
    property var tasksApplet: null
    property var overflowRecords: []
    Timer {
        id: overflowTimer
        running: true
        interval: 1200
        onTriggered: {
            if (!root.containment) { restart(); return; }
            if (!root.tasksApplet) {
                function visit(item) {
                    if (item.isAppletContainer && item.applet.plasmoid.pluginName === "io.gitgud.wackyideas.smarttasks")
                        root.tasksApplet = item.applet;
                    for (const child of item.children) visit(child);
                }
                visit(root.containment);
                if (!root.tasksApplet) { restart(); return; }
                // Captures cannot establish native outside-click behaviour.
                root.tasksApplet.hideOnWindowDeactivate = false;
            }
            if (root.overflowStep < 0) { root.advanceOverflow(); return; }
            const app = root.tasksApplet;
            const label = root.overflowStates[root.overflowStep];
            const popup = ["overflow-open", "child-menu", "child-dismiss"].includes(label);
            const target = popup ? app.fullRepresentationItem : root;
            if (!target || !target.width || !target.height) { console.log("OVERFLOW_FAILED " + label); return; }
            const origin = target.mapToGlobal(0, 0);
            const metrics = app.compactRepresentationItem?.metrics;
            const record = {label: label, x: origin.x, y: origin.y, width: target.width, height: target.height,
                expanded: app.expanded, overflowOpen: app.overflowOpen, childOpen: app.childOpen,
                count: metrics?.count, visibleCount: metrics?.visibleCount, hiddenCount: metrics?.hiddenCount,
                compact: metrics?.compact, appletWidth: app.width, cellSize: app.cellSize};
            console.log("OVERFLOW " + JSON.stringify(record));
            target.grabToImage(result => {
                result.saveToFile(OUTPUT + "/" + label + ".png");
                root.advanceOverflow();
            });
        }
    }
    function advanceOverflow() {
        root.overflowStep++;
        if (root.overflowStep >= root.overflowStates.length) {
            root.tasksApplet.expanded = false;
            console.log("OVERFLOW_DONE");
            return;
        }
        const label = root.overflowStates[root.overflowStep];
        const app = root.tasksApplet;
        if (label === "model-shrink") app.openOverflow();
        if (label === "normal" || label === "model-shrink") app.plasmoid.configuration.launchers = LAUNCHERS.slice(0, 4);
        if (label === "compact") app.plasmoid.configuration.launchers = LAUNCHERS.slice(0, 12);
        if (label === "overflow") app.plasmoid.configuration.launchers = LAUNCHERS;
        if (label === "overflow-open") app.openOverflow();
        if (label === "child-menu") app.openTaskMenu(15, {AppName: "Application", IsLauncher: true});
        if (label === "child-dismiss" || label === "collapse") app.dismissPopup(true);
        overflowTimer.restart();
    }
'''.replace('BASELINE', json.dumps(args.baseline)).replace('LAUNCHERS', json.dumps(launchers)).replace('OUTPUT', json.dumps(str(output)))
s = panel.read_text()
panel.write_text(s[:s.rfind('}')] + script + '\n}')
env = dict(os.environ, XDG_DATA_HOME=str(output/'data'), XDG_CONFIG_HOME=str(output/'config'),
           XDG_CACHE_HOME=str(output/'cache'), XDG_STATE_HOME=str(output/'state'),
           QSG_RHI_BACKEND='opengl', QT_QUICK_CONTROLS_STYLE='org.kde.desktop', QT_STYLE_OVERRIDE='Breeze')
env.pop('QT_QPA_PLATFORM', None)
env.pop('QT_QUICK_BACKEND', None)
logfile = output / 'run.log'
with logfile.open('w') as log:
    process = subprocess.Popen(['dbus-run-session', '--', 'kwin_wayland', '--virtual', '--width', '1920', '--height', '1080',
                                '--socket', 'sber-overflow-' + str(os.getpid()), '--no-lockscreen', '--no-global-shortcuts',
                                '--no-kactivities', '--exit-with-session',
                                'plasmashell --no-respawn --shell-plugin io.gitgud.wackyideas.desktop'],
                               env=env, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
    print(f'Isolated process group: {process.pid}', flush=True)
    try:
        deadline = time.monotonic() + 25
        while process.poll() is None and time.monotonic() < deadline:
            if 'OVERFLOW_DONE' in logfile.read_text():
                break
            time.sleep(.2)
    finally:
        if process.poll() is None:
            os.killpg(process.pid, signal.SIGTERM)
            try:
                process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait(timeout=3)
        print(f'Process group {process.pid} stopped', flush=True)
records = [json.loads(line.split('OVERFLOW ', 1)[1]) for line in logfile.read_text().splitlines() if 'OVERFLOW ' in line]
(output/'geometry.json').write_text(json.dumps(records, indent=2))
expected = 3 if args.baseline else 8
assert len(records) == expected, f'Incomplete captures: {logfile}'
if not args.baseline:
    states = {record['label']: record for record in records}
    assert not states['normal']['compact'] and states['normal']['hiddenCount'] == 0
    assert states['compact']['compact'] and states['compact']['hiddenCount'] == 0
    assert states['overflow']['hiddenCount'] > 0
    assert states['overflow-open']['overflowOpen'] and states['overflow-open']['expanded']
    assert states['child-menu']['childOpen']
    assert states['child-dismiss']['overflowOpen'] and not states['child-dismiss']['childOpen']
    assert not states['collapse']['expanded']
    assert not states['model-shrink']['overflowOpen'] and states['model-shrink']['hiddenCount'] == 0
print(f'{len(records)} captures and state checks passed', flush=True)
