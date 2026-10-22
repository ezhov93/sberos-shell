// Shell settings use the shared SberOS UI Kit; configuration belongs to the shell.
import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import Sber.Controls as Sber
import Sber.Core as SberCore
import Sber.Theme
import SircaShell

Window {
    id: win
    title: "SberOS — Shell Settings"
    width: 1040
    height: 760
    minimumWidth: 900
    minimumHeight: 600
    color: Theme.Palette.Background.Default.Primary
    visible: false

    function openIt(atPage) {
        if (atPage !== undefined && atPage >= 0 && atPage < pages.length)
            page = atPage;
        visible = true;
        raise();
        requestActivate();
    }
    function syncTheme() {
        SberCore.Core.Settings.LineHeight = Theme.Sizes.LineHeight.S;
        SberCore.Core.Settings.setThemeMode(Config.dark ? SberCore.Settings.Dark : SberCore.Settings.Light);
    }
    Component.onCompleted: syncTheme()
    Connections {
        target: Config
        function onDarkChanged() {
            win.syncTheme();
        }
    }

    property int page: 0
    readonly property var pages: [
        {
            name: "Appearance"
        },
        {
            name: "System area"
        },
        {
            name: "Panel"
        },
        {
            name: "Behaviour"
        },
        {
            name: "Desktop"
        },
        {
            name: "About"
        }
    ]
    property var pending: ({})
    function flushWrites() {
        writeLater.stop();
        const changes = pending;
        pending = ({});
        if (Object.keys(changes).length)
            Shell.saveConfigKeys(changes);
    }
    function setKey(key, value, now) {
        const changes = Object.assign({}, pending);
        changes[key] = value;
        pending = changes;
        if (now)
            flushWrites();
        else if (!writeLater.running)
            writeLater.start();
    }
    function resetKey(key) {
        flushWrites();
        Shell.removeConfigKey(key);
    }
    Timer {
        id: writeLater
        interval: 50
        onTriggered: win.flushWrites()
    }
    onClosing: flushWrites()
    onVisibleChanged: if (!visible)
        flushWrites()
    onPageChanged: {
        flushWrites();
        content.contentY = 0;
    }
    Component.onDestruction: flushWrites()

    component Section: Column {
        property string title
        default property alias rows: body.data
        width: parent ? parent.width : 0
        spacing: 12
        Sber.Label {
            text: parent.title
            font: Theme.Fonts.HeaderH4B
        }
        Rectangle {
            width: parent.width
            height: body.implicitHeight + 24
            radius: Theme.Sizes.BorderRadius.M
            color: Theme.Palette.Background.Default.Secondary
            Column {
                id: body
                x: 16
                y: 12
                width: parent.width - 32
                spacing: 16
            }
        }
    }
    component Row_: Column {
        id: row
        property string label
        property string hint: ""
        property string key: ""
        default property alias control: slot.data
        readonly property bool custom: key !== "" && Config.user && Config.user[key] !== undefined
        width: parent ? parent.width : 0
        spacing: 6
        Sber.Label {
            text: row.label
            bold: true
            width: parent.width
            wrapMode: Text.Wrap
        }
        Sber.Label {
            text: row.hint
            visible: text !== ""
            secondary: true
            width: parent.width
            wrapMode: Text.Wrap
        }
        RowLayout {
            width: parent.width
            spacing: 12
            Item {
                id: slot
                property string settingLabel: row.label
                property string settingHint: row.hint
                implicitWidth: childrenRect.width
                implicitHeight: childrenRect.height
                Layout.fillWidth: true
            }
            Sber.Button {
                text: "Reset"
                type: Sber.Widget.Secondary
                backgroundType: Sber.Widget.Clear
                visible: row.key !== ""
                enabled: row.custom
                Accessible.name: "Reset " + row.label
                onClicked: win.resetKey(row.key)
            }
        }
    }
    component Toggle: Sber.Switch {
        Accessible.name: parent ? parent.settingLabel : ""
        Accessible.description: parent ? parent.settingHint : ""
    }

    component Num: RowLayout {
        id: n
        property string key
        property real from
        property real to
        property real step: 1
        property real value
        property string unit: ""
        property int decimals: 0
        width: 400
        spacing: 16
        Sber.Slider {
            id: slider
            objectName: "setting-" + n.key
            Layout.preferredWidth: 300
            from: n.from
            to: n.to
            stepSize: n.step
            showRangeValues: false
            Accessible.name: n.parent ? n.parent.settingLabel : ""
            Binding {
                target: slider
                property: "value"
                value: n.value
                when: !slider.pressed
            }
            onValueEdited: v => win.setKey(n.key, n.decimals > 0 ? Number(v.toFixed(n.decimals)) : Math.round(v), false)
            onEditingFinished: v => win.setKey(n.key, n.decimals > 0 ? Number(v.toFixed(n.decimals)) : Math.round(v), true)
        }
        Sber.Label {
            Layout.preferredWidth: 72
            secondary: true
            text: (n.decimals > 0 ? n.value.toFixed(n.decimals) : Math.round(n.value)) + n.unit
        }
    }
    component Choice: Sber.Button {
        id: choice
        property bool on: false
        property color dot: "transparent"
        signal tapped
        type: on ? Sber.Widget.Accient : Sber.Widget.Secondary
        checked: on
        onClicked: tapped()
        contentItem: Row {
            spacing: 8
            Rectangle {
                visible: choice.dot.a > 0
                width: 12
                height: 12
                radius: 6
                color: choice.dot
                anchors.verticalCenter: parent.verticalCenter
            }
            Sber.Label {
                text: choice.text
                type: choice.type
                bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Rectangle {
        id: side
        width: 204
        height: parent.height
        color: Theme.Palette.Background.Default.Secondary
        Column {
            x: 16
            y: 24
            width: parent.width - 32
            spacing: 8
            Sber.Label {
                text: "Shell Settings"
                bold: true
                bottomPadding: 16
            }
            Repeater {
                model: win.pages
                Sber.Button {
                    required property int index
                    required property var modelData
                    width: parent.width
                    text: modelData.name
                    type: win.page === index ? Sber.Widget.Accient : Sber.Widget.Secondary
                    onClicked: win.page = index
                }
            }
        }
    }
    Item {
        x: side.width
        width: parent.width - side.width
        height: parent.height
        Flickable {
            id: content
            anchors.fill: parent
            anchors.margins: 24
            contentWidth: width
            contentHeight: stack.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            Sber.ScrollBar.vertical: Sber.ScrollBar {}
            // Reveal controls reached with Tab even below the visible viewport.
            Connections {
                target: win
                function onActiveFocusItemChanged() {
                    const item = win.activeFocusItem;
                    let ancestor = item;
                    while (ancestor && ancestor !== stack)
                        ancestor = ancestor.parent;
                    if (!item || ancestor !== stack)
                        return;
                    const pt = item.mapToItem(stack, 0, 0);
                    if (pt.y < content.contentY)
                        content.contentY = Math.max(0, pt.y - 8);
                    else if (pt.y + item.height > content.contentY + content.height)
                        content.contentY = Math.min(content.contentHeight - content.height, pt.y + item.height - content.height + 8);
                }
            }
            Column {
                id: stack
                width: parent.width
                spacing: 24
                Sber.Label {
                    text: win.pages[win.page].name
                    font: Theme.Fonts.HeaderH4B
                }

                // Appearance
                Column {
                    visible: win.page === 0
                    width: parent.width
                    spacing: 18
                    Section {
                        title: "Popups"
                        Row_ {
                            label: "Popup corners"
                            hint: "Roundness of popup windows"
                            key: "cornerRadius"
                            Num {
                                key: "cornerRadius"
                                from: 8
                                to: 30
                                value: Config.cornerRadius
                                unit: " px"
                            }
                        }
                    }
                }

                // System area
                Column {
                    visible: win.page === 1
                    width: parent.width
                    spacing: 18
                    Section {
                        title: "Weather"
                        Row_ {
                            label: "Weather"
                            hint: "Open-Meteo forecast for the clock popup and panel weather indicator"
                            key: "weather"
                            Toggle {
                                checked: Config.weatherOn
                                onToggled: win.setKey("weather", checked, true)
                            }
                        }
                        Row_ {
                            label: "Location"
                            hint: Weather.locationName !== "" ? Weather.locationName : "Type a town and pick a hit"
                            key: "weatherLocation"
                            Column {
                                id: placeCol
                                spacing: 8
                                Sber.TextField {
                                    id: placeField
                                    width: 360
                                    placeholderText: "Town or city"
                                    Accessible.name: "Weather location"
                                    onTextEdited: placeTimer.restart()
                                    onAccepted: Weather.searchPlace(text)
                                }
                                Timer {
                                    id: placeTimer
                                    interval: 450
                                    onTriggered: Weather.searchPlace(placeField.text)
                                }
                                Connections {
                                    target: Weather
                                    function onPlacesFound(list) {
                                        places.clear();
                                        for (const p of list)
                                            places.append(p);
                                    }
                                }
                                ListModel {
                                    id: places
                                }
                                Repeater {
                                    model: places
                                    Sber.Button {
                                        id: hit
                                        required property var model
                                        width: 360
                                        type: Sber.Widget.Secondary
                                        text: model.name + (model.region ? ", " + model.region : "") + (model.country ? " · " + model.country : "")
                                        contentItem: Sber.Label {
                                            text: hit.text
                                            elide: Text.ElideRight
                                        }
                                        onClicked: {
                                            win.flushWrites();
                                            Shell.saveConfigKeys({
                                                weatherLocation: {
                                                    lat: model.lat,
                                                    lon: model.lon,
                                                    name: model.name
                                                },
                                                weather: true
                                            });
                                            placeTimer.stop();
                                            placeField.text = "";
                                            places.clear();
                                        }
                                    }
                                }
                            }
                        }
                        Row_ {
                            label: "Units"
                            key: "weatherUnits"
                            Row {
                                spacing: 8
                                Choice {
                                    text: "°C"
                                    on: Config.get("weatherUnits", "c") !== "f"
                                    onTapped: win.setKey("weatherUnits", "c", true)
                                }
                                Choice {
                                    text: "°F"
                                    on: Config.get("weatherUnits", "c") === "f"
                                    onTapped: win.setKey("weatherUnits", "f", true)
                                }
                            }
                        }
                    }
                    Section {
                        title: "Tile widgets"
                        Row_ {
                            label: "Click"
                            hint: "Panel quick-settings indicators: choose whether a click opens the tile page or toggles it"
                            key: "barTileClick"
                            Flow {
                                id: clickFlow
                                width: 330
                                spacing: 6
                                readonly property var names: ({
                                        volume: "Volume",
                                        network: "Network",
                                        bluetooth: "Bluetooth",
                                        dnd: "Do Not Disturb",
                                        nightlight: "Night Light",
                                        power: "Power profile",
                                        caffeine: "Caffeine",
                                        mic: "Microphone"
                                    })
                                readonly property var modes: Config.get("barTileClick", {}) || {}
                                function modeOf(id) {
                                    const m = modes[id];
                                    if (m === "page" || m === "toggle")
                                        return m;
                                    return (id === "volume" || id === "network") ? "page" : "toggle";
                                }
                                Repeater {
                                    model: ["volume", "network", "bluetooth", "dnd", "nightlight", "power", "caffeine", "mic"]
                                    Choice {
                                        required property string modelData
                                        text: clickFlow.names[modelData] + ": " + (clickFlow.modeOf(modelData) === "page" ? "open" : "toggle")
                                        on: clickFlow.modeOf(modelData) === "page"
                                        onTapped: {
                                            const m = Object.assign({}, clickFlow.modes);
                                            m[modelData] = clickFlow.modeOf(modelData) === "page" ? "toggle" : "page";
                                            win.setKey("barTileClick", m, true);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Section {
                        title: "Quick settings"
                        Row_ {
                            label: "Tiles"
                            hint: "What the panel shows. Right-click a tile in the panel to drag them into another order"
                            key: "qsTiles"
                            Flow {
                                id: tileFlow
                                width: 330
                                spacing: 6
                                readonly property var names: ({
                                        network: "Network",
                                        bluetooth: "Bluetooth",
                                        dnd: "Do Not Disturb",
                                        nightlight: "Night Light",
                                        power: "Power profile",
                                        caffeine: "Caffeine",
                                        mic: "Microphone",
                                        displays: "Displays",
                                        settings: "System Settings",
                                        sun: "Follow the sun",
                                        sliders: "Sliders"
                                    })
                                readonly property var all: ["network", "bluetooth", "dnd", "nightlight", "power", "caffeine", "mic", "displays", "settings", "sun", "sliders"]
                                readonly property var shown: {
                                    const v = Config.get("qsTiles", null);
                                    return v && v.length !== undefined ? Array.prototype.slice.call(v) : all;
                                }
                                Repeater {
                                    model: tileFlow.all
                                    Choice {
                                        required property string modelData
                                        text: tileFlow.names[modelData]
                                        on: tileFlow.shown.indexOf(modelData) >= 0
                                        onTapped: {
                                            let l = tileFlow.shown.slice();
                                            if (on)
                                                l = l.filter(x => x !== modelData);
                                            else
                                                l.push(modelData);
                                            win.setKey("qsTiles", l, true);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Section {
                        title: "Content"
                        Row_ {
                            label: "Clock size"
                            key: "clockSize"
                            Num {
                                key: "clockSize"
                                from: 12
                                to: 22
                                value: Config.clockSize
                                unit: " px"
                            }
                        }
                        Row_ {
                            label: "Popup padding"
                            hint: "Air between a popup's content and the glass"
                            key: "lobePad"
                            Num {
                                key: "lobePad"
                                from: 4
                                to: 20
                                value: Config.lobePad
                                unit: " px"
                            }
                        }
                    }
                }

                // Dock
                Column {
                    visible: win.page === 2
                    width: parent.width
                    spacing: 18
                    Section {
                        title: "Size"
                        Row_ {
                            label: "Icon size"
                            key: "dockIcon"
                            Num {
                                key: "dockIcon"
                                from: 32
                                to: 64
                                value: Config.dockIcon
                                unit: " px"
                            }
                        }
                        Row_ {
                            label: "Cell width"
                            hint: "Space per icon"
                            key: "dockCell"
                            Num {
                                key: "dockCell"
                                from: 44
                                to: 84
                                value: Config.dockCell
                                unit: " px"
                            }
                        }
                        Row_ {
                            label: "Height"
                            key: "dockHeight"
                            Num {
                                key: "dockHeight"
                                from: 44
                                to: 84
                                value: Config.dockHeight
                                unit: " px"
                            }
                        }
                        Row_ {
                            label: "Gap to the screen edge"
                            key: "dockGap"
                            Num {
                                key: "dockGap"
                                from: 0
                                to: 24
                                value: Config.dockGap
                                unit: " px"
                            }
                        }
                    }
                    Section {
                        title: "Hover"
                        Row_ {
                            label: "Magnification"
                            hint: "1.00 = none"
                            key: "dockMagnify"
                            Num {
                                key: "dockMagnify"
                                from: 1
                                to: 1.6
                                step: 0.01
                                decimals: 2
                                value: Config.dockMagnify
                                unit: "×"
                            }
                        }
                    }
                }

                // Behaviour
                Column {
                    visible: win.page === 3
                    width: parent.width
                    spacing: 18
                    Section {
                        title: "Windows"
                        Row_ {
                            label: "Panel and windows"
                            key: "dockVisibility"
                            Row {
                                spacing: 6
                                Choice {
                                    text: "Never touch"
                                    on: Config.dockVisibility === "always"
                                    onTapped: win.setKey("dockVisibility", "always", true)
                                }
                                Choice {
                                    text: "Hide"
                                    on: Config.dockVisibility === "dodge"
                                    onTapped: win.setKey("dockVisibility", "dodge", true)
                                }
                                Choice {
                                    text: "Below"
                                    on: Config.dockVisibility === "below"
                                    onTapped: win.setKey("dockVisibility", "below", true)
                                }
                            }
                        }
                        Row_ {
                            label: "Snap zones"
                            hint: "While you drag a window a strip of layouts appears under the bar; drop on one to tile the window there"
                            key: "snapZones"
                            Toggle {
                                checked: Config.get("snapZones", true) !== false
                                onToggled: win.setKey("snapZones", checked, true)
                            }
                        }
                        Row_ {
                            label: "Record sound"
                            hint: "Screen recordings include what the computer plays. The microphone is never recorded"
                            key: "recordSound"
                            Toggle {
                                checked: Config.recordSound
                                onToggled: win.setKey("recordSound", checked, true)
                            }
                        }
                        Row_ {
                            label: "Live level meter"
                            hint: "The now-playing bars follow the real sound level. Redraws the bar about 25 times a second while music plays (about 1-2 % GPU here); off = still bars"
                            key: "levelMeter"
                            Toggle {
                                checked: Config.levelMeter
                                onToggled: win.setKey("levelMeter", checked, true)
                            }
                        }
                        Row_ {
                            label: "Frame meter"
                            hint: "Frames per second and the longest frame gap, on the bar's and the dock's surface. Reads idle when nothing repaints"
                            key: "showFps"
                            Toggle {
                                checked: Config.showFps
                                onToggled: win.setKey("showFps", checked, true)
                            }
                        }
                    }
                    Section {
                        title: "Notifications"
                        Row_ {
                            label: "Quiet during games and full screen"
                            hint: "No popups then; they wait in the history. Critical ones still show"
                            key: "quietWhenBusy"
                            Toggle {
                                checked: Config.quietWhenBusy
                                onToggled: win.setKey("quietWhenBusy", checked, true)
                            }
                        }
                    }
                    Section {
                        title: "Keys"
                        Row_ {
                            label: "Search"
                            hint: "Meta + Space"
                            Sber.Label {
                                text: "Meta+Space"
                                secondary: true
                            }
                        }
                        Row_ {
                            label: "Launcher"
                            hint: "Tap Meta"
                            Sber.Label {
                                text: "Meta"
                                secondary: true
                            }
                        }
                        Row_ {
                            label: "Switch windows"
                            Sber.Label {
                                text: "Alt+Tab"
                                secondary: true
                            }
                        }
                    }
                }

                // Desktop
                Column {
                    visible: win.page === 4
                    width: parent.width
                    spacing: 18
                    Section {
                        title: "Wallpaper"
                        Item {
                            width: parent.width
                            height: wpGrid.implicitHeight + 24
                            readonly property var files: win.page === 4 ? Shell.wallpaperFiles(Config.wallpaperFolder) : []
                            readonly property string current: Config.wallpaper !== "" ? Config.wallpaper : Shell.plasmaWallpaper()
                            Flow {
                                id: wpGrid
                                x: 12
                                y: 12
                                width: parent.width - 24
                                spacing: 10
                                Repeater {
                                    model: parent.parent.files
                                    Sber.Button {
                                        id: th
                                        required property string modelData
                                        width: (wpGrid.width - 20) / 3
                                        height: width * 0.5
                                        type: modelData === parent.parent.current ? Sber.Widget.Accient : Sber.Widget.Secondary
                                        backgroundType: Sber.Widget.Outline
                                        Accessible.name: "Wallpaper " + modelData.split("/").pop()
                                        contentItem: Image {
                                            source: "file://" + th.modelData
                                            sourceSize: Qt.size(360, 180)
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                        }
                                        onClicked: {
                                            win.setKey("wallpaper", modelData, true);
                                            if (Shell.plasmaRunning)
                                                Shell.runDetached("plasma-apply-wallpaperimage", [modelData]);
                                        }
                                    }
                                }
                            }
                        }
                        Row_ {
                            label: "Follow Plasma's wallpaper"
                            hint: Config.wallpaper === "" ? "On: the shell shows what Plasma shows" : "Off: you picked one above"
                            key: "wallpaper"
                            Choice {
                                text: "Follow Plasma"
                                on: Config.wallpaper === ""
                                onTapped: win.resetKey("wallpaper")
                            }
                        }
                        Sber.Label {
                            x: 16
                            bottomPadding: 10
                            width: parent.width - 32
                            wrapMode: Text.Wrap
                            secondary: true
                            text: "Pictures from " + Config.wallpaperFolder + ". A pick is applied to the shell's own background layer and, while Plasma's desktop is running, to Plasma as well."
                        }
                    }
                    Section {
                        title: "Folder colour"
                        visible: Shell.hasProgram("glass-folder-color")
                        Item {
                            width: parent.width
                            height: fflow.implicitHeight + 24
                            Flow {
                                id: fflow
                                x: 14
                                y: 12
                                width: parent.width - 28
                                spacing: 8
                                Repeater {
                                    model: [["blue", "#5294e2"], ["indigo", "#5c6bc0"], ["bluegrey", "#607d8b"], ["nordic", "#5e81ac"], ["darkcyan", "#45abb7"], ["violet", "#7e57c2"], ["grey", "#8e8e8e"], ["black", "#4f4f4f"]]   // literal-ok: colour swatches
                                    Choice {
                                        required property var modelData
                                        text: modelData[0]
                                        dot: modelData[1]
                                        onTapped: Shell.runDetached("glass-folder-color", [modelData[0]])
                                    }
                                }
                            }
                        }
                        Sber.Label {
                            x: 16
                            bottomPadding: 10
                            text: "Applies to your Papirus copy. File managers show it after a restart."
                            secondary: true
                        }
                    }
                    Section {
                        title: "System"
                        Row_ {
                            label: "Colours, fonts, Plasma's wallpaper"
                            hint: "Plasma's own settings"
                            Choice {
                                text: "Open System Settings"
                                onTapped: Shell.runDetached("systemsettings", [])
                            }
                        }
                    }
                }

                // About
                Column {
                    visible: win.page === 5
                    width: parent.width
                    spacing: 18
                    Section {
                        title: "Sirca Shell"
                        Row_ {
                            label: "Version"
                            Sber.Label {
                                text: Shell.version + (Shell.buildCommit !== "" ? "  ·  build " + Shell.buildCommit.substring(0, 7) : "")
                                secondary: true
                                font.features: {
                                    "tnum": 1
                                }
                            }
                        }
                        Row_ {
                            label: "Config file"
                            Sber.Label {
                                text: Shell.configPath()
                                secondary: true
                                width: parent.width
                                wrapMode: Text.Wrap
                            }
                        }
                        Row_ {
                            label: "Changed settings"
                            Sber.Label {
                                text: Config.user ? Object.keys(Config.user).filter(k => k !== "launchers").length + " keys" : "0 keys"
                                secondary: true
                            }
                        }
                        Row_ {
                            label: "Reload the shell"
                            hint: "Checks the build first; a broken build is refused"
                            Choice {
                                text: "Reload"
                                enabled: Shell.toolPath("sirca-shell-reload") !== ""
                                opacity: enabled ? 1 : 0.4
                                onTapped: {
                                    const p = Shell.toolPath("sirca-shell-reload");
                                    if (p !== "")
                                        Shell.runDetached(p, []);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
