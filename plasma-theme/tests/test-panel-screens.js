// SPDX-License-Identifier: GPL-2.0-or-later
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const template = fs.readFileSync(path.join(__dirname,
    "../layout-templates/sberos.taskbar/contents/layout.js"), "utf8");
const panelType = "io.gitgud.wackyideas.panel";

function session(screenCount, saved = []) {
    const panels = saved;
    const context = vm.createContext({
        screenCount,
        get panelIds() { return panels.map((_, index) => index); },
        panelById: id => panels[id],
        Panel: function (type) {
            const panel = {type, screen: -1, widgetTypes: [], readConfig: (_, fallback) => fallback, widgets: type => [],
                addWidget(type) {
                    assert.ok(this.screen >= 0, "Assign screen before adding applets");
                    this.widgetTypes.push(type);
                    return {writeConfig() {}};
                }};
            panels.push(panel);
            return panel;
        }
    });
    return {panels, context, run() { vm.runInContext(template, context); }};
}

const fresh = session(3);
fresh.run();
assert.deepEqual(fresh.panels.map(p => p.screen), [0, 1, 2]);
assert.ok(fresh.panels.every(p => p.location === "bottom" && p.locked && p.widgetTypes.length === 5));
fresh.run();
assert.equal(fresh.panels.length, 3, "Repeated startup must not duplicate panels");
fresh.context.screenCount = 4;
fresh.run();
assert.deepEqual(fresh.panels.map(p => p.screen), [0, 1, 2, 3]);
fresh.context.screenCount = 1;
fresh.run();
fresh.context.screenCount = 4;
fresh.run();
assert.equal(fresh.panels.length, 4, "Reconnect must reuse saved panels");

const saved = {type: panelType, screen: 0, widgets: () => [], customSetting: "preserve"};
const savedSnapshot = {...saved};
const waiting = {type: panelType, screen: -1, widgets: () => [], readConfig: () => 1};
const restored = session(2, [saved, waiting, {type: "org.kde.panel", screen: 0}]);
restored.run();
assert.equal(restored.panels.length, 3, "Pending panel views already occupy their saved screen");
assert.deepEqual(saved, savedSnapshot);
const empty = session(0);
empty.run();
assert.equal(empty.panels.length, 0);
let removed = 0;
const pins = ["applications:org.kde.kate.desktop"];
const taskWidget = {type: "io.gitgud.wackyideas.smarttasks", pins};
const launcherWidget = {type: "p-connor.plasma-drawer", remove() { removed++; }};
let oldWidgets = [launcherWidget, taskWidget];
const oldPanel = {type: panelType, screen: 0, locked: true,
    widgets(type) { return oldWidgets.filter(widget => widget.type === type && !removed); }};
const upgrade = session(1, [oldPanel]);
upgrade.run();
upgrade.run();
assert.equal(removed, 1, "Remove the former launcher once");
assert.equal(upgrade.panels.length, 1, "Reuse the panel");
assert.equal(taskWidget.pins, pins, "Keep the task applet and its pins");
assert.ok(oldPanel.locked);
assert.ok(fresh.panels.every(p => p.widgetTypes.filter(type => type === taskWidget.type).length === 1));
assert.ok(fresh.panels.every(p => !p.widgetTypes.includes(launcherWidget.type)));
console.log("Panel screens: fresh startup, repeat, add, reconnect, restore and zero outputs passed");
