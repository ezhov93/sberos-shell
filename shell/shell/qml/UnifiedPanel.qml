// One bottom surface combines the task strip with the former top bar's system functions.
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import Sber.Controls as Sber
import Sber.Core as SberCore
import Sber.Theme
import SircaShell

Dock {
    id: panel
    unified: true
    title: "SberOS — Panel"
    leadingWidth: leading.implicitWidth + 12
    trailingWidth: statusViewport.width + essential.width + 20
    property var recorder: null
    property bool busy: fullscreenActive || gameActive
    property bool showingDesktop: false
    property string activeTitle: ""
    property string activeApp: ""
    property var activeIcon
    signal showDesktopRequested
    signal searchRequested
    property string openLobe: ""
    property string requestedPage: "main"
    property real popupAnchor: width - trailingWidth / 2
    readonly property var nativeControl: controlLoader.item
    readonly property var notifications: historyLoader.item
    readonly property bool mediaAvailable: media.hasTrack
    readonly property int barW: dockW
    readonly property bool showingCards: openLobe === "" && !launcherOpen && !previewShown && cards.count > 0
    readonly property Item systemView: showingCards ? cards : openLobe === "clock" ? calendarLoader.item : openLobe === "gear" ? controlLoader.item : openLobe === "notif" ? historyLoader.item : openLobe === "tray" ? trayMenuLoader.item : openLobe === "media" ? mediaLoader.item : openLobe === "disks" ? disksLoader.item : openLobe === "system" ? monitorLoader.item : null
    systemOpen: openLobe !== "" || showingCards
    systemFocus: openLobe !== ""
    restingKeyboardMode: cards.replyingCount > 0 ? "ondemand" : "none"
    systemWidth: Math.min(screenW - 48, (systemView ? systemView.implicitWidth || systemView.width : 360) + 2 * lobePad)
    systemHeight: Math.min(Math.max(100, Screen.height - dockH - 2 * gap - 48), (systemView ? systemView.implicitHeight || systemView.height : 240) + 2 * lobePad)
    systemAnchorX: popupAnchor
    onSystemCloseRequested: openLobe = ""
    onOpenLobeChanged: {
        if (openLobe !== "") {
            warm = true;
            launcherOpen = false;
            previewShown = false;
        }
        if (openLobe !== "tray")
            nativeTray.openItem = null;
    }
    function toggle(name) {
        openLobe = openLobe === name ? "" : name;
    }
    function openAt(name, item) {
        popupAnchor = item.mapToItem(panel.contentItem, item.width / 2, 0).x;
        toggle(name);
    }
    function placeMedia() {
        popupAnchor = media.mapToItem(panel.contentItem, media.width / 2, 0).x;
    }
    function openPage(page) {
        requestedPage = page || "main";
        warm = true;
        openLobe = "gear";
        if (controlLoader.item && controlLoader.item.page !== undefined)
            controlLoader.item.page = requestedPage;
    }
    function openSoundPage() {
        openPage("sound");
    }
    function openTrayMenuAt(index) {
        nativeTray.requestMenuAt(index);
    }
    function syncTheme() {
        SberCore.Core.Settings.LineHeight = Theme.Sizes.LineHeight.S;
        SberCore.Core.Settings.setThemeMode(Config.dark ? SberCore.Settings.Dark : SberCore.Settings.Light);
    }
    Component.onCompleted: syncTheme()
    Connections {
        target: Config
        function onDarkChanged() {
            panel.syncTheme();
        }
    }
    readonly property var placedWidgets: Config.barLeft.concat(Config.barCenter, Config.barRight)
    function placed(name) {
        return placedWidgets.indexOf(name) >= 0;
    }

    component PanelButton: Sber.Button {
        id: button
        property string symbol: ""
        property string description: ""
        lineHeight: Math.min(panel.dockH - 8, Theme.Sizes.LineHeight.S)
        font: Theme.Fonts.BodySB
        type: Sber.Widget.Secondary
        backgroundType: Sber.Widget.Clear
        Accessible.name: description !== "" ? description : text
        implicitWidth: symbol !== "" ? lineHeight : label.implicitWidth + 20
        contentItem: Item {
            implicitWidth: label.implicitWidth
            implicitHeight: label.implicitHeight
            Kirigami.Icon {
                anchors.centerIn: parent
                visible: button.symbol !== ""
                width: 20
                height: 20
                source: button.symbol
                isMask: true
                color: Config.ink
            }
            Sber.Label {
                id: label
                anchors.centerIn: parent
                visible: button.symbol === ""
                text: button.text
                color: Config.ink
                font: button.font
            }
        }
        Sber.ToolTip.visible: hovered
        Sber.ToolTip.text: description
    }

    Row {
        id: leading
        enabled: !panel.editing
        x: panel.barRect.x + panel.pad
        y: panel.barRect.y + (panel.dockH - height) / 2
        height: Math.min(panel.dockH - 8, Theme.Sizes.LineHeight.S)
        spacing: 4
        PanelButton {
            symbol: "edit-find-symbolic"
            description: qsTr("Search")
            onClicked: panel.searchRequested()
        }
        PanelButton {
            symbol: "user-desktop-symbolic"
            description: qsTr("Show desktop")
            onClicked: panel.showDesktopRequested()
        }
        Workspaces {
            visible: panel.screenW >= 1100 && shown
            allowed: panel.placed("workspaces")
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    Flickable {
        id: statusViewport
        enabled: !panel.editing
        x: essential.x - width - 8
        y: panel.barRect.y
        width: Math.max(0, Math.min(status.implicitWidth, panel.screenW * 0.36, panel.dockW - panel.leadingWidth - essential.width - 3 * panel.pad - Config.dockCell))
        height: panel.dockH
        contentWidth: status.implicitWidth
        contentHeight: height
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalFlick
        Row {
            id: status
            height: panel.dockH
            spacing: 6
            PanelButton {
                visible: !!panel.recorder && (panel.recorder.recording || panel.recorder.finishing)
                text: panel.recorder ? panel.recorder.clock : ""
                description: qsTr("Stop recording")
                anchors.verticalCenter: parent.verticalCenter
                enabled: !!panel.recorder && panel.recorder.recording
                onClicked: panel.recorder.stop()
            }
            MediaIsland {
                id: media
                anchors.verticalCenter: parent.verticalCenter
                allowed: panel.placed("media") && panel.screenW >= 1400
                quiet: panel.quiet
                lobeOpen: panel.openLobe === "media"
                barLeft: panel.x
                slideY: panel.y + panel.barRect.y
                onClicked: {
                    panel.placeMedia();
                    panel.toggle("media");
                }
            }
            WeatherWidget {
                anchors.verticalCenter: parent.verticalCenter
                allowed: panel.placed("weather")
                onClicked: panel.openAt("clock", this)
                onSetupRequested: Shell.openSettingsPage(1)
            }
            Repeater {
                model: panel.placedWidgets.filter(name => name.indexOf("tile:") === 0)
                BarTile {
                    required property string modelData
                    name: modelData.substring(5)
                    qs: panel.nativeControl
                    anchors.verticalCenter: parent.verticalCenter
                    onOpenPage: page => panel.openPage(page)
                    onOsd: (icon, value) => osd.show(icon, value)
                }
            }
            Repeater {
                model: panel.placedWidgets.filter(name => name.indexOf("user:") === 0)
                UserWidget {
                    required property string modelData
                    name: modelData.substring(5)
                    quiet: panel.quiet
                    width: implicitWidth
                    height: panel.dockH
                }
            }
            BarBattery {
                anchors.verticalCenter: parent.verticalCenter
                onClicked: panel.openPage("main")
            }
            BarPrivacy {
                anchors.verticalCenter: parent.verticalCenter
                audio: volumeLoader.item
                onClicked: panel.openSoundPage()
            }
            BarMic {
                anchors.verticalCenter: parent.verticalCenter
                audio: volumeLoader.item
                allowed: panel.placed("mic")
            }
            BarKeyboard {
                anchors.verticalCenter: parent.verticalCenter
                allowed: panel.placed("keyboard")
            }
            Flickable {
                width: Math.min(nativeTray.implicitWidth, Math.max(64, panel.screenW * 0.14))
                height: panel.dockH
                contentWidth: nativeTray.implicitWidth
                contentHeight: height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                Tray {
                    id: nativeTray
                    anchors.verticalCenter: parent.verticalCenter
                    onMenuRequested: (item, centerX) => {
                        panel.warm = true;
                        Qt.callLater(() => {
                            const menu = trayMenuLoader.item;
                            if (!menu)
                                return;
                            panel.popupAnchor = nativeTray.mapToItem(panel.contentItem, centerX, 0).x;
                            nativeTray.openItem = item;
                            menu.show(item);
                            panel.openLobe = "tray";
                        });
                    }
                }
            }
            PanelButton {
                symbol: "media-removable-symbolic"
                description: qsTr("Removable drives")
                anchors.verticalCenter: parent.verticalCenter
                onClicked: panel.openAt("disks", this)
            }
            PanelButton {
                symbol: "view-statistics-symbolic"
                description: qsTr("System monitor")
                visible: panel.placed("system")
                anchors.verticalCenter: parent.verticalCenter
                onClicked: panel.openAt("system", this)
            }
        }
    }
    Row {
        id: essential
        enabled: !panel.editing
        x: panel.barRect.x + panel.dockW - width - panel.pad
        y: panel.barRect.y
        height: panel.dockH
        spacing: 6
        PanelButton {
            symbol: "notifications-symbolic"
            description: qsTr("Notifications")
            anchors.verticalCenter: parent.verticalCenter
            onClicked: panel.openAt("notif", this)
        }
        PanelButton {
            id: clockButton
            property date now: new Date()
            Timer {
                interval: Config.clockSeconds ? 1000 : 10000
                running: panel.visible
                repeat: true
                triggeredOnStart: true
                onTriggered: clockButton.now = new Date()
            }
            text: (Config.clockDate && panel.screenW >= 1100 ? Qt.formatDate(now, Config.dateFormat) + "  " : "") + Qt.formatTime(now, (Config.clock24h ? "HH:mm" : "h:mm") + (Config.clockSeconds ? ":ss" : "") + (Config.clock24h ? "" : " AP"))
            font: Qt.font({
                family: Theme.Fonts.BodySB.family,
                pixelSize: Config.clockSize,
                bold: Config.clockBold
            })
            description: qsTr("Calendar")
            anchors.verticalCenter: parent.verticalCenter
            onClicked: panel.openAt("clock", this)
        }
        PanelButton {
            symbol: "configure-symbolic"
            description: qsTr("Quick settings")
            anchors.verticalCenter: parent.verticalCenter
            onClicked: panel.openAt("gear", this)
        }
    }
    Loader {
        id: volumeLoader
        active: panel.warm
        source: "VolumeBackend.qml"
    }

    // All system popups grow upward inside the same surface and share its input mask.
    Flickable {
        id: systemContent
        x: panel.systemRect.x + panel.lobePad
        y: panel.systemRect.y + panel.lobePad
        width: Math.max(1, panel.systemWidth - 2 * panel.lobePad)
        height: Math.max(0, panel.systemRect.height - 2 * panel.lobePad)
        contentWidth: width
        contentHeight: panel.systemView ? panel.systemView.implicitHeight || panel.systemView.height : 0
        visible: panel.systemUp
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        Sber.ScrollBar.vertical: Sber.ScrollBar {}
        Connections {
            target: panel
            function onOpenLobeChanged() {
                systemContent.contentY = 0;
            }
        }
        NotificationCards {
            id: cards
            visible: panel.showingCards
            muted: panel.busy && Config.quietWhenBusy
        }
        Loader {
            id: calendarLoader
            active: panel.warm
            visible: panel.openLobe === "clock"
            sourceComponent: CalendarPanel {
                open: panel.openLobe === "clock"
            }
        }
        Loader {
            id: controlLoader
            active: panel.warm
            visible: panel.openLobe === "gear"
            source: Config.quickSettingsStyle === "classic" ? "qrc:/qt/qml/SircaShell/qml/control/ControlPanel.qml" : "QuickSettings.qml"
            onLoaded: {
                if (item.page !== undefined)
                    item.page = panel.requestedPage;
                item.expanded = Qt.binding(() => panel.openLobe === "gear");
                if (item.busy !== undefined)
                    item.busy = Qt.binding(() => panel.busy);
            }
            Connections {
                target: controlLoader.item
                ignoreUnknownSignals: true
                function onCloseRequested() {
                    panel.openLobe = "";
                }
                function onOsdRequested(icon, fraction) {
                    osd.show(icon, fraction);
                }
            }
        }
        Loader {
            id: historyLoader
            active: panel.warm
            visible: panel.openLobe === "notif"
            sourceComponent: NotificationCenter {
                open: panel.openLobe === "notif"
            }
        }
        Loader {
            id: trayMenuLoader
            active: panel.warm
            visible: panel.openLobe === "tray"
            sourceComponent: TrayMenu {
                onCloseRequested: panel.openLobe = ""
            }
        }
        Loader {
            id: mediaLoader
            active: panel.warm
            visible: panel.openLobe === "media"
            source: "MediaPanel.qml"
            onLoaded: {
                item.mpris = Qt.binding(() => media.model);
                item.open = Qt.binding(() => panel.openLobe === "media");
            }
        }
        Loader {
            id: disksLoader
            active: panel.warm
            visible: panel.openLobe === "disks"
            sourceComponent: RemovableMedia {
                open: panel.openLobe === "disks"
            }
        }
        Loader {
            id: monitorLoader
            active: panel.warm
            visible: panel.openLobe === "system"
            sourceComponent: SysMon {
                open: panel.openLobe === "system"
            }
        }
    }
    // Passive OSD stays inside the panel and never requests keyboard focus.
    Rectangle {
        id: osd
        property string symbol: ""
        property real fraction: 0
        function show(icon, value) {
            symbol = icon;
            fraction = value;
            hideOsd.restart();
        }
        visible: hideOsd.running
        x: clockButton.mapToItem(panel.contentItem, 0, 0).x - 8
        y: panel.barRect.y + 4
        width: 112
        height: panel.dockH - 8
        radius: Theme.Sizes.BorderRadius.S
        color: Theme.Palette.Background.Default.Secondary
        Timer {
            id: hideOsd
            interval: 1600
        }
        Sber.Label {
            anchors.centerIn: parent
            text: Math.round(osd.fraction * 100) + "%"
        }
        Connections {
            target: Shell
            function onDbusSignal(iface, member, args) {
                if (iface === "org.kde.osdService" && member === "osdProgress" && args.length >= 2)
                    osd.show(String(args[0]), Number(args[1]) / 100);
            }
        }
    }
}
