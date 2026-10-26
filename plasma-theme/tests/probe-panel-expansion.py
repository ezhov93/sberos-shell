#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
"""Compare panel expansion strategies in private KWin with maximized/fullscreen clients."""
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
for entry in sorted(Path('/usr/share/applications').glob('*.desktop')):
    launcher = 'applications:' + entry.name
    if launcher not in launchers and 'NoDisplay=true' not in entry.read_text(errors='replace'):
        launchers.append(launcher)
launchers = launchers[:30]

panel = output / 'data/plasma/shells/io.gitgud.wackyideas.desktop/contents/views/Panel.qml'
text = panel.read_text()
text = text.replace('readonly property int fixedTopFloatingPadding: 0',
                    'property int probeTopPadding: 0\n    readonly property int fixedTopFloatingPadding: probeTopPadding')
text = text.replace('anchors.fill: isOpaque ? opaqueItem : translucentItem',
                    'anchors.left: parent.left\n        anchors.right: parent.right\n        anchors.bottom: parent.bottom')
text = text.replace('rects: root.containment?.islandRects ?? []',
                    'rects: (root.containment?.islandRects ?? []).map(rect => ({x: rect.x, y: rect.y + root.height - panel.thickness, width: rect.width, height: rect.height, radius: rect.radius}))')
instrument = r'''
    property var probeStates: ["baseline", "thickness", "restore-thickness", "window-height", "window-position", "geometry-refresh", "restore-height",
        "extra-padding", "restore-padding", "overlay", "close-overlay"]
    property int probeStep: -1
    property var tasksApplet: null
    property var probeRecords: []
    Timer {
        id: probeTimer
        interval: 1600
        running: true
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
                root.tasksApplet.hideOnWindowDeactivate = false;
                root.tasksApplet.plasmoid.configuration.launchers = LAUNCHERS;
            }
            if (root.probeStep < 0) { root.advanceProbe(); return; }
            const label = root.probeStates[root.probeStep];
            const app = root.tasksApplet;
            const popup = app.fullRepresentationItem?.Window.window;
            const record = {time: Date.now(), label: label, thickness: panel.thickness,
                window: {x: panel.x, y: panel.y, width: panel.width, height: panel.height},
                qmlHeight: root.height, screen: panel.screenGeometry,
                available: root.containment.plasmoid.availableScreenRect,
                topPadding: root.probeTopPadding, expanded: app.expanded,
                popup: label === "overlay" ? {x: popup?.x, y: popup?.y, width: popup?.width, height: popup?.height} : null};
            console.log("EXPANSION " + JSON.stringify(record));
            root.grabToImage(result => {
                result.saveToFile(OUTPUT + "/" + label + ".png");
                root.advanceProbe();
            });
        }
    }
    function advanceProbe() {
        root.probeStep++;
        if (root.probeStep >= root.probeStates.length) { console.log("EXPANSION_DONE"); return; }
        const label = root.probeStates[root.probeStep];
        if (label === "baseline" || label === "restore-thickness") panel.thickness = 88;
        if (label === "thickness") panel.thickness = 168;
        if (label === "window-height") panel.height = 168;
        if (label === "window-position") panel.y = panel.screenGeometry.y + panel.screenGeometry.height - panel.height;
        if (label === "geometry-refresh") { panel.offset = 1; panel.offset = 0; }
        if (label === "restore-height") panel.height = 88;
        if (label === "extra-padding" || label === "restore-padding") {
            root.probeTopPadding = label === "extra-padding" ? 80 : 0;
            root.floatingnessTargetChanged();
        }
        if (label === "overlay") {
            root.tasksApplet.openOverflow();
            Qt.callLater(() => {
                const view = root.tasksApplet.fullRepresentationItem;
                for (const child of view.children) {
                    if (child.overlapPanel !== undefined) child.overlapPanel = true;
                }
            });
        }
        if (label === "close-overlay") root.tasksApplet.expanded = false;
        probeTimer.restart();
    }
'''.replace('LAUNCHERS', json.dumps(launchers)).replace('OUTPUT', json.dumps(str(output)))
panel.write_text(text[:text.rfind('}')] + instrument + '\n}')
client = output / 'client.qml'
client.write_text('''import QtQuick
import QtQuick.Window
Window {
    id: maximized
    title: "Sber expansion probe - maximized"
    color: "#26374a"
    flags: Qt.Window | Qt.FramelessWindowHint
    visible: true
    visibility: Window.Maximized
    Window {
        id: fullscreen
        title: "Sber expansion probe - fullscreen"
        transientParent: null
        color: "#344c38"
        visible: true
        visibility: Window.FullScreen
    }
    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: console.log("CLIENT " + JSON.stringify({time: Date.now(),
            maximized: {x: maximized.x, y: maximized.y, width: maximized.width, height: maximized.height, visibility: maximized.visibility},
            fullscreen: {x: fullscreen.x, y: fullscreen.y, width: fullscreen.width, height: fullscreen.height, visibility: fullscreen.visibility}}))
    }
}
''')
native = output / 'native.js'
native.write_text('''function report(window) {
    print("NATIVE " + JSON.stringify({time: Date.now(), id: String(window.internalId),
        caption: window.caption, resourceClass: window.resourceClass,
        geometry: window.frameGeometry, fullscreen: window.fullScreen}));
}
function watch(window) {
    report(window);
    window.frameGeometryChanged.connect(function() { report(window); });
}
workspace.windowAdded.connect(watch);
workspace.windowList().forEach(watch);
''')
session = output / 'session.sh'
session.write_text('#!/bin/sh\n'
                   'probe_id="$(qdbus6 org.kde.KWin /Scripting loadScript "' + str(native) + '")"\n'
                   'qdbus6 org.kde.KWin "/Scripting/Script$probe_id" run\n'
                   '/usr/lib/qt6/bin/qml --apptype gui "' + str(client) + '" &\n'
                   'plasmashell --no-respawn --shell-plugin io.gitgud.wackyideas.desktop &\nwait $!\n')
session.chmod(0o755)
env = dict(os.environ, XDG_DATA_HOME=str(output/'data'), XDG_CONFIG_HOME=str(output/'config'),
           XDG_CACHE_HOME=str(output/'cache'), XDG_STATE_HOME=str(output/'state'),
           QT_LOGGING_RULES='kwin_scripting.debug=true', QSG_RHI_BACKEND='opengl', QT_QUICK_CONTROLS_STYLE='org.kde.desktop', QT_STYLE_OVERRIDE='Breeze')
env.pop('QT_QPA_PLATFORM', None)
env.pop('QT_QUICK_BACKEND', None)
logfile = output / 'run.log'
with logfile.open('w') as log:
    process = subprocess.Popen(['dbus-run-session', '--', 'kwin_wayland', '--virtual', '--width', '1920', '--height', '1080',
                                '--socket', 'sber-expansion-' + str(os.getpid()), '--no-lockscreen', '--no-global-shortcuts',
                                '--no-kactivities', '--exit-with-session', str(session)],
                               env=env, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
    print(f'Isolated process group: {process.pid}', flush=True)
    try:
        deadline = time.monotonic() + 30
        while process.poll() is None and time.monotonic() < deadline:
            if 'EXPANSION_DONE' in logfile.read_text():
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
lines = logfile.read_text().splitlines()
records = [json.loads(line.split('EXPANSION ', 1)[1]) for line in lines if 'EXPANSION ' in line]
clients = [json.loads(line.split('CLIENT ', 1)[1]) for line in lines if 'CLIENT ' in line]
assert len(records) == 11, f'Incomplete panel records: {logfile}'
assert clients, f'No client measurements: {logfile}'
native_records = [json.loads(line.split('NATIVE ', 1)[1]) for line in lines if 'NATIVE ' in line]
assert native_records, f'No native KWin measurements: {logfile}'
for record in records:
    prior = [item for item in clients if item['time'] <= record['time']]
    assert prior, f'No settled client data: {record}'
    record['clients'] = prior[-1]
    latest = {}
    for item in native_records:
        if item['time'] <= record['time']:
            latest[item['id']] = item
    record['nativeWindows'] = list(latest.values())
    native_panels = [item['geometry'] for item in latest.values()
                     if item['resourceClass'] == 'plasmashell' and not item['caption']
                     and item['geometry']['width'] == 1920 and item['geometry']['height'] < 1080]
    assert len(native_panels) == 1, f'Ambiguous native panel: {record}'
    record['nativePanel'] = native_panels[0]
(output / 'geometry.json').write_text(json.dumps(records, indent=2))
for record in records:
    print(record['label'], 'panel', record['window']['height'], 'thickness', record['thickness'],
          'available', record['available']['height'], 'maximized', record['clients']['maximized']['height'],
          'fullscreen', record['clients']['fullscreen']['height'], flush=True)

states = {record['label']: record for record in records}
assert states['baseline']['clients']['maximized']['height'] == 992
assert states['thickness']['clients']['maximized']['height'] == 912
assert all(record['clients']['fullscreen']['height'] == 1080 for record in records)
assert states['overlay']['clients']['maximized'] == states['baseline']['clients']['maximized']
assert states['overlay']['available'] == states['baseline']['available']
assert states['overlay']['window'] == states['baseline']['window']
print('Work-area controls and overlay invariance passed', flush=True)
assert states['window-height']['nativePanel']['y'] + states['window-height']['nativePanel']['height'] > 1080
assert states['window-position']['window']['y'] != states['window-position']['nativePanel']['y']
assert states['extra-padding']['available']['height'] != states['extra-padding']['clients']['maximized']['height']
print('Direct resize clipping and padding disagreement reproduced', flush=True)
