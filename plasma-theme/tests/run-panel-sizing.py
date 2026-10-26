#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
"""Capture the real panel in a temporary Plasma profile and private D-Bus session."""
import argparse
import json
import os
import pathlib
import shutil
import subprocess
import signal
import time
p = argparse.ArgumentParser()
p.add_argument('--source', required=True)
p.add_argument('--output', required=True)
p.add_argument('--platform', choices=['wayland'], default='wayland')
p.add_argument('--capture-only', action='store_true')
a = p.parse_args()
source = pathlib.Path(a.source).resolve()
output = pathlib.Path(a.output).resolve()
output.mkdir(parents=True, exist_ok=False)
for theme in ['light', 'dark']:
    profile = output / theme
    profile.mkdir(exist_ok=True)
    for d in ['data', 'config', 'cache', 'state']:
        (profile / d).mkdir(exist_ok=True)
    for folder, kind in [('plasmoids', 'plasmoids'), ('shells', 'shells'), ('layout-templates', 'layout-templates')]:
        for package in (source / folder).iterdir():
            if not (package / 'metadata.json').exists():
                continue
            plugin = json.loads((package / 'metadata.json').read_text())['KPlugin']['Id']
            target = profile / 'data/plasma' / kind / plugin
            shutil.copytree(package, target, dirs_exist_ok=True)
    config = profile / 'config'
    shutil.copy('/usr/share/color-schemes/Breeze' + ('Dark' if theme == 'dark' else 'Light') + '.colors', config / 'kdeglobals')
    with (config / 'kdeglobals').open('a') as f:
        f.write('\n[Icons]\nTheme=breeze\n')
    shell = profile / 'data/plasma/shells/io.gitgud.wackyideas.desktop'
    panel = shell / 'contents/views/Panel.qml'
    s = panel.read_text()
    idx = s.rfind('}')
    states = [{'height': h, 'label': str(h)} for h in [32, 48, 64, 72, 96, 120]]
    states += [{'height': 120, 'label': 'overflow', 'launchers': ['applications:' + x + '.desktop' for x in ['org.kde.dolphin', 'org.kde.konsole', 'systemsettings', 'org.kde.kate', 'org.kde.gwenview', 'org.kde.okular', 'org.kde.ark', 'org.kde.kcalc', 'org.kde.spectacle', 'org.kde.kwrite', 'org.kde.khelpcenter', 'org.kde.plasma-systemmonitor', 'firefox', 'chromium', 'org.kde.kolourpaint', 'org.kde.filelight']]}, {'height': 72, 'label': 'few', 'launchers': ['applications:org.kde.dolphin.desktop', 'applications:org.kde.konsole.desktop']}, {'height': 72, 'label': 'many', 'launchers': ['applications:' + x + '.desktop' for x in ['org.kde.dolphin', 'org.kde.konsole', 'systemsettings', 'org.kde.kate', 'org.kde.gwenview', 'org.kde.okular', 'org.kde.ark', 'org.kde.kcalc', 'org.kde.spectacle']]}, {'height': 72, 'label': 'shrunk', 'launchers': ['applications:org.kde.dolphin.desktop', 'applications:org.kde.konsole.desktop']}]
    instrument = r"""
    property var sizingStates: STATES
    property int sizingStep: -1
    Timer {
        id: sizingTimer
        interval: 1300
        running: true
        repeat: false
        onTriggered: {
            if (!root.containment) { restart(); return; }
            if (root.sizingStep >= 0) {
                const state = root.sizingStates[root.sizingStep];
                const records = [];
                function visit(item) {
                    if (item.isAppletContainer && item.visible) {
                        const pos = item.mapToItem(root, 0, 0);
                        records.push({plugin: item.applet.plasmoid.pluginName, x: pos.x, y: pos.y,
                            width: item.width, height: item.height, parentWidth: item.parent.width, margins: [item.Layout.leftMargin,item.Layout.rightMargin],
                            preferred: item.applet.Layout.preferredWidth,
                            minimum: item.applet.Layout.minimumWidth});
                    }
                    for (const child of item.children) visit(child);
                }
                visit(root.containment);
                console.log("SIZING " + JSON.stringify({label: state.label, thickness: panel.thickness,
                    width: root.width, height: root.height, dpi: root.dpi, screenDpi: Screen.devicePixelRatio, containmentWidth: root.containment.width, preferredWidth: root.containment.Layout.preferredWidth, applets: records}));
                root.grabToImage(result => {
                    result.saveToFile(OUTPUT + "/" + state.label + ".png");
                    root.advanceSizing();
                }, Qt.size(root.width * root.dpi, root.height * root.dpi));
            } else {
                root.advanceSizing();
            }
        }
    }
    function advanceSizing() {
        root.sizingStep++;
        if (root.sizingStep >= root.sizingStates.length) {
            exitTimer.start();
            return;
        }
        const next = root.sizingStates[root.sizingStep];
        panel.thickness = next.height;
        if (next.launchers) {
            for (const applet of root.containment.plasmoid.applets) {
                if (applet.pluginName === "io.gitgud.wackyideas.smarttasks")
                    applet.configuration.launchers = next.launchers;
            }
        }
        sizingTimer.restart();
    }
    Timer { id: exitTimer; interval: 300; onTriggered: console.log("SIZING_DONE") }
""".replace('STATES', json.dumps(states)).replace('OUTPUT', json.dumps(str(profile)))
    panel.write_text(s[:idx] + instrument + s[idx:])
    env = dict(os.environ, XDG_DATA_HOME=str(profile / 'data'), XDG_CONFIG_HOME=str(config), XDG_CACHE_HOME=str(profile / 'cache'), XDG_STATE_HOME=str(profile / 'state'), QT_QPA_PLATFORM=a.platform, QSG_RHI_BACKEND='opengl', QT_QUICK_CONTROLS_STYLE='org.kde.desktop', QT_STYLE_OVERRIDE='Breeze', KDE_DEBUG='1', QT_LOGGING_RULES='qt.qml.connections=false')
    env.pop('QT_QUICK_BACKEND', None)
    with (profile / 'run.log').open('w') as log:
        process = subprocess.Popen(['dbus-run-session', '--', 'plasmashell', '--no-respawn', '--shell-plugin', 'io.gitgud.wackyideas.desktop'], env=env, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
        deadline = time.monotonic() + 30
        try:
            while process.poll() is None and time.monotonic() < deadline:
                if 'SIZING_DONE' in (profile / 'run.log').read_text():
                    break
                time.sleep(0.2)
        finally:
            if process.poll() is None:
                os.killpg(process.pid, signal.SIGTERM)
                try:
                    process.wait(timeout=3)
                except subprocess.TimeoutExpired:
                    os.killpg(process.pid, signal.SIGKILL)
                    process.wait(timeout=3)
    print(theme, 'exit', process.returncode)
    lines = (profile / 'run.log').read_text().splitlines()
    records = [json.loads(line.split('SIZING ', 1)[1]) for line in lines if 'SIZING ' in line]
    (profile / 'geometry.json').write_text(json.dumps(records, indent=2))
    print(theme, len(records), 'captures')
    for line in lines:
        if 'Binding loop' in line or 'Error' in line or 'is not defined' in line:
            print(line[:500])
    if len(records) != len(states):
        raise SystemExit(f"{theme}: incomplete capture; see {profile / 'run.log'}")
    if not a.capture_only:
        for record in records:
            applets = sorted(record['applets'], key=lambda item: item['x'])
            for index, item in enumerate(applets):
                assert abs(item['height'] - record['thickness']) < 1, (record['label'], item)
                assert item['x'] >= -1 and item['x'] + item['width'] <= record['width'] + 1, (record['label'], item)
                if index:
                    assert applets[index - 1]['x'] + applets[index - 1]['width'] <= item['x'] + 1, (record['label'], item)
            center = next((item for item in applets if item['plugin'] == 'com.mcc45tr.filesearch'))
            assert abs(center['x'] + center['width'] / 2 - record['width'] / 2) <= 1, record
        by_label = {record['label']: record for record in records}
        assert by_label['many']['width'] > by_label['few']['width']
        assert by_label['shrunk']['width'] < by_label['many']['width']
        overflow = by_label['overflow']
        tasks = next((item for item in overflow['applets'] if item['plugin'] == 'io.gitgud.wackyideas.smarttasks'))
        assert tasks['width'] < tasks['preferred'], tasks
        print(theme, 'geometry checks passed')
