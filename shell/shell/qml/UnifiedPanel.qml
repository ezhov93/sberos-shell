// One bottom surface combines the task strip with the former top bar's system functions.
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.notificationmanager as NotificationManager
import Sber.Controls as Sber
import Sber.Core as SberCore
import Sber.Theme
import SircaShell

Dock {
    id: panel
    unified: true
    title: "SberOS — Panel"
    // Fixed centre and right-hand budgets keep system changes out of the task/search geometry.
    readonly property real zoneGap: 8
    readonly property real oskaWidth: Math.min(456, screenW * 0.25)
    readonly property real systemZoneWidth: essential.implicitWidth + 16
    readonly property real trayIslandWidth: nativeTray.implicitWidth > 0 ? Math.min(Math.max(64, screenW * 0.10) + 16, nativeTray.implicitWidth + 16) : 0
    readonly property real trayGap: trayIslandWidth > 0 ? zoneGap : 0
    readonly property rect trayRect: Qt.rect(essentialRect.x - trayGap - trayIslandWidth, barRect.y, trayIslandWidth, dockH)
    readonly property rect sberRect: Qt.rect(barRect.x, barRect.y, dockH, dockH)
    readonly property rect oskaRect: Qt.rect((width - oskaWidth) / 2, barRect.y, oskaWidth, dockH)
    readonly property rect essentialRect: Qt.rect(barRect.x + dockW - systemZoneWidth, barRect.y, systemZoneWidth, dockH)
    readonly property rect applicationsRect: Qt.rect(sberRect.x + sberRect.width + zoneGap, barRect.y, Math.max(Config.dockCell + 2 * pad, Math.min(contentW, oskaRect.x - sberRect.x - sberRect.width - 2 * zoneGap)), dockH)
    panelZones: [sberRect, applicationsRect, oskaRect, trayRect, essentialRect]
    leadingWidth: applicationsRect.x - barRect.x
    trailingWidth: dockW - leadingWidth - applicationsRect.width
    taskAreaX: applicationsRect.x + pad
    taskAreaWidth: Math.max(Config.dockCell, applicationsRect.width - 2 * pad)
    property var recorder: null
    property bool busy: fullscreenActive || gameActive
    property bool showingDesktop: false
    property string activeTitle: ""
    property string activeApp: ""
    property var activeIcon
    signal showDesktopRequested
    signal sberRequested
    property string openLobe: ""
    property string previousOpenLobe: ""
    property bool retainingSearchSurface: false
    readonly property bool oskaSearchSurfaceActive: openLobe === "search" || retainingSearchSurface || oskaSearchSurface.reveal > 0.001
    property bool greetingVisible: true
    property string requestedPage: "main"
    property real popupAnchor: essentialRect.x + essentialRect.width / 2
    readonly property var nativeControl: controlLoader.item
    readonly property var notifications: historyLoader.item
    property int oskaNotificationRevision: 0
    readonly property bool oskaNotificationsInhibited: oskaNotificationSettings.notificationsInhibitedByApplication || (oskaNotificationSettings.notificationsInhibitedUntil instanceof Date && !isNaN(oskaNotificationSettings.notificationsInhibitedUntil.getTime()) && Date.now() < oskaNotificationSettings.notificationsInhibitedUntil.getTime())
    readonly property var oskaNotification: {
        oskaNotificationRevision;
        const roles = NotificationManager.Notifications;
        if (oskaFeed.count === 0)
            return null;
        const index = oskaFeed.index(0, 0);
        return {
            id: oskaFeed.data(index, roles.IdRole),
            summary: String(oskaFeed.data(index, roles.SummaryRole) || ""),
            body: String(oskaFeed.data(index, roles.BodyRole) || ""),
            applicationIcon: String(oskaFeed.data(index, roles.ApplicationIconNameRole) || ""),
            icon: String(oskaFeed.data(index, roles.IconNameRole) || "")
        };
    }
    readonly property bool oskaNotificationVisible: oskaSearchSurfaceActive && oskaNotification !== null
    readonly property real oskaNotificationHeight: oskaNotificationVisible ? 56 : 0
    readonly property real activeSystemViewHeight: oskaSearchSurfaceActive ? searchResults.y + searchResults.height + (oskaNotificationVisible ? 8 + oskaNotificationHeight : 0) : systemView ? systemView.y + (systemView.implicitHeight || systemView.height) : 0
    readonly property bool mediaAvailable: media.hasTrack
    readonly property int barW: dockW
    readonly property bool showingCards: openLobe === "" && !searchField.activeFocus && !launcherOpen && !overflowOpen && !previewShown && cards.count > 0
    readonly property Item systemView: showingCards ? cards : openLobe === "search" ? searchResults : openLobe === "clock" ? calendarLoader.item : openLobe === "gear" ? controlLoader.item : openLobe === "notif" ? historyLoader.item : openLobe === "tray" ? trayMenuLoader.item : openLobe === "media" ? mediaLoader.item : openLobe === "disks" ? disksLoader.item : openLobe === "system" ? monitorLoader.item : null
    systemOpen: openLobe !== "" || showingCards
    integratedSystemEnabled: oskaSearchSurfaceActive
    integratedSystemOpen: openLobe === "search"
    integratedSystemRect: oskaSearchSurface.contentRect
    integratedSystemSurfaceRect: oskaSearchSurface.surfaceRect
    systemFocus: openLobe !== "" || searchField.activeFocus
    restingKeyboardMode: cards.replyingCount > 0 ? "ondemand" : "none"
    systemContentInset: openLobe === "gear" ? 0 : lobePad
    systemInnerSurface: openLobe !== "gear"
    systemWidth: oskaSearchSurfaceActive || openLobe === "notif" || showingCards ? oskaWidth : Math.min(screenW - 48, (systemView ? systemView.implicitWidth || systemView.width : 360) + 2 * systemContentInset)
    systemGap: oskaSearchSurfaceActive ? 0 : openLobe === "notif" || showingCards ? 8 : 0
    systemHeight: Math.min(Math.max(100, Screen.height - dockH - 2 * gap - 48), (activeSystemViewHeight || 240) + 2 * systemContentInset)
    systemAnchorX: openLobe === "search" || showingCards ? searchField.mapToItem(panel.contentItem, searchField.width / 2, 0).x : popupAnchor
    onSystemCloseRequested: {
        if (openLobe === "search")
            searchField.focus = false;
        openLobe = "";
    }
    onOpenLobeChanged: {
        const previous = previousOpenLobe;
        previousOpenLobe = openLobe;
        if (openLobe === "search")
            retainingSearchSurface = false;
        else if (previous === "search" && openLobe === "" && (oskaSearchSurface.reveal > 0.001 || systemUp))
            retainingSearchSurface = true;
        if (openLobe !== "") {
            warm = true;
            launcherOpen = false;
            previewShown = false;
        }
        if (openLobe !== "tray")
            nativeTray.openItem = null;
    }
    function settleSearchSurface() {
        if (openLobe !== "search" && oskaSearchSurface.reveal <= 0.001 && !systemUp)
            retainingSearchSurface = false;
    }
    onSystemUpChanged: settleSearchSurface()
    Connections {
        target: oskaSearchSurface
        function onRevealChanged() {
            panel.settleSearchSurface();
        }
    }
    function toggle(name, anchor) {
        if (anchor !== undefined)
            popupAnchor = anchor;
        else if (name === "clock" || name === "gear")
            popupAnchor = essentialRect.x + essentialRect.width / 2;
        else if (name === "notif")
            popupAnchor = oskaRect.x + oskaRect.width / 2;
        openLobe = openLobe === name ? "" : name;
    }
    function openAt(name, item) {
        toggle(name, item.mapToItem(panel.contentItem, item.width / 2, 0).x);
    }
    function placeMedia() {
        popupAnchor = essentialRect.x + essentialRect.width / 2;
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
    function focusSearch(query) {
        if (query !== undefined)
            searchField.text = String(query);
        openLobe = searchField.text.trim() === "" ? "" : "search";
        searchField.forceActiveFocus();
    }
    function openTrayMenuAt(index) {
        nativeTray.requestMenuAt(index);
    }
    function syncTheme() {
        SberCore.Core.Settings.LineHeight = Theme.Sizes.LineHeight.S;
        SberCore.Core.Settings.setThemeMode(Config.dark ? SberCore.Settings.Dark : SberCore.Settings.Light);
    }
    Component.onCompleted: syncTheme()
    NotificationManager.Settings {
        id: oskaNotificationSettings
    }
    NotificationManager.Notifications {
        id: oskaFeed
        limit: 256
        showExpired: false
        showDismissed: false
        showAddedDuringInhibition: false
        showJobs: false
        blacklistedDesktopEntries: oskaNotificationSettings.popupBlacklistedApplications
        blacklistedNotifyRcNames: oskaNotificationSettings.popupBlacklistedServices
        whitelistedDesktopEntries: panel.oskaNotificationsInhibited ? oskaNotificationSettings.doNotDisturbPopupWhitelistedApplications : []
        whitelistedNotifyRcNames: panel.oskaNotificationsInhibited ? oskaNotificationSettings.doNotDisturbPopupWhitelistedServices : []
        sortMode: NotificationManager.Notifications.SortByDate
        sortOrder: Qt.AscendingOrder
        groupMode: NotificationManager.Notifications.GroupDisabled
        urgencies: NotificationManager.Notifications.LowUrgency | NotificationManager.Notifications.NormalUrgency | NotificationManager.Notifications.CriticalUrgency
    }
    Connections {
        target: oskaFeed
        function onCountChanged() {
            panel.oskaNotificationRevision++;
        }
        function onDataChanged() {
            panel.oskaNotificationRevision++;
        }
        function onRowsInserted() {
            panel.oskaNotificationRevision++;
        }
        function onRowsRemoved() {
            panel.oskaNotificationRevision++;
        }
        function onModelReset() {
            panel.oskaNotificationRevision++;
        }
        function onLayoutChanged() {
            panel.oskaNotificationRevision++;
        }
    }
    Timer {
        interval: 10000
        running: true
        onTriggered: panel.greetingVisible = false
    }
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
                color: Theme.Palette.Text.Default.Primary
            }
            Sber.Label {
                id: label
                anchors.centerIn: parent
                visible: button.symbol === ""
                text: button.text
                width: Math.max(0, button.width - 12)
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                color: Theme.Palette.Text.Default.Primary
                font: button.font
            }
        }
        Sber.ToolTip.visible: hovered
        Sber.ToolTip.text: description
    }

    PanelButton {
        objectName: "panel-sber"
        x: panel.sberRect.x + 4
        y: panel.sberRect.y + 4
        width: panel.sberRect.width - 8
        height: panel.sberRect.height - 8
        enabled: !panel.editing
        contentItem: Item {
            Sber.Icon {
                anchors.centerIn: parent
                width: 24
                height: 24
                name: "Sber"
                size: 24
                color: Theme.Palette.Text.Default.Primary
            }
        }
        description: qsTr("Sber menu")
        onClicked: panel.sberRequested()
    }
    Item {
        id: oska
        objectName: "panel-oska"
        x: panel.oskaRect.x
        y: panel.oskaRect.y
        width: panel.oskaRect.width
        height: panel.oskaRect.height
        enabled: !panel.editing
        PanelButton {
            id: notificationButton
            x: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            height: 40
            padding: 0
            description: qsTr("Notifications")
            contentItem: OskaAvatar {
                anchors.fill: parent
            }
            onClicked: panel.toggle("notif")
        }
        TextInput {
            id: searchField
            objectName: "searchButton"
            x: notificationButton.x + notificationButton.width + 10
            y: 4
            width: Math.max(0, layoutButton.x - x - 8)
            height: parent.height - 8
            verticalAlignment: TextInput.AlignVCenter
            color: Theme.Palette.Text.Default.Primary
            font: Theme.Fonts.BodyM
            clip: true
            selectByMouse: true
            selectionColor: Theme.Palette.Surface.Default.Accent
            selectedTextColor: Theme.Palette.Text.Default.Primary
            onTextChanged: {
                searchResults.currentIndex = 0;
                if (text.trim() !== "")
                    panel.openLobe = "search";
                else if (panel.openLobe === "search")
                    panel.openLobe = "";
            }
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    if (text !== "")
                        text = "";
                    else
                        focus = false;
                    event.accepted = true;
                } else if (event.key === Qt.Key_Down) {
                    searchResults.moveSelection(1);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Up) {
                    searchResults.moveSelection(-1);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    searchResults.runCurrent();
                    event.accepted = true;
                }
            }
            Accessible.name: qsTr("Find a document or application")
        }
        Text {
            anchors.left: searchField.left
            anchors.verticalCenter: parent.verticalCenter
            width: searchField.width
            visible: searchField.text === ""
            text: panel.greetingVisible ? qsTr("Привет, Михаил! Желаю хорошего дня") : qsTr("Найти приложение или документ")
            color: Theme.Palette.Text.Default.Secondary
            font: Theme.Fonts.BodySB
            elide: Text.ElideRight
            enabled: false
        }
        KeyboardInfo {
            id: keyboard
        }
        PanelButton {
            id: layoutButton
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            text: String(keyboard.layoutShort).toUpperCase()
            description: keyboard.layoutName
            onClicked: keyboard.nextLayout()
        }
    }
    Flickable {
        x: panel.trayRect.x + 8
        y: panel.barRect.y
        width: Math.max(0, panel.trayRect.width - 16)
        height: panel.dockH
        contentWidth: nativeTray.implicitWidth
        contentHeight: height
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        Tray {
            id: nativeTray
            flat: true
            symbolicColor: Theme.Palette.Text.Default.Primary
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
    MediaIsland {
        id: media
        visible: false
        allowed: false
    }
    Row {
        id: essential
        enabled: !panel.editing
        width: implicitWidth
        x: panel.essentialRect.x + panel.systemZoneWidth - width - 8
        y: panel.barRect.y
        height: panel.dockH
        spacing: 2
        PanelButton {
            symbol: "configure-symbolic"
            description: qsTr("Quick settings")
            anchors.verticalCenter: parent.verticalCenter
            onClicked: panel.openAt("gear", this)
        }
        PanelButton {
            id: clockButton
            property date now: new Date()
            Timer {
                interval: 10000
                running: panel.visible
                repeat: true
                triggeredOnStart: true
                onTriggered: clockButton.now = new Date()
            }
            text: now.toLocaleDateString(Qt.locale(), "ddd, d MMM").replace(/^./, day => day.toLocaleUpperCase()) + " · " + now.toLocaleTimeString(Qt.locale(), "HH:mm")
            font: Qt.font({
                family: Theme.Fonts.BodySB.family,
                pixelSize: Math.min(Config.clockSize, 13),
                bold: Config.clockBold
            })
            description: qsTr("Calendar")
            anchors.verticalCenter: parent.verticalCenter
            onClicked: panel.openAt("clock", this)
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
        x: panel.systemRect.x + panel.systemContentInset
        y: panel.systemRect.y + panel.systemContentInset
        width: Math.max(1, panel.systemWidth - 2 * panel.systemContentInset)
        height: panel.integratedSystemEnabled
            ? Math.max(0, Math.min(panel.systemHeight, panel.systemRect.height) - 2 * panel.systemContentInset)
            : Math.max(0, panel.systemRect.height - 2 * panel.systemContentInset)
        contentWidth: width
        contentHeight: panel.activeSystemViewHeight
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
        OskaSearchResults {
            id: searchResults
            width: systemContent.width
            height: implicitHeight
            y: 0
            query: searchField.text
            iconLeftInset: searchField.x - panel.lobePad - listMargin
            textLeftInset: searchField.x + 36 - panel.lobePad - listMargin
            textRightInset: searchField.x + searchField.width - panel.lobePad - listMargin
            visible: panel.oskaSearchSurfaceActive
            onActivated: {
                searchField.text = "";
                searchField.forceActiveFocus();
            }
        }
        Item {
            id: oskaNotificationBanner
            x: 0
            y: searchResults.y + searchResults.height + 8
            width: systemContent.width
            height: panel.oskaNotificationHeight
            visible: panel.oskaNotificationVisible
            Rectangle {
                anchors.fill: parent
                radius: 20
                color: Theme.Palette.Background.Default.Secondary
                border.width: 1
                border.color: Theme.Palette.Outline.Default.SolidPrimary
            }
            Row {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 10
                Rectangle {
                    width: 40
                    height: 40
                    radius: width / 2
                    color: Theme.Palette.Background.Default.Tertiary
                    anchors.verticalCenter: parent.verticalCenter
                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        source: panel.oskaNotification ? panel.oskaNotification.applicationIcon || panel.oskaNotification.icon : "preferences-desktop-notification"
                        roundToIconSize: false
                    }
                }
                Column {
                    width: parent.width - 40 - 18 - 20
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        width: parent.width
                        text: panel.oskaNotification ? panel.oskaNotification.summary : ""
                        color: Theme.Palette.Text.Default.Primary
                        font: Theme.Fonts.BodyM
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                Kirigami.Icon {
                    width: 20
                    height: 20
                    anchors.verticalCenter: parent.verticalCenter
                    source: panel.oskaNotification ? panel.oskaNotification.icon : "preferences-desktop-notification"
                    isMask: true
                    color: Theme.Palette.Text.Default.Primary
                    roundToIconSize: false
                    visible: panel.oskaNotification && panel.oskaNotification.applicationIcon !== "" && panel.oskaNotification.icon !== "" && panel.oskaNotification.icon !== panel.oskaNotification.applicationIcon
                }
            }
        }
        NotificationCards {
            id: cards
            width: systemContent.width
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
                    osd.showProgress(icon, fraction * 100, 100, "");
                }
            }
        }
        Loader {
            id: historyLoader
            active: panel.warm
            visible: panel.openLobe === "notif"
            width: systemContent.width
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
    // Passive OSD is drawn by Sirca when it owns org.kde.osdService without plasmashell.
    Rectangle {
        id: osd
        property string symbol: ""
        property real fraction: 0
        property string message: ""
        property bool progressVisible: true
        function showProgress(icon, value, maximum, additionalText) {
            symbol = icon;
            fraction = maximum > 0 ? Math.max(0, Math.min(1, value / maximum)) : 0;
            message = additionalText || "";
            progressVisible = true;
            hideOsd.restart();
        }
        function showText(icon, text) {
            symbol = icon;
            message = text;
            progressVisible = false;
            hideOsd.restart();
        }
        visible: hideOsd.running
        z: 1000
        x: (panel.width - width) / 2
        y: panel.barRect.y - height - 12
        width: 320
        height: 76
        radius: Theme.Sizes.BorderRadius.L
        color: Theme.Palette.Background.Default.Secondary
        border.width: 1
        border.color: Theme.Palette.Outline.Default.SolidSecondary
        opacity: visible ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 140 }
        }
        Timer {
            id: hideOsd
            interval: 1800
        }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 16
            Kirigami.Icon {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                source: osd.symbol
                isMask: true
                color: Theme.Palette.Text.Default.Primary
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                RowLayout {
                    Layout.fillWidth: true
                    Sber.Label {
                        Layout.fillWidth: true
                        visible: osd.message !== ""
                        text: osd.message
                        elide: Text.ElideRight
                        color: Theme.Palette.Text.Default.Primary
                        font: Theme.Fonts.BodySB
                    }
                    Sber.Label {
                        Layout.alignment: Qt.AlignRight
                        visible: osd.progressVisible
                        text: Math.round(osd.fraction * 100) + "%"
                        color: Theme.Palette.Text.Default.Primary
                        font: Theme.Fonts.BodySB
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 6
                    visible: osd.progressVisible
                    radius: height / 2
                    color: Theme.Palette.Background.Default.Primary
                    Rectangle {
                        width: parent.width * osd.fraction
                        height: parent.height
                        radius: parent.radius
                        color: Theme.Palette.Surface.Default.Accent
                        Behavior on width { NumberAnimation { duration: 120 } }
                    }
                }
            }
        }
        Connections {
            target: Shell
            function onDbusSignal(iface, member, args) {
                if (iface !== "org.kde.osdService")
                    return;
                if (member === "osdProgress" && args.length >= 3)
                    osd.showProgress(String(args[0]), Number(args[1]), Number(args[2]), args.length >= 4 ? String(args[3]) : "");
                else if (member === "osdText" && args.length >= 2)
                    osd.showText(String(args[0]), String(args[1]));
            }
        }
    }
}
