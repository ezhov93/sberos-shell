#!/usr/bin/python3
"""Read KWin maximize area without moving windows; unload the temporary script afterwards.

Usage: /usr/bin/python3 work-area.py /tmp/area.json
Requires python3-dbus and python3-gi on the current user session bus.
"""
import dbus, dbus.service, dbus.mainloop.glib
from gi.repository import GLib
import json, pathlib, sys, tempfile

dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
bus = dbus.SessionBus()
loop = GLib.MainLoop()
result = []
class Probe(dbus.service.Object):
    @dbus.service.method('org.sberos.PanelCheck', in_signature='s', out_signature='')
    def Report(self, payload):
        result.append(json.loads(str(payload)))
        loop.quit()
name = dbus.service.BusName('org.sberos.PanelCheck', bus, do_not_queue=True)
probe = Probe(bus, '/PanelCheck')
with tempfile.TemporaryDirectory(prefix='panel001-area-') as directory:
    script = pathlib.Path(directory)/'area.js'
    script.write_text('''const w = workspace.activeWindow;
const a = w ? workspace.clientArea(KWin.MaximizeArea, w) : null;
callDBus("org.sberos.PanelCheck", "/PanelCheck", "org.sberos.PanelCheck", "Report", JSON.stringify(a ? {x:a.x,y:a.y,width:a.width,height:a.height} : {}));''')
    scripting = dbus.Interface(bus.get_object('org.kde.KWin', '/Scripting'), 'org.kde.kwin.Scripting')
    script_name = 'sberos-panel001-area-probe'
    script_id = scripting.loadScript(str(script), script_name, signature="ss")
    try:
        dbus.Interface(bus.get_object('org.kde.KWin', '/Scripting/Script'+str(script_id)), 'org.kde.kwin.Script').run()
        GLib.timeout_add(3000, lambda: (loop.quit(), False)[1])
        loop.run()
    finally:
        scripting.unloadScript(script_name)
if not result:
    raise SystemExit('No work-area response from KWin')
pathlib.Path(sys.argv[1]).write_text(json.dumps(result[-1], indent=2)+'\n')
print(result[-1])
