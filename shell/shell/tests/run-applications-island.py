#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Test the expanding applications island with a temporary config and private D-Bus."""
import argparse
import configparser
import json
import os
from pathlib import Path
import signal
import shlex
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--binary', type=Path, default=root/'build/bin/sirca-shell')
parser.add_argument('--output', type=Path, required=True)
parser.add_argument('--baseline', action='store_true')
parser.add_argument('--wayland', action='store_true', help='Use private KWin and real TaskManager with maximized/fullscreen clients')
args = parser.parse_args()
output = args.output.resolve()
output.mkdir(parents=True, exist_ok=False)
launchers = ['applications:org.kde.dolphin.desktop', 'applications:org.kde.konsole.desktop']
for entry in sorted(Path('/usr/share/applications').glob('*.desktop')):
    url = 'applications:' + entry.name
    if url not in launchers and 'NoDisplay=true' not in entry.read_text(errors='replace'):
        launchers.append(url)
launchers = launchers[:30]
entries = []
for url in launchers:
    desktop = configparser.ConfigParser(interpolation=None, strict=False)
    desktop.read('/usr/share/applications/' + url.removeprefix('applications:'))
    entry = desktop['Desktop Entry']
    entries.append({'AppName':entry.get('Name',url),'decoration':entry.get('Icon','application-x-executable'),
        'LauncherUrlWithoutIcon':url,'AppId':url.removeprefix('applications:').removesuffix('.desktop'),
        'IsLauncher':True,'IsGroupParent':False,'IsActive':False,'ChildCount':0,
        'IsStartup':False,'IsDemandingAttention':False,'IsMinimized':False})
with tempfile.TemporaryDirectory(prefix='sirca-applications-') as temporary:
    work = Path(temporary)
    config = work/'config/sirca-shell'
    config.mkdir(parents=True)
    for name in ['data', 'cache', 'state']:
        (work/name).mkdir()
    (config/'config.json').write_text(json.dumps({'mode':'light','dockDodge':False,'dockVisibility':'always',
        'dockFullscreenMode':'keep','welcomed':True,'selfTestNotify':False,'ownWallpaper':False,'launchers':launchers}))
    screen = work/'screen.json'
    screen.write_text(json.dumps({'screens':[{'name':'applications-test','width':1920,'height':1080,
        'logicalDpi':96,'logicalBaseDpi':96}]}))
    fixture = work/'Applications.qml'
    fixture.write_text((root/'tests/panel/Applications.qml').read_text()
        .replace('BASELINE_MODE', json.dumps(args.baseline)).replace('OUTPUT_DIR', str(output))
        .replace('STRESS_LAUNCHERS', json.dumps(launchers)).replace('MOCK_TASKS',json.dumps(not args.wayland))
        .replace('STRESS_ENTRIES',json.dumps(entries)))
    env = dict(os.environ, QT_QPA_PLATFORM='offscreen:configfile='+str(screen), QT_QUICK_BACKEND='software',
        QT_STYLE_OVERRIDE='Breeze', XDG_CONFIG_HOME=str(work/'config'), XDG_DATA_HOME=str(work/'data'),
        XDG_CACHE_HOME=str(work/'cache'), XDG_STATE_HOME=str(work/'state'))
    command = ['dbus-run-session','--',str(args.binary.resolve()),'--qml-test',str(fixture)]
    if args.wayland:
        client = work/'client.qml'
        client.write_text("""import QtQuick
import QtQuick.Window
Window {
    id: maximized
    title: "Island probe - maximized"
    flags: Qt.Window | Qt.FramelessWindowHint
    visible: true
    visibility: Window.Maximized
    Window {
        id: fullscreen
        title: "Island probe - fullscreen"
        transientParent: null
        visible: true
        visibility: Window.FullScreen
    }
    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: console.log("CLIENT " + JSON.stringify({time: Date.now(),
            maximized: {x:maximized.x,y:maximized.y,width:maximized.width,height:maximized.height},
            fullscreen: {x:fullscreen.x,y:fullscreen.y,width:fullscreen.width,height:fullscreen.height}}))
    }
}
""")
        native = work/'native.js'
        native.write_text("""function report(window) {
    print("NATIVE " + JSON.stringify({time:Date.now(),id:String(window.internalId),
        caption:window.caption,resourceClass:window.resourceClass,geometry:window.frameGeometry}));
}
function watch(window) {
    report(window);
    window.frameGeometryChanged.connect(function() { report(window); });
}
workspace.windowAdded.connect(watch);
workspace.windowList().forEach(watch);
""")
        session = work/'session.sh'
        session.write_text('#!/bin/sh\n'
            + 'probe_id="$(qdbus6 org.kde.KWin /Scripting loadScript ' + shlex.quote(str(native)) + ')"\n'
            + 'qdbus6 org.kde.KWin "/Scripting/Script$probe_id" run\n'
            + '/usr/lib/qt6/bin/qml --apptype gui '+shlex.quote(str(client))+' &\n'
            + shlex.join([str(args.binary.resolve()),'--qml-test',str(fixture)])+'\n')
        session.chmod(0o755)
        env.pop('QT_QPA_PLATFORM',None)
        env.pop('QT_QUICK_BACKEND',None)
        env['QT_LOGGING_RULES'] = 'kwin_scripting.debug=true'
        command = ['dbus-run-session','--','kwin_wayland','--virtual','--width','1920','--height','1080',
            '--socket','sirca-island-'+str(os.getpid()),'--no-lockscreen','--no-global-shortcuts',
            '--no-kactivities','--exit-with-session',str(session)]
    logfile = output/'run.log'
    with logfile.open('w') as log:
        process = subprocess.Popen(command,
            env=env, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
        print('Test process group:', process.pid, flush=True)
        try:
            process.wait(timeout=35)
        except subprocess.TimeoutExpired:
            print('Timed out after 35 seconds', flush=True)
        finally:
            try:
                os.killpg(process.pid, signal.SIGTERM)
            except ProcessLookupError:
                pass
            try:
                process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait(timeout=3)
        print('Test group stopped:', process.pid, 'exit:',process.returncode, flush=True)
    log = logfile.read_text()
    errors = [line for line in log.splitlines() if any(token in line for token in
        ['APPLICATIONS FAIL:', 'ReferenceError:', 'TypeError:', 'Binding loop', 'Cannot assign', 'unavailable'])]
    records = [json.loads(line.split('APPLICATIONS GEOMETRY ',1)[1]) for line in log.splitlines() if 'APPLICATIONS GEOMETRY ' in line]
    if args.wayland:
        clients = [json.loads(line.split('CLIENT ',1)[1]) for line in log.splitlines() if 'CLIENT ' in line]
        native = [json.loads(line.split('NATIVE ',1)[1]) for line in log.splitlines() if 'NATIVE ' in line]
        for record in records:
            prior = [item for item in clients if item['time'] <= record['time']]
            assert prior, 'No Wayland client measurements'
            record['clients'] = prior[-1]
            latest = {}
            for item in native:
                if item['time'] <= record['time']:
                    latest[item['id']] = item
            panels = [item for item in latest.values() if item['resourceClass'] == 'sirca-shell'
                and item['geometry']['width'] == 1920 and item['geometry']['height'] < 1080]
            assert len(panels) == 1, 'Expected one native panel: '+repr(list(latest.values()))
            record['nativePanel'] = panels[0]
            assert prior[-1]['maximized'] == {'x':0,'y':0,'width':1920,'height':992}, record
            assert prior[-1]['fullscreen'] == {'x':0,'y':0,'width':1920,'height':1080}, record
        assert records and all(item['nativePanel']['id'] == records[0]['nativePanel']['id']
            and item['nativePanel']['geometry'] == records[0]['nativePanel']['geometry'] for item in records), 'Native panel moved'
        print('Wayland: one native panel, maximized 1920x992, fullscreen 1920x1080 in every state')
    (output/'geometry.json').write_text(json.dumps(records,indent=2))
    for error in errors:
        print(error[:600])
    passed = process.returncode == 0 and not errors and 'APPLICATIONS PASS:' in log
    print(('PASS' if passed else 'FAIL')+': '+str(logfile), flush=True)
    raise SystemExit(0 if passed else 1)
