import QtQuick
import SircaShell
QtObject {
    id: test
    property var app: Main {}
    property int step: 0
    function check(ok, message) { if (!ok) { console.error("PANEL FAIL:", message); Qt.exit(1) } }
    function capture(window, name, next) {
        window.contentItem.grabToImage(result => {
            test.check(result.saveToFile("OUTPUT_DIR/" + name + ".png"), "capture saved")
            if (next) Qt.callLater(next)
        })
    }
    property var timer: Timer {
        interval: 1800; running: true; repeat: true
        onTriggered: {
            const p = test.app.dock
            if (test.step === 0) {
                test.check(p && test.app.topBar === p && p.unified && p.edge === "bottom", "one bottom surface")
                if (p.tasksModel) p.tasksModel.filterByActivity = false // No activity controller in the test bus.
                test.capture(p, "light", () => p.toggle("clock"))
            } else if (test.step === 1) {
                console.log("TASKS", p.tasksModel ? p.tasksModel.count : -1)
                test.check(p.systemOpen && p.systemView !== null, "calendar loaded")
                test.check(p.systemRect.y >= 0 && p.systemRect.x >= 0 && p.systemRect.x + p.systemRect.width <= p.width, "popup inside surface")
                test.capture(p, "calendar", () => p.toggle("gear"))
            } else if (test.step === 2) {
                test.check(p.nativeControl !== null, "quick settings loaded")
                test.capture(p, "quick-settings", () => { p.openLobe = ""; p.launcherOpen = true })
            } else if (test.step === 3) {
                test.check(p.launcherOpen && !p.systemOpen && p.lobeH > 10, "launcher shares the surface")
                test.capture(p, "launcher", () => { p.launcherOpen = false; Shell.saveConfigKey("mode", "dark") })
            } else if (test.step === 4) {
                test.capture(p, "dark", () => Shell.saveConfigKey("panelLayout", "split"))
            } else if (test.step === 5) {
                test.check(test.app.topBar !== p && p && test.app.topBar, "legacy split layout available")
                test.capture(test.app.topBar, "before-top-dark", () => test.capture(p, "before-dock-dark", () => Shell.saveConfigKey("mode", "light")))
            } else if (test.step === 6) {
                test.capture(test.app.topBar, "before-top-light", () => test.capture(p, "before-dock-light", () => Shell.saveConfigKey("panelLayout", "unified")))
            } else if (test.step === 7) {
                test.check(test.app.topBar === p && p.unified, "layout restored without duplicate surfaces")
                test.app.closePopups()
                test.check(p.openLobe === "" && !p.launcherOpen, "close popups routes to unified surface")
                console.log("PANEL PASS: single surface, popups, launcher, themes, split fallback, restoration")
            } else Qt.quit()
            test.step++
        }
    }
}
