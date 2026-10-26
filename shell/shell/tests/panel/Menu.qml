import QtQuick
import QtTest
import SircaShell

QtObject {
    id: test
    property var app: Main {}
    property var menu: null
    property var events: null
    property var eventFactory: Component {
        TestEvent {}
    }
    property int step: 0
    property bool capturing: false
    property var actions: []
    property var originalLaunchers: []
    property bool wasPinned: false
    property var savedScreens: null
    property string primaryName: ""
    property string secondaryName: ""
    function check(ok, text) {
        if (!ok) {
            console.error("PANEL FAIL:", text);
            Qt.exit(1);
            throw new Error(text);
        }
    }
    function click(x, y, button) {
        check(events.mouseClick(menu.contentItem, x, y, button || Qt.LeftButton, Qt.NoModifier, 0), "mouse event delivered");
    }
    function key(key) {
        check(events.keyClick(key, Qt.NoModifier, 0), "key event delivered");
    }
    function entry(index, button) {
        click(menu.menuRect.x + menu.menuRect.width / 2, menu.menuRect.y + menu.menuPadding + (menu.cellSize + menu.menuSpacing) * index + menu.cellSize / 2, button);
    }
    function capture(name, next) {
        if (!CAPTURE_ENABLED) {
            if (next)
                Qt.callLater(next);
            return;
        }
        capturing = true;
        check(menu.contentItem.grabToImage(result => {
            test.check(result.saveToFile("OUTPUT_DIR/" + name + ".png"), "screenshot saved");
            test.capturing = false;
            if (next)
                Qt.callLater(next);
        }), "screenshot starts");
    }
    property var timer: Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: {
            if (test.capturing)
                return;
            const p = test.app.dock;
            if (test.step === 0) {
                test.menu = test.app.win("sberMenu");
                test.menu.dryRun = true;
                test.events = test.eventFactory.createObject(test.menu.contentItem);
                test.menu.actionInvoked.connect(id => {
                    test.actions.push(id);
                });
                test.originalLaunchers = Config.launchers.slice();
                test.app.toggleSber(p, false);
            } else if (test.step === 1) {
                test.check(test.menu.visible && test.menu.entries.length === 4, "MVP has four entries");
                test.check(test.menu.currentIndex === -1, "no entry focused initially");
                test.key(Qt.Key_Return);
                test.check(test.actions.length === 0, "Enter without focus does nothing");
                test.key(Qt.Key_Down);
                test.check(test.menu.currentIndex === 0, "first Down focuses shell settings");
                test.key(Qt.Key_Tab);
                test.check(test.menu.currentIndex === 1, "Tab advances");
                test.key(Qt.Key_Up);
                test.check(test.menu.currentIndex === 0, "Up goes back");
                test.capture("menu-light");
            } else if (test.step === 2) {
                test.key(Qt.Key_Down);
                test.key(Qt.Key_Menu);
                test.check(test.menu.child === "terminal", "keyboard context menu");
                test.key(Qt.Key_Escape);
                test.check(test.menu.visible && test.menu.child === "" && test.menu.currentIndex === 1, "Escape closes child and restores keyboard focus");
                test.entry(1, Qt.RightButton);
                test.check(test.menu.child === "terminal" && test.actions.length === 0, "right click does not launch");
                test.entry(0);
                test.check(test.menu.visible && test.menu.child === "" && test.actions.length === 0, "outside child only closes child");
                test.entry(1, Qt.RightButton);
                test.capture("terminal-context");
            } else if (test.step === 3) {
                test.wasPinned = test.menu.pinnedIndex >= 0;
                const r = test.menu.childRect;
                test.click(r.x + 30, r.y + 8 + (test.menu.contextItems.length - 0.5) * 44);
                test.check(test.menu.visible && test.menu.child === "", "pin action retains parent menu");
            } else if (test.step === 4) {
                test.check((test.menu.pinnedIndex >= 0) !== test.wasPinned, "pin changes configuration");
                Shell.saveConfigKey("launchers", test.originalLaunchers);
                test.entry(2);
                test.check(test.menu.child === "power", "power child opens");
                test.capture("power-light");
            } else if (test.step === 5) {
                const r = test.menu.childRect;
                test.click(r.x + 30, r.y + 8 + 4.5 * 44);
                test.check(test.menu.powerActions.armed === "shutdown" && test.actions.length === 0, "shutdown requires confirmation");
                test.entry(0);
                test.check(test.menu.child === "" && test.menu.visible && test.actions.length === 0, "outside child does not activate settings");
                test.entry(2);
                test.key(Qt.Key_Escape);
                test.check(test.menu.child === "" && test.menu.visible, "Escape removes power child");
                test.key(Qt.Key_Escape);
                test.check(!test.menu.visible, "second Escape closes parent");
                test.app.toggleSber(p, false);
                test.entry(2);
                Shell.saveConfigKey("mode", "dark");
            } else if (test.step === 6) {
                test.capture("power-dark", () => test.key(Qt.Key_Escape));
            } else if (test.step === 7) {
                test.capture("menu-dark");
            } else if (test.step === 8) {
                test.entry(1);
                test.check(!test.menu.visible && test.actions[test.actions.length - 1] === "terminal", "terminal launch request closes parent");
                test.app.toggleSber(p, false);
                test.entry(0);
                test.check(!test.menu.visible && test.actions[test.actions.length - 1] === "settings", "settings route closes parent");
                test.check(test.app._made.settings && test.app._made.settings.visible, "the shell settings window opens");
                test.app._made.settings.close();
                test.app.toggleSber(p, false);
                test.entry(2);
                Shell.toggleLauncher();
                test.check(!test.menu.visible && test.menu.child === "", "global toggle closes all levels");
                test.app.toggleSber(p, false);
                test.entry(2);
                test.check(test.menu.powerActions.dryRun, "power dry-run enforced");
                test.menu.powerActions.activate(4);
                test.menu.powerActions.activate(4);
                test.check(!test.menu.visible && test.actions[test.actions.length - 1] === "shutdown", "confirmed dry-run power action closes all levels");
                test.app.toggleSber(p, false);
                test.click(test.menu.width - 20, 20);
                test.check(!test.menu.visible, "outside click closes parent");
            } else if (test.step === 9) {
                if (Qt.application.screens.length > 1) {
                    const a = test.app.primarySet.screen;
                    const b = Qt.application.screens.find(s => s.name !== a.name);
                    test.primaryName = a.name;
                    test.secondaryName = b.name;
                    test.savedScreens = Config.get("screens", {}) || {};
                    let second = null;
                    for (let i = 0; i < test.app.sets.count; ++i) {
                        const s = test.app.sets.objectAt(i);
                        if (s && s.name === b.name)
                            second = s.panel;
                    }
                    test.check(second, "second screen panel exists");
                    test.app.lastActiveScreenName = b.name;
                    test.check(test.app.activePanel() === second, "keyboard actions select the last active screen panel");
                    const choices = Object.assign({}, test.savedScreens);
                    choices[a.name] = Object.assign({}, choices[a.name] || {}, {
                        panel: false
                    });
                    Shell.saveConfigKey("screens", choices);
                }
            } else if (test.step === 10) {
                if (test.primaryName !== "") {
                    test.check(test.app.primarySet.panel === null, "explicitly disabling the primary panel is respected");
                    let second = null;
                    for (let i = 0; i < test.app.sets.count; ++i) {
                        const s = test.app.sets.objectAt(i);
                        if (s && s.name === test.secondaryName)
                            second = s.panel;
                    }
                    test.check(second && test.app.activePanel() === second, "active screen remains usable without a primary panel");
                    test.app.lastActiveScreenName = "";
                    test.check(test.app.sberPanel() === second, "global panel command falls back to the first enabled screen");
                    Shell.saveConfigKey("screens", test.savedScreens);
                    test.app.lastActiveScreenName = test.primaryName;
                }
            } else if (test.step === 11) {
                const p = test.app.dock;
                if (Qt.application.screens.length > 1) {
                    const a = Qt.application.screens.find(s => s.name === test.primaryName);
                    const b = Qt.application.screens.find(s => s.name === test.secondaryName);
                    let second = null, outside = null;
                    for (let i = 0; i < test.app.sets.count; ++i) {
                        const s = test.app.sets.objectAt(i);
                        if (s && s.name === b.name) {
                            second = s.panel;
                            outside = s.sberCatcher;
                        }
                    }
                    test.app.toggleSber(p, false);
                    test.entry(2);
                    test.check(outside && outside.visible, "other screen has a click catcher");
                    test.events.mouseClick(outside.contentItem, 20, 20, Qt.LeftButton, Qt.NoModifier, 0);
                    test.check(test.menu.child === "" && test.menu.visible && test.menu.screen.name === a.name, "outside on other screen closes child only");
                    test.entry(2);
                    const x = second.x + second.sberRect.x + 30, y = second.y + second.sberRect.y + 30;
                    test.events.mouseClick(outside.contentItem, x, y, Qt.LeftButton, Qt.NoModifier, 0);
                    test.check(test.menu.child === "" && test.menu.screen.name === a.name, "other screen button first closes child only");
                    test.events.mouseClick(outside.contentItem, x, y, Qt.LeftButton, Qt.NoModifier, 0);
                    test.check(test.menu.visible && test.menu.screen.name === b.name && second.externalMenuOpen && !p.externalMenuOpen, "single instance moves to other screen");
                    test.menu.closeAll();
                    Shell.toggleLauncher();
                    test.check(test.menu.visible && test.menu.screen.name === b.name, "keyboard route uses last active panel screen");
                }
                test.menu.closeAll();
                Shell.saveConfigKey("launchers", test.originalLaunchers);
                console.log("PANEL PASS: Sber menu, keyboard, context, pinning, layered dismissal, dry-run power, themes");
                Qt.quit();
            }
            test.step++;
        }
    }
}
