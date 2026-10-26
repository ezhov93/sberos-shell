#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
"""Capture only the Smart Panel target and its popups; never vary screen or grid size."""
import argparse
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import time

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--source', required=True)
p.add_argument('--output', required=True)
p.add_argument('--states', nargs='+', choices=['panel', 'sber', 'power', 'search', 'notifications', 'quick', 'calendar', 'launcher'], default=['panel'])
a = p.parse_args()
source = Path(a.source).resolve()
output = Path(a.output).resolve()
output.mkdir(parents=True, exist_ok=False)
for theme in ['light']:
    profile = output / theme
    for name in ['data', 'config', 'cache', 'state']:
        (profile / name).mkdir(parents=True)
    for kind in ['plasmoids', 'shells', 'layout-templates']:
        for package in (source / kind).iterdir():
            if (package / 'metadata.json').exists():
                plugin = json.loads((package / 'metadata.json').read_text())['KPlugin']['Id']
                shutil.copytree(package, profile / 'data/plasma' / kind / plugin)
    shutil.copy('/usr/share/color-schemes/Breeze' + ('Dark' if theme == 'dark' else 'Light') + '.colors', profile / 'config/kdeglobals')
    with (profile / 'config/kdeglobals').open('a') as f:
        f.write('\n[Icons]\nTheme=breeze\n')
    panel = profile / 'data/plasma/shells/io.gitgud.wackyideas.desktop/contents/views/Panel.qml'
    s = panel.read_text()
    instrument = r'''
    property var captureStates: [
        {label: "panel"},
        {label: "sber", plugin: "io.gitgud.wackyideas.sbermenu"},
        {label: "power", plugin: "io.gitgud.wackyideas.sbermenu", power: true},
        {label: "search", plugin: "com.mcc45tr.filesearch"},
        {label: "notifications", plugin: "com.mcc45tr.filesearch"},
        {label: "quick", plugin: "KdeControlStation"},
        {label: "calendar", plugin: "io.gitgud.wackyideas.clockcalendar"},
        {label: "launcher", plugin: "p-connor.plasma-drawer"}
    ].filter(state => SELECTED.includes(state.label))
    property int captureStep: -1
    property var captureApplet: null
    property var captureItems: []
    Timer {
        id: captureTimer
        interval: 1500
        running: true
        onTriggered: {
            if (!root.containment) { restart(); return; }
            if (!root.captureItems.length) {
                function visit(item) {
                    if (item.isAppletContainer) { root.captureItems.push(item.applet); item.applet.hideOnWindowDeactivate = false; }
                    for (const child of item.children) visit(child);
                }
                visit(root.containment);
            }
            if (root.captureStep >= 0) {
                const state = root.captureStates[root.captureStep];
                let target = root;
                if (state.plugin) {
                    target = root.captureApplet?.fullRepresentationItem;
                    if (state.label === "launcher") target = target?.dashWindow?.mainItem;
                }
                if (!target || target.width <= 0 || target.height <= 0) {
                    console.log("CAPTURE_FAILED " + state.label);
                    root.advanceCapture();
                    return;
                }
                const origin = target.mapToGlobal(0, 0);
                console.log("CAPTURE " + JSON.stringify({label: state.label, x: origin.x, y: origin.y, width: target.width, height: target.height,
                    thickness: panel.thickness, screen: panel.screenGeometry, dpi: root.dpi}));
                const grabbing = target.grabToImage(result => {
                    result.saveToFile(OUTPUT + "/" + state.label + ".png");
                    root.advanceCapture();
                });
                if (!grabbing) { console.log("CAPTURE_FAILED " + state.label); root.advanceCapture(); }
            } else root.advanceCapture();
        }
    }
    function advanceCapture() {
        root.captureStep++;
        if (root.captureStep >= root.captureStates.length) {
            for (const applet of root.captureItems) applet.expanded = false;
            console.log("CAPTURE_DONE");
            return;
        }
        const state = root.captureStates[root.captureStep];
        root.captureApplet = state.plugin ? root.captureItems.find(item => item.plasmoid.pluginName === state.plugin) : null;
        for (const applet of root.captureItems) if (applet !== root.captureApplet) {
            applet.expanded = false;
            if (applet.applicationMenuOpen !== undefined) applet.applicationMenuOpen = false;
        }
        if (root.captureApplet) {
            if (root.captureApplet.notificationsOpen !== undefined) root.captureApplet.notificationsOpen = state.label === "notifications";
            if (state.label !== "launcher") root.captureApplet.expanded = true;
            if (state.power) root.captureApplet.powerMenuOpen = true;
            if (state.label === "launcher") root.captureApplet.fullRepresentationItem.dashWindow.toggleLauncher();
        }
        captureTimer.restart();
    }
'''.replace('OUTPUT', json.dumps(str(profile))).replace('SELECTED', json.dumps(a.states))
    panel.write_text(s[:s.rfind('}')] + instrument + '\n}')
    env = dict(os.environ, XDG_DATA_HOME=str(profile/'data'), XDG_CONFIG_HOME=str(profile/'config'),
               XDG_CACHE_HOME=str(profile/'cache'), XDG_STATE_HOME=str(profile/'state'), QT_QPA_PLATFORM='wayland',
               QSG_RHI_BACKEND='opengl', QT_QUICK_CONTROLS_STYLE='org.kde.desktop', QT_STYLE_OVERRIDE='Breeze')
    env.pop('QT_QUICK_BACKEND', None)
    logfile = profile / 'run.log'
    with logfile.open('w') as log:
        process = subprocess.Popen(['dbus-run-session', '--', 'plasmashell', '--no-respawn', '--shell-plugin', 'io.gitgud.wackyideas.desktop'],
                                   env=env, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
        print(f'{theme}: isolated process group {process.pid}', flush=True)
        try:
            deadline = time.monotonic() + 25
            while process.poll() is None and time.monotonic() < deadline:
                if 'CAPTURE_DONE' in logfile.read_text():
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
    records = [json.loads(line.split('CAPTURE ', 1)[1]) for line in logfile.read_text().splitlines() if 'CAPTURE ' in line]
    (profile/'geometry.json').write_text(json.dumps(records, indent=2))
    print(f'{theme}: {len(records)} target-state captures; process group stopped', flush=True)
    if len(list(profile.glob('*.png'))) != len(a.states):
        raise SystemExit(f'Incomplete captures: {logfile}')
