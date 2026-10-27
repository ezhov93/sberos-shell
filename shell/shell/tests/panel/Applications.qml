// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtTest
import org.kde.taskmanager as TaskManager
import SircaShell

QtObject {
    id: test
    property var app: Main {}
    property int step: 0
    property bool capturing: false
    property var events: null
    property var eventFactory: Component { TestEvent {} }
    property var originalWindow: null
    property var originalZones: []
    property var identities: []
    property real originalMaximumHeight: 0
    property string draggedLauncher: ""
    readonly property bool baseline: BASELINE_MODE
    readonly property bool mockTasks: MOCK_TASKS
    property var mockEntries: STRESS_ENTRIES
    property var modelFixture: ListModel {
        property var launcherList: []
        property var activeTask: null
        function makeModelIndex(row, child) { return row; }
        function launcherPosition(url) { return launcherList.indexOf(String(url)); }
        function syncLaunchers() {}
        function requestPublishDelegateGeometry(index, rect, item) {}
        function data(index, role) {
            const roles = TaskManager.AbstractTasksModel;
            const entry = index >= 0 && index < count ? get(index) : null;
            if (!entry) return null;
            if (role === roles.IsLauncher) return true;
            if (role === roles.IsGroupParent || role === roles.IsActive) return false;
            if (role === roles.LauncherUrlWithoutIcon) return entry.LauncherUrlWithoutIcon;
            if (role === Qt.DecorationRole) return entry.decoration;
            if (role === Qt.DisplayRole || role === roles.AppName) return entry.AppName;
            return null;
        }
    }
    function syncMockTasks() {
        const urls = Config.launchers.slice();
        if (modelFixture.launcherList.join("\n") === urls.join("\n")) return;
        modelFixture.clear();
        modelFixture.launcherList = urls;
        for (const url of urls) {
            const entry = mockEntries.find(item => item.LauncherUrlWithoutIcon === url);
            if (entry) modelFixture.append(entry);
        }
    }
    property var configWatch: Connections {
        target: Config
        function onLaunchersChanged() { if (test.mockTasks) test.syncMockTasks(); }
    }

    function check(ok, message) {
        if (!ok) {
            console.error("APPLICATIONS FAIL:", message);
            Qt.exit(1);
            throw new Error(message);
        }
    }
    function find(item, name) {
        if (item.objectName === name) return item;
        for (const child of item.children || []) {
            const found = find(child, name);
            if (found) return found;
        }
        return null;
    }
    function capture(panel, label, next) {
        capturing = true;
        check(panel.contentItem.grabToImage(result => {
            check(result.saveToFile("OUTPUT_DIR/" + label + ".png"), "capture saved: " + label);
            capturing = false;
            if (next) next();
        }), "capture started: " + label);
        const surface = baseline ? panel.taskAreaRect : panel.applicationSurface.surfaceRect;
        console.log("APPLICATIONS GEOMETRY " + JSON.stringify({label: label, time: Date.now(),
            window: {x: panel.x, y: panel.y, width: panel.width, height: panel.height},
            strut: panel.strut, surface: surface, count: panel.taskSlotCount, hidden: panel.hiddenTaskCount,
            expanded: panel.overflowOpen, zones: panel.panelZones}));
    }
    function stable(panel) {
        check(panel.width === originalWindow.width && panel.height === originalWindow.height,
            "native window dimensions unchanged");
        check(panel.x === originalWindow.x && panel.y === originalWindow.y && panel.strut === originalWindow.strut,
            "native position and reserve unchanged");
        for (let index = 0; index < originalZones.length; index++) {
            if (index === 1) continue;
            check(JSON.stringify(panel.panelZones[index]) === JSON.stringify(originalZones[index]),
                "base zone unchanged: " + index);
        }
        if (!baseline) {
            const r = panel.applicationSurface.surfaceRect;
            const base = panel.panelZones[1];
            check(Math.abs(r.y + r.height - base.y - base.height) < .01, "island bottom stays fixed");
            check(panel.applicationSurface.Window.window === panel, "island remains in the same native window");
            check(panel.inputRegions.length === 5, "one input region replaces applications zone");
            check(Math.abs(panel.inputRegions[1].h - r.height) < .01, "input region follows surface");
        }
    }
    property var timer: Timer {
        interval: 850
        running: true
        repeat: true
        onTriggered: {
            if (test.capturing) return;
            const p = test.app.dock;
            if (!p || !p.tasksModel) return;
            if (test.mockTasks) {
                test.syncMockTasks();
                p.tasksModel = test.modelFixture;
            } else p.tasksModel.filterByActivity = false;
            if (test.step === 0 && p.tasksModel.count < 12) return;
            if (test.step === 0) {
                test.check(p.hiddenTaskCount > 0, "stress data overflows");
                test.events = test.eventFactory.createObject(p.contentItem);
                test.originalWindow = {x:p.x,y:p.y,width:p.width,height:p.height,strut:p.strut};
                test.originalZones = p.panelZones.slice();
                if (!test.baseline) {
                    test.identities = [test.find(p.contentItem, "application-launchpad"),
                        test.find(p.contentItem, "application-task-0"), test.find(p.contentItem, "application-task-15")];
                    test.check(test.identities.every(item => item !== null), "existing delegates found");
                }
                test.capture(p, "light-closed", () => p.overflowOpen = true);
            } else if (test.step === 1) {
                test.stable(p);
                test.check(p.overflowOpen, "overflow opens");
                if (!test.baseline) {
                    test.check(p.applicationSurface.height > p.dockH && p.applicationColumns <= 12, "island grows into rows");
                    test.check(!test.find(p.contentItem, "application-overflow").visible, "counter hidden in grid");
                    test.check(test.identities[0].children.find(item => item.contentItem)?.contentItem.width === 32,
                        "Launchpad glyph keeps the same 32 px size as applications");
                    test.check(test.identities[0] === test.find(p.contentItem, "application-launchpad") &&
                        test.identities[1] === test.find(p.contentItem, "application-task-0") &&
                        test.identities[2] === test.find(p.contentItem, "application-task-15"), "same controls survive reflow");
                }
                test.capture(p, "light-open", () => Shell.saveConfigKey("mode", "dark"));
            } else if (test.step === 2) {
                test.stable(p);
                test.capture(p, "dark-open", () => {
                    if (test.baseline) p.overflowOpen = false;
                    else p.closeOverflow(true);
                });
            } else if (test.step === 3) {
                test.stable(p);
                test.check(!p.overflowOpen, "overflow closes");
                if (!test.baseline) test.check(test.find(p.contentItem, "application-overflow").activeFocus, "counter regains keyboard focus");
                test.capture(p, "dark-closed", () => Shell.saveConfigKey("mode", "light"));
            } else if (test.step === 4) {
                if (test.baseline) {
                    console.log("APPLICATIONS PASS: baseline captures");
                    Qt.quit();
                    return;
                }
                p.overflowOpen = true;
            } else if (test.step === 5) {
                test.stable(p);
                p.focusApplicationSlot(p.taskSlotCount - 1);
                test.events.keyClick(Qt.Key_Tab, Qt.NoModifier, 0);
                test.check(p.focusedApplicationSlot === 0, "Tab wraps to Launchpad");
                test.events.keyClick(Qt.Key_Backtab, Qt.ShiftModifier, 0);
                test.check(p.focusedApplicationSlot === p.taskSlotCount - 1, "Shift+Tab wraps to last application");
                p.focusApplicationSlot(0);
                test.events.keyClick(Qt.Key_Down, Qt.NoModifier, 0);
                test.check(p.focusedApplicationSlot === p.applicationColumns, "Down moves to next row");
                test.events.keyClick(Qt.Key_Right, Qt.NoModifier, 0);
                test.check(p.focusedApplicationSlot === p.applicationColumns + 1, "Right moves to next application");
                test.events.keyClick(Qt.Key_F10, Qt.ShiftModifier, 0);
            } else if (test.step === 6) {
                test.check(p.previewShown && p.lobeMode === "menu" && p.overflowOpen, "context menu retains expanded island");
                test.capture(p, "context-menu", () => test.events.keyClick(Qt.Key_Escape, Qt.NoModifier, 0));
            } else if (test.step === 7) {
                test.check(!p.previewShown && p.overflowOpen, "first Escape closes only child");
                test.events.keyClick(Qt.Key_Escape, Qt.NoModifier, 0);
            } else if (test.step === 8) {
                test.stable(p);
                test.check(!p.overflowOpen && test.find(p.contentItem, "application-overflow").activeFocus,
                    "second Escape closes island and restores focus");
                p.overflowOpen = true;
            } else if (test.step === 9) {
                test.stable(p);
                test.originalMaximumHeight = p.applicationSurface.maximumHeight;
                p.applicationSurface.maximumHeight = 120;
            } else if (test.step === 10) {
                p.focusApplicationSlot(p.taskSlotCount - 1);
            } else if (test.step === 11) {
                const viewport = test.find(p.contentItem, "application-viewport");
                test.check(viewport.contentY > 0 && viewport.contentHeight > viewport.height,
                    "keyboard scrolls to last application at capped height");
                test.events.keyClick(Qt.Key_Tab, Qt.NoModifier, 0);
                test.check(p.focusedApplicationSlot === 0 && viewport.contentY === 0,
                    "Tab wraps and scrolls back to Launchpad");
                test.events.keyClick(Qt.Key_Backtab, Qt.ShiftModifier, 0);
                test.check(p.focusedApplicationSlot === p.taskSlotCount - 1 && viewport.contentY > 0,
                    "Shift+Tab scrolls back to last application");
                test.capture(p, "scrolled", () => {
                    p.applicationSurface.maximumHeight = test.originalMaximumHeight;
                    p.focusApplicationSlot(0);
                });
            } else if (test.step === 12) {
                if (!test.mockTasks) {
                    const cell = test.find(p.contentItem, "application-task-0");
                    test.draggedLauncher = String(p.tasksModel.data(p.tasksModel.makeModelIndex(0),
                        TaskManager.AbstractTasksModel.LauncherUrlWithoutIcon));
                    const pos = cell.mapToItem(p.contentItem, cell.width / 2, cell.height / 2);
                    test.events.mousePress(p.contentItem, pos.x, pos.y, Qt.LeftButton, Qt.NoModifier, 0);
                    test.events.mouseMove(p.contentItem, pos.x + 12, pos.y, 50, Qt.LeftButton, Qt.NoModifier);
                    test.events.mouseMove(p.contentItem, pos.x + 52, pos.y + 48, 50, Qt.LeftButton, Qt.NoModifier);
                    test.events.mouseRelease(p.contentItem, pos.x + 52, pos.y + 48, Qt.LeftButton, Qt.NoModifier, 50);
                }
            } else if (test.step === 13) {
                if (!test.mockTasks) {
                    const position = p.tasksModel.launcherPosition(test.draggedLauncher);
                    test.check(position >= p.applicationColumns - 1, "drag moves launcher into next grid row");
                    test.check(Config.launchers.indexOf(test.draggedLauncher) === position, "drag saves launcher order");
                    console.log("APPLICATIONS DRAG PASS:", test.draggedLauncher, "new position", position);
                }
                test.app.closePopups();
                test.check(!p.overflowOpen, "global close also collapses island");
                p.overflowOpen = true;
            } else if (test.step === 14) {
                test.stable(p);
                Shell.saveConfigKey("launchers", STRESS_LAUNCHERS.slice(0,2));
            } else if (test.step === 15) {
                test.check(p.hiddenTaskCount === 0 && !p.overflowOpen, "shrinking model closes overflow");
                test.stable(p);
                console.log("APPLICATIONS PASS: one native window, same controls, fixed reserve/bottom/zones, keyboard, scrolling, global close and model changes");
                Qt.quit();
            }
            test.step++;
        }
    }
}
