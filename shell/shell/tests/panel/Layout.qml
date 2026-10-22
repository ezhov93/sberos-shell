import QtQuick
import SircaShell

QtObject {
    id: test
    property var app: Main {}
    property int step: 0
    property real centre: 0
    property real systemX: 0
    property bool capturing: false
    property var originalLaunchers: []
    function check(ok, message) {
        if (!ok) { console.error("PANEL FAIL:", message); Qt.exit(1); }
    }
    function geometry(p) {
        check(p.width === 1920, "only the agreed 1920 px screen is tested");
        const zones = p.panelZones;
        check(zones.length === 5, "five panel zones");
        check(Math.abs(p.oskaRect.x + p.oskaRect.width / 2 - p.width / 2) < 1, "Oska is at screen centre");
        for (let i = 0; i < zones.length; ++i) {
            const r = zones[i];
            check(r.width > 0 && r.height > 0 && r.x >= 0 && r.x + r.width <= p.width, "zone inside screen: " + i);
            if (i) check(zones[i - 1].x + zones[i - 1].width < r.x, "zones have a clear gap: " + i);
        }
        check(p.taskAreaRect.x >= zones[1].x && p.taskAreaRect.x + p.taskAreaRect.width <= zones[1].x + zones[1].width, "tasks remain in applications zone");
        check(!p.blur && p.inputRegions.length >= 5, "separate opaque surfaces retain an input mask");
    }
    function capture(p, name, next) {
        if (!CAPTURE_ENABLED) {
            if (next) Qt.callLater(next);
            return;
        }
        capturing = true;
        const started = p.contentItem.grabToImage(result => {
            test.capturing = false;
            test.check(result.saveToFile("OUTPUT_DIR/" + name + ".png"), "capture saved");
            if (next) Qt.callLater(next);
        });
        test.check(started, "capture starts: " + name);
        p.requestUpdate();
    }
    property var timer: Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: {
            if (test.capturing) return;
            const p = test.app.dock;
            if (test.step === 0) {
                test.geometry(p);
                test.originalLaunchers = Config.launchers.slice();
                test.centre = p.oskaRect.x;
                test.systemX = p.essentialRect.x;
                console.log("LAYOUT SCREEN", p.screen.width, p.screen.height, "tasks", p.tasksModel ? p.tasksModel.count : -1);
                test.capture(p, "layout-light", () => {
                    p.recorder = { recording: true, finishing: false, clock: "00:42", stop: function() {} };
                });
            } else if (test.step === 1) {
                test.geometry(p);
                test.check(p.oskaRect.x === test.centre && p.essentialRect.x === test.systemX, "dynamic indicators do not move Oska or system controls");
                test.capture(p, "layout-indicators", () => { p.recorder = null; Shell.saveConfigKey("mode", "dark"); });
            } else if (test.step === 2) {
                test.geometry(p);
                test.capture(p, "layout-dark", () => {
                    Shell.saveConfigKeys({ dockCell: 72, launchers: STRESS_LAUNCHERS });
                });
            } else if (test.step === 3) {
                test.geometry(p);
                test.check(p.oskaRect.x === test.centre, "task sizing does not move Oska");
                if (!CAPTURE_ENABLED) {
                    test.check(p.tasksModel && p.tasksModel.count >= 12, "Wayland stress model has enough applications");
                    test.check(p.contentW > p.applicationsRect.width, "applications overflow stays constrained");
                    console.log("LAYOUT OVERFLOW", p.tasksModel.count, "apps", p.applicationsRect.width, "content", p.contentW);
                }
                Shell.saveConfigKey("launchers", test.originalLaunchers);
                Shell.removeConfigKey("dockCell");
                p.toggle("clock");
            } else if (test.step === 4) {
                test.check(p.systemOpen && p.systemView, "calendar opens");
                test.check(p.systemRect.x >= 0 && p.systemRect.y >= 0 && p.systemRect.x + p.systemRect.width <= p.width, "calendar is inside screen");
                test.capture(p, "layout-calendar", () => p.toggle("gear"));
            } else if (test.step === 5) {
                test.check(p.nativeControl, "quick settings opens");
                test.capture(p, "layout-quick-settings", () => { test.app.closePopups(); p.launcherOpen = true; });
            } else if (test.step === 6) {
                test.check(p.launcherOpen && !p.systemOpen, "launcher remains accessible");
                test.capture(p, "layout-launcher", () => { p.launcherOpen = false; Shell.saveConfigKey("panelLayout", "split"); });
            } else if (test.step === 7) {
                test.check(test.app.topBar !== p && p && !p.unified, "split remains available");
                Shell.saveConfigKey("panelLayout", "unified");
            } else if (test.step === 8) {
                test.geometry(p);
                test.check(test.app.topBar === p, "one surface after restoring unified");
                console.log("PANEL PASS: five zones at 1920, stable centre, dynamic indicators, themes, popups, split");
                Qt.quit();
            }
            test.step++;
        }
    }
}
