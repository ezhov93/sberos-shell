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
            const panel = {type, screen: -1, widgets: [], readConfig: (_, fallback) => fallback,
                addWidget(type) {
                    assert.ok(this.screen >= 0, "Assign screen before adding applets");
                    this.widgets.push(type);
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
assert.ok(fresh.panels.every(p => p.location === "bottom" && p.locked && p.widgets.length === 7));
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

const saved = {type: panelType, screen: 0, customSetting: "preserve"};
const waiting = {type: panelType, screen: -1, readConfig: () => 1};
const restored = session(2, [saved, waiting, {type: "org.kde.panel", screen: 0}]);
restored.run();
assert.equal(restored.panels.length, 3, "Pending panel views already occupy their saved screen");
assert.deepEqual(saved, {type: panelType, screen: 0, customSetting: "preserve"});
const empty = session(0);
empty.run();
assert.equal(empty.panels.length, 0);
console.log("Panel screens: fresh startup, repeat, add, reconnect, restore and zero outputs passed");
