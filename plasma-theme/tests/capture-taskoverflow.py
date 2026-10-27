#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
"""Check applications and +N at 1920x1080 in an isolated virtual KWin."""
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
parser.add_argument('--applications', action='store_true')
parser.add_argument('--launchers-file', type=Path)
parser.add_argument('--native-geometry', action='store_true')
parser.add_argument('--restore-config', type=Path)
parser.add_argument('--theme', choices=['light', 'dark'], default='light')
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
if args.restore_config:
    shutil.copy(args.restore_config, output / 'config/plasma-io.gitgud.wackyideas.desktop-appletsrc')
    shutil.copy(args.restore_config.parent / 'plasmashellrc', output / 'config/plasmashellrc')
shutil.copy('/usr/share/color-schemes/Breeze' + args.theme.title() + '.colors', output / 'config/kdeglobals')
with (output / 'config/kdeglobals').open('a') as handle:
    handle.write('\n[Icons]\nTheme=breeze\n')
launchers = ['applications:org.kde.dolphin.desktop', 'applications:org.kde.konsole.desktop']
for path in sorted(Path('/usr/share/applications').glob('*.desktop')):
    entry = 'applications:' + path.name
    if entry not in launchers and 'NoDisplay=true' not in path.read_text(errors='replace'):
        launchers.append(entry)
launchers = launchers[:30]
if args.launchers_file:
    fixture = json.loads(args.launchers_file.read_text())
    launchers = fixture['launchers'] if isinstance(fixture, dict) else fixture
assert len(launchers) == 30, '30 installed desktop entries required'
panel = output / 'data/plasma/shells/io.gitgud.wackyideas.desktop/contents/views/Panel.qml'
script = r'''
    property var overflowStates: BASELINE ? ["normal", "compact", "overflow"]
        : ["normal", "compact", "overflow", "overflow-open", "child-menu", "child-dismiss", "collapse", "model-shrink"].concat(CHECK_LAUNCHPAD ? ["launchpad", "search", "launcher-dismiss", "overflow-again", "launcher-from-overflow", "other-popup"] : [])
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
                const plugins = root.containment.plasmoid.applets.map(item => item.pluginName);
                console.log("APPLICATIONS_START " + JSON.stringify({plugins: plugins,
                    appletId: root.tasksApplet.plasmoid.id, launchers: root.tasksApplet.plasmoid.configuration.launchers}));
            }
            if (root.overflowStep < 0) { root.advanceOverflow(); return; }
            const app = root.tasksApplet;
            const label = root.overflowStates[root.overflowStep];
            const popup = ["overflow-open", "child-menu", "child-dismiss"].includes(label);
            const launcher = ["launchpad", "search", "launcher-from-overflow"].includes(label);
            const target = launcher ? app.launchpadWindow?.mainItem : popup ? app.fullRepresentationItem : root;
            if (!target || !target.width || !target.height) { console.log("OVERFLOW_FAILED " + label); return; }
            const origin = target.mapToGlobal(0, 0);
            const metrics = app.compactRepresentationItem?.metrics;
            function findNamed(item, name) {
                if (item.objectName === name) return item;
                for (const child of item.children) { const match = findNamed(child, name); if (match) return match; }
                return null;
            }
            const grid = launcher ? findNamed(target, "launchpadGrid") : null;
            const field = launcher ? findNamed(target, "launchpadSearch") : null;
            const record = {time: Date.now(), panelHeight: root.height,
                panelRects: root.containment.islandRects,
                available: root.containment.plasmoid.availableScreenRect,
                islandReplaced: app.islandReplaced, compactOpacity: app.compactRepresentationItem?.opacity,
                counterFocus: app.compactRepresentationItem?.overflowButton.activeFocus,
                panelActive: app.compactRepresentationItem?.Window.window.active,
                returnFocusPending: app.returnFocusPending,
                panelFocusItem: String(app.compactRepresentationItem?.Window.window.activeFocusItem),
                counterFocusItem: app.compactRepresentationItem?.Window.window.activeFocusItem === app.compactRepresentationItem?.overflowButton,
                applicationMenuOpen: app.applicationMenuOpen, appsCount: grid?.apps.length,
                totalApps: grid?.allApps.length, query: field?.text, label: label, x: origin.x, y: origin.y, width: target.width, height: target.height,
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
        if (label === "launchpad" || label === "launcher-from-overflow") app.toggleLaunchpad();
        if (label === "search") {
            function setQuery(item) {
                if (item.objectName === "launchpadSearch") item.text = "konsole";
                for (const child of item.children) setQuery(child);
            }
            setQuery(app.launchpadWindow.mainItem);
        }
        if (label === "launcher-dismiss") app.applicationMenuOpen = false;
        if (label === "overflow-again") { app.plasmoid.configuration.launchers = LAUNCHERS; Qt.callLater(() => app.openOverflow()); }
        if (label === "other-popup") {
            function openCalendar(item) {
                if (item.isAppletContainer && item.applet.plasmoid.pluginName === "io.gitgud.wackyideas.clockcalendar") item.applet.expanded = true;
                for (const child of item.children) openCalendar(child);
            }
            openCalendar(root.containment);
        }
        if (label === "normal" || label === "model-shrink") app.plasmoid.configuration.launchers = LAUNCHERS.slice(0, 4);
        if (label === "compact") app.plasmoid.configuration.launchers = LAUNCHERS.slice(0, COMPACT_PINS);
        if (label === "overflow") app.plasmoid.configuration.launchers = LAUNCHERS;
        if (label === "overflow-open") app.openOverflow();
        if (label === "child-menu") app.openTaskMenu(15, {AppName: "Application", IsLauncher: true});
        if (label === "child-dismiss" || label === "collapse") app.dismissPopup(true);
        overflowTimer.restart();
    }
'''.replace('COMPACT_PINS', str(10 if args.native_geometry else 12)).replace('CHECK_LAUNCHPAD', json.dumps(args.applications)).replace('BASELINE', json.dumps(args.baseline)).replace('LAUNCHERS', json.dumps(launchers)).replace('OUTPUT', json.dumps(str(output)))
if args.native_geometry:
    script += r'''
    property int motionCapture: 0
    Timer {
        interval: 25
        running: true
        repeat: true
        onTriggered: {
            if (!root.tasksApplet?.overflowOpen || !root.tasksApplet.expanded) return;
            const host = root.tasksApplet.fullRepresentationItem;
            if (!host) return;
            function findIsland(item) {
                if (item.objectName === "applicationsExpansion") return item;
                for (const child of item.children) { const found = findIsland(child); if (found) return found; }
                return null;
            }
            const island = findIsland(host);
            if (!island || !island.replaced || island.reveal <= 0 || island.reveal >= 1) return;
            const pos = host.mapToGlobal(0, 0);
            const record = {time: Date.now(), reveal: island.reveal, prefix: island.framePrefix,
                source: island.frameSource, width: island.surfaceWidth, height: island.surfaceHeight,
                bottom: pos.y + host.height, left: pos.x, hostHeight: host.height,
                hostWidth: host.width, replaced: root.tasksApplet.islandReplaced,
                compactOpacity: root.tasksApplet.compactRepresentationItem.opacity};
            console.log("REVEAL_FRAME " + JSON.stringify(record));
            const name = OUTPUT + "/motion-" + root.motionCapture++ + ".png";
            host.grabToImage(result => result.saveToFile(name));
        }
    }
'''.replace('OUTPUT', json.dumps(str(output)))
s = panel.read_text()
panel.write_text(s[:s.rfind('}')] + script + '\n}')
session_command = 'plasmashell --no-respawn --shell-plugin io.gitgud.wackyideas.desktop'
if args.native_geometry:
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
    session_command = str(session)
env = dict(os.environ, XDG_DATA_HOME=str(output/'data'), XDG_CONFIG_HOME=str(output/'config'),
           XDG_CACHE_HOME=str(output/'cache'), XDG_STATE_HOME=str(output/'state'),
           QT_LOGGING_RULES='kwin_scripting.debug=true', QSG_RHI_BACKEND='opengl', QT_QUICK_CONTROLS_STYLE='org.kde.desktop', QT_STYLE_OVERRIDE='Breeze')
env.pop('QT_QPA_PLATFORM', None)
env.pop('QT_QUICK_BACKEND', None)
logfile = output / 'run.log'
with logfile.open('w') as log:
    process = subprocess.Popen(['dbus-run-session', '--', 'kwin_wayland', '--virtual', '--width', '1920', '--height', '1080',
                                '--socket', 'sber-overflow-' + str(os.getpid()), '--no-lockscreen', '--no-global-shortcuts',
                                '--no-kactivities', '--exit-with-session',
                                session_command],
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
expected = 3 if args.baseline else 14 if args.applications else 8
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

if args.applications:
    startup = next(json.loads(line.split('APPLICATIONS_START ', 1)[1]) for line in logfile.read_text().splitlines() if 'APPLICATIONS_START ' in line)
    assert startup['plugins'].count('io.gitgud.wackyideas.smarttasks') == 1, startup
    assert 'p-connor.plasma-drawer' not in startup['plugins'], startup
    assert len(startup['plugins']) == 5, startup
    assert states['launchpad']['applicationMenuOpen'] and not states['launchpad']['expanded']
    assert states['launchpad']['width'] == 1920 and states['launchpad']['height'] == 1080
    assert states['launchpad']['totalApps'] > 0
    assert states['search']['query'] == 'konsole'
    assert 0 < states['search']['appsCount'] < states['search']['totalApps']
    assert not states['launcher-dismiss']['applicationMenuOpen']
    assert states['overflow-again']['overflowOpen']
    assert states['launcher-from-overflow']['applicationMenuOpen'] and not states['launcher-from-overflow']['overflowOpen']
    assert not states['other-popup']['applicationMenuOpen']
    (output / 'startup.json').write_text(json.dumps(startup, indent=2))
    if args.restore_config:
        import configparser
        previous = configparser.ConfigParser(interpolation=None, strict=False)
        previous.read(args.restore_config)
        section = next(section for section in previous.sections()
            if previous[section].get('plugin') == 'io.gitgud.wackyideas.smarttasks')
        assert startup['appletId'] == int(section.rsplit('[', 1)[1].rstrip(']'))
        assert startup['launchers'] == previous[section + '][Configuration][General']['launchers'].split(',')
    print('Single applet, Launchpad, search and popup exclusion passed', flush=True)

if args.native_geometry:
    lines = logfile.read_text().splitlines()
    native_records = [json.loads(line.split('NATIVE ', 1)[1]) for line in lines if 'NATIVE ' in line]
    frames = [json.loads(line.split('REVEAL_FRAME ', 1)[1]) for line in lines if 'REVEAL_FRAME ' in line]
    assert frames and native_records
    for record in records:
        latest = {}
        for item in native_records:
            if item['time'] <= record['time']: latest[item['id']] = item
        clients = {item['caption'].rsplit(' - ', 1)[-1]: item['geometry'] for item in latest.values()
            if item['caption'].startswith('Sber expansion probe - ')}
        assert clients['maximized']['height'] == 992, (record['label'], clients)
        assert clients['fullscreen']['height'] == 1080, (record['label'], clients)
        assert record['panelHeight'] == 88 and record['available']['height'] == 992
        panels = [item['geometry'] for item in latest.values()
            if item['resourceClass'] == 'plasmashell' and not item['caption']
            and item['geometry']['width'] == 1920 and item['geometry']['height'] < 1080]
        assert panels and all(panel == {'x': 0, 'y': 992, 'width': 1920, 'height': 88} for panel in panels)
        record['nativePanel'] = panels[-1]
        record['nativeClients'] = clients
    assert all(frame['bottom'] == 1072 and frame['left'] == 96 for frame in frames), frames
    assert all(frame['replaced'] and frame['compactOpacity'] == 0 for frame in frames), frames
    assert states['overflow-open']['islandReplaced']
    assert len(states['overflow-open']['panelRects']) == len(states['overflow']['panelRects']) - 1
    assert len(states['collapse']['panelRects']) == len(states['overflow']['panelRects'])
    assert not states['collapse']['islandReplaced'] and states['collapse']['compactOpacity'] == 1
    assert states['collapse']['counterFocus']
    (output / 'geometry.json').write_text(json.dumps(records, indent=2))
    (output / 'motion.json').write_text(json.dumps(frames, indent=2))
    (output / 'native.json').write_text(json.dumps(native_records, indent=2))
    print('Native clients 992/1080, panel/work area, animation anchor, handoff and counter focus passed', flush=True)
