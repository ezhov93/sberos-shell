// Edit mode: a scene of its own, like Plasma's. The desktop dims while the panel stays live, with a floating strip of options.
import QtQuick
import SircaShell
import "Glass"

Window {
    id: es
    color: "transparent"
    flags: Qt.FramelessWindowHint
    visible: false
    width: Screen.width; height: Screen.height
    signal done()
    signal moreSettings()
    property rect dockHole: Qt.rect(0, 0, 0, 0)
    property bool setupDone: false
    property real show: 0
    Behavior on show { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    readonly property color accent: Config.accent

    function open() { if (!setupDone) { Shell.setupSearch(es); setupDone = true } visible = true; show = 1; keys.forceActiveFocus(); regions.restart() }
    function close_() { visible = false; show = 0 }
    Timer { id: regions; interval: 30; onTriggered: es.pushRegions() }
    function pushRegions() { if (!visible) return
        const p = []; for (const it of [dockStrip, pill, screensStrip]) if (it.visible) p.push({ x: it.x, y: it.y, w: it.width, h: it.height, r: it.radius })
        Shell.setSceneRegions(es, p, [ { x: dockHole.x, y: dockHole.y, w: dockHole.width, h: dockHole.height } ]); es.requestUpdate() }
    onDockHoleChanged: regions.restart()

    // ---- writing: sliders write while they move, a little throttled (every write re-evaluates the whole shell)
    property var pending: ({})
    Timer { id: flush; interval: 45; onTriggered: { const p = es.pending; es.pending = ({}); if (Object.keys(p).length) Shell.saveConfigKeys(p) } }
    function put(key, value, now) { const p = Object.assign({}, pending); p[key] = value; pending = p; if (now) { flush.stop(); flush.triggered() } else if (!flush.running) flush.start() }

    // ---- every option, as data. t: num | bool | choice
    readonly property var clockTab: ({ name: "Clock", items: [
            { k: "clock24h", t: "bool", label: "24 hour" },
            { k: "clockSeconds", t: "bool", label: "Seconds" },
            { k: "clockDate", t: "bool", label: "Date in the clock" },
            { k: "clockBold", t: "bool", label: "Bold" },
            { k: "clockSize", t: "num", label: "Size", from: 11, to: 24, step: 1, unit: " px" },
            { k: "dateFormat", t: "choice", label: "Date format", options: [["ddd d MMM", "Sat 19 Sep"], ["d MMMM", "19 September"], ["dd.MM.yyyy", "19.09.2026"], ["yyyy-MM-dd", "2026-09-19"], ["M/d", "9/19"]] } ] })
    readonly property var dockTabs: [
        { name: "Size", items: [
            { k: "dockFillMargin", t: "num", label: "Side margin", from: 0, to: 120, step: 1, unit: " px" },
            { k: "dockIcon", t: "num", label: "Icon size", from: 28, to: 72, step: 1, unit: " px" },
            { k: "dockCell", t: "num", label: "Icon spacing", from: 40, to: 96, step: 1, unit: " px" },
            { k: "dockHeight", t: "num", label: "Height", from: 40, to: 96, step: 1, unit: " px" },
            { k: "dockGap", t: "num", label: "Gap to the edge", from: 0, to: 40, step: 1, unit: " px" } ] },
        { name: "Media", items: [
            { k: "hazeStrength", t: "num", label: "Artwork glow", from: 0, to: 1, step: 0.01, pct: true } ] },
        { name: "Icons", items: [
            { k: "dockMagnify", t: "num", label: "Hover zoom", from: 1, to: 1.8, step: 0.01, mult: true },
            { k: "dockSpotlight", t: "bool", label: "Hover light" },
            { k: "dockIndicators", t: "bool", label: "Running pills" },
            { k: "dockBadges", t: "bool", label: "Badges" },
            { k: "dockHop", t: "bool", label: "Launch hop" },
            { k: "launcherIcon", t: "choice", label: "Launcher icon", options: [["start-here-kde-symbolic", "KDE"], ["view-app-grid-symbolic", "Grid"], ["application-menu-symbolic", "Menu"], ["search-symbolic", "Search"], ["starred-symbolic", "Star"]] } ] },
        { name: "Behaviour", items: [
            { k: "dockVisibility", t: "choice", label: "Windows", options: [["always", "Never touch it"], ["dodge", "Hide under them"], ["below", "Go below it"]] },
            { k: "dockPreviews", t: "bool", label: "Window previews" },
            { k: "dockPreviewDelay", t: "num", label: "Preview delay", from: 0, to: 1500, step: 20, unit: " ms", when: "dockPreviews=true" },
            { k: "dockFullscreenMode", t: "choice", label: "Full-screen windows", options: [["hide", "Hide the panel"], ["keep", "Keep it visible"]] } ] } ]
    function keysOf(tabs, extra) { const out = extra.slice(); for (const t of tabs) for (const i of t.items) if (["cornerRadius", "levelMeter", "quietWhenBusy"].indexOf(i.k) < 0) out.push(i.k); return out }
    function met(when) { if (!when) return true; const p = when.split("="); return String(Config[p[0]]) === p[1] }
    function text(item, v) { return item.pct ? Math.round(v * 100) + " %" : item.mult ? Number(v).toFixed(2) + "×" : Math.round(v) + (item.unit || "") }

    // ---- one option
    component PillBtn: Rectangle { id: pb; property string label; property bool primary: false; signal tapped()
        width: pbt.implicitWidth + 30; height: 32; radius: 16; anchors.verticalCenter: parent.verticalCenter
        color: primary ? es.accent : Qt.rgba(1, 1, 1, pbh.hovered ? 0.16 : 0.09); Behavior on color { ColorAnimation { duration: Config.quick } }
        Text { id: pbt; anchors.centerIn: parent; text: pb.label; color: "white"; font.pixelSize: 12; font.weight: pb.primary ? Font.DemiBold : Font.Normal }
        HoverHandler { id: pbh; cursorShape: Qt.PointingHandCursor } TapHandler { onTapped: pb.tapped() } }
    component Option: Item { id: op; required property var modelData
        readonly property var cur: Config[modelData.k]
        visible: es.met(modelData.when); width: visible ? (modelData.t === "choice" ? ch.implicitWidth : 188) : 0; height: 50
        Text { id: lab; text: op.modelData.label; color: Qt.rgba(1, 1, 1, 0.72); font.pixelSize: 12 }
        Text { visible: op.modelData.t === "num"; anchors.right: parent.right; text: op.modelData.t === "num" ? es.text(op.modelData, sl.shown) : ""; color: "white"; font.pixelSize: 12; font.weight: Font.DemiBold; font.features: { "tnum": 1 } }
        GlassSlider { id: sl; visible: op.modelData.t === "num"; y: 22; width: parent.width; from: op.modelData.from || 0; to: op.modelData.to || 1; step: op.modelData.step || 0
            value: op.modelData.t === "num" ? Number(op.cur) : 0
            onMoved: v => es.put(op.modelData.k, op.modelData.step >= 1 ? Math.round(v) : Number(v.toFixed(3)), false)
            onCommitted: v => es.put(op.modelData.k, op.modelData.step >= 1 ? Math.round(v) : Number(v.toFixed(3)), true) }
        GlassSwitch { visible: op.modelData.t === "bool"; y: 22; checked: op.modelData.t === "bool" && !!op.cur; onToggled: on => es.put(op.modelData.k, on, true) }
        Row { id: ch; visible: op.modelData.t === "choice"; y: 21; spacing: 5
            Repeater { model: op.modelData.t === "choice" ? op.modelData.options : []
                Rectangle { id: seg; required property var modelData; readonly property bool on: String(op.cur) === modelData[0]
                    width: st.implicitWidth + 20; height: 25; radius: 12.5; color: on ? es.accent : Qt.rgba(1, 1, 1, sh.hovered ? 0.14 : 0.08); Behavior on color { ColorAnimation { duration: Config.quick } }
                    Text { id: st; anchors.centerIn: parent; text: seg.modelData[1]; color: "white"; font.pixelSize: 11; font.weight: seg.on ? Font.DemiBold : Font.Normal }
                    HoverHandler { id: sh; cursorShape: Qt.PointingHandCursor } TapHandler { onTapped: es.put(op.modelData.k, seg.modelData[0], true) } } } } }

    // ---- a strip: title, tabs and the tab's options
    component Strip: Rectangle { id: strip
        property string title; property string hint; property var tabs: []; property int tab: 0
        radius: 26; color: Qt.rgba(0.07, 0.08, 0.11, 0.55); border.width: 1; border.color: Qt.rgba(1, 1, 1, 0.20)
        width: Math.min(es.width - 80, 1180); height: body.y + body.height + 18
        opacity: es.show; onHeightChanged: regions.restart(); onYChanged: regions.restart()
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }
        Text { x: 26; y: 17; text: strip.title; color: "white"; font.pixelSize: 15; font.weight: Font.DemiBold }
        Text { x: 26; y: 39; text: strip.hint; color: Qt.rgba(1, 1, 1, 0.55); font.pixelSize: 11 }
        Row { anchors.right: parent.right; anchors.rightMargin: 22; y: 16; spacing: 6
            Repeater { model: strip.tabs
                Rectangle { id: tb; required property var modelData; required property int index; readonly property bool on: strip.tab === index
                    width: tt.implicitWidth + 26; height: 28; radius: 14; color: on ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(1, 1, 1, th.hovered ? 0.10 : 0.04); Behavior on color { ColorAnimation { duration: Config.quick } }
                    Text { id: tt; anchors.centerIn: parent; text: tb.modelData.name; color: "white"; opacity: tb.on ? 1 : 0.75; font.pixelSize: 12; font.weight: tb.on ? Font.DemiBold : Font.Normal }
                    HoverHandler { id: th; cursorShape: Qt.PointingHandCursor } TapHandler { onTapped: strip.tab = tb.index } } } }
        Column { id: body; x: 26; y: 66; width: parent.width - 52; spacing: 10
            Flow { width: parent.width; spacing: 30
                Repeater { model: strip.tabs.length ? strip.tabs[strip.tab].items : []; Option {} } }
        }
    }

    Rectangle { anchors.fill: parent; color: Qt.rgba(0, 0, 0, 0.36 * es.show) }        // the dim (the panel windows draw above it)
    Item { id: keys; anchors.fill: parent; focus: true; Keys.onPressed: e => { if (e.key === Qt.Key_Escape) { es.done(); e.accepted = true } }
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons } }

    readonly property var panelTabs: es.dockTabs.concat([es.clockTab])
    Strip { id: dockStrip; anchors.horizontalCenter: parent.horizontalCenter; y: es.dockHole.y - height - 26 + (1 - es.show) * 14
        title: "Panel"; hint: "Drag icons to reorder  ·  × unpins  ·  right-click an app to pin it"; tabs: es.panelTabs }

    // ---- Screens: which screens show the panel. Only with more than one screen.
    Rectangle { id: screensStrip; visible: Qt.application.screens.length > 1; anchors.horizontalCenter: parent.horizontalCenter
        y: pill.y - height - 14; radius: 26                                  // just above the pill, between the two strips
        width: Math.min(es.width - 80, 1180); height: sbody.y + sbody.height + 18
        color: Qt.rgba(0.07, 0.08, 0.11, 0.55); border.width: 1; border.color: Qt.rgba(1, 1, 1, 0.20); opacity: es.show
        onHeightChanged: regions.restart(); onYChanged: regions.restart()
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }
        Text { x: 26; y: 17; text: "Screens"; color: "white"; font.pixelSize: 15; font.weight: Font.DemiBold }
        Text { x: 26; y: 39; text: "Choose screens for the panel. Popups and shortcuts use the primary screen."; color: Qt.rgba(1, 1, 1, 0.55); font.pixelSize: 11 }
        Column { id: sbody; x: 26; y: 66; width: parent.width - 52; spacing: 8
            Repeater { model: Qt.application.screens
                Row { id: sr; required property var modelData; spacing: 18; height: 32
                    readonly property string sname: modelData.name
                    readonly property bool isPrimary: sname === Shell.primaryScreenName
                    readonly property var ch: (Config.get("screens", {}) || {})[sname] || {}
                    function setChoice(key, on) { const all = Object.assign({}, Config.get("screens", {}) || {}); const mine = Object.assign({}, all[sname] || {}); mine[key] = on; all[sname] = mine; Shell.saveConfigKey("screens", all) }
                    Text { width: 300; anchors.verticalCenter: parent.verticalCenter; elide: Text.ElideRight; color: "white"; font.pixelSize: 13
                        text: sr.sname + "  ·  " + sr.modelData.width + " × " + sr.modelData.height + (sr.isPrimary ? "  ·  primary" : "") }
                    Row { spacing: 8; anchors.verticalCenter: parent.verticalCenter
                        Text { text: "Panel"; color: Qt.rgba(1, 1, 1, 0.75); font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                        GlassSwitch { checked: sr.ch.panel !== undefined ? !!sr.ch.panel : ((sr.ch.bar !== undefined ? !!sr.ch.bar : sr.isPrimary) || (sr.ch.dock !== undefined ? !!sr.ch.dock : sr.isPrimary)); onToggled: on => sr.setChoice("panel", on) } }
                    PillBtn { visible: !sr.isPrimary; label: "Make primary"; onTapped: Shell.saveConfigKey("primaryScreen", sr.sname) } } } } }

    Rectangle { id: pill; anchors.horizontalCenter: parent.horizontalCenter; radius: height / 2
        y: dockStrip.y - height - 14 - (screensStrip.visible ? Math.round((screensStrip.height + 14) / 2) : 0)
        width: pr.implicitWidth + 44; height: 56; color: Qt.rgba(0.07, 0.08, 0.11, 0.55); border.width: 1; border.color: Qt.rgba(1, 1, 1, 0.20); opacity: es.show
        onYChanged: regions.restart(); onWidthChanged: regions.restart()
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }
        Row { id: pr; anchors.centerIn: parent; spacing: 12
            Text { text: "Editing the desktop"; color: "white"; font.pixelSize: 14; font.weight: Font.DemiBold; anchors.verticalCenter: parent.verticalCenter; rightPadding: 8 }
            PillBtn { label: "Reset panel"; onTapped: Shell.removeConfigKeys(es.keysOf(es.panelTabs, [])) }
            PillBtn { label: "More settings…"; onTapped: es.moreSettings() }
            PillBtn { label: "Done"; primary: true; onTapped: es.done() } } }
}
