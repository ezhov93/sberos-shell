/*
    SPDX-FileCopyrightText: 2026 SberOS Shell contributors
    SPDX-License-Identifier: GPL-2.0-or-later
*/
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid
import org.kde.plasma.private.sessions

PlasmoidItem {
    id: root
    readonly property SmartPanelTheme smartTheme: SmartPanelTheme {}
    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property real panelExtent: Math.max(1, vertical ? width : height)
    property bool powerMenuOpen: false
    property int selectedAction: -1
    readonly property var menuActions: [
        {action: "settings", icon: "settings", label: qsTr("Настройки")},
        {action: "terminal", icon: "terminal", label: qsTr("Терминал")},
        {action: "power", icon: "power", label: qsTr("Питание и сеанс")},
        {action: "collapse", icon: "down", label: qsTr("Свернуть меню")}
    ]
    readonly property var powerActions: [
        {action: "logout", label: qsTr("Завершить сеанс"), shortcut: "", enabled: sessionManagement.canLogout},
        {action: "reboot", label: qsTr("Перезагрузить"), shortcut: "", enabled: sessionManagement.canReboot},
        {action: "shutdown", label: qsTr("Выключить"), shortcut: "Ctrl+Alt+Delete", enabled: sessionManagement.canShutdown},
        {action: "lock", label: qsTr("Заблокировать экран"), shortcut: "Win+L", enabled: sessionManagement.canLock},
        {action: "suspend", label: qsTr("Спящий режим"), shortcut: "", enabled: sessionManagement.canSuspend}
    ]

    preferredRepresentation: compactRepresentation
    Plasmoid.title: qsTr("Меню Сбера")
    Plasmoid.icon: Qt.resolvedUrl("../assets/smart-panel/sber.svg")
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    Layout.minimumWidth: vertical ? 0 : panelExtent
    Layout.maximumWidth: vertical ? Infinity : panelExtent
    Layout.preferredWidth: vertical ? 72 : panelExtent
    Layout.minimumHeight: vertical ? panelExtent : 0
    Layout.maximumHeight: vertical ? panelExtent : Infinity
    Layout.preferredHeight: vertical ? panelExtent : 72

    onExpandedChanged: {
        powerMenuOpen = false;
        selectedAction = -1;
    }

    function activateMenu(action) {
        if (action === "power") {
            powerMenuOpen = !powerMenuOpen;
        } else if (action === "collapse") {
            if (powerMenuOpen) powerMenuOpen = false;
            else root.expanded = false;
        } else {
            root.expanded = false;
            executableSource.connectSource(action === "settings" ? "kstart systemsettings" : "kstart konsole");
        }
    }

    function activatePower(action) {
        root.expanded = false;
        switch (action) {
        case "logout": sessionManagement.requestLogout(SessionManagement.Default); break;
        case "reboot": sessionManagement.requestReboot(SessionManagement.Default); break;
        case "shutdown": sessionManagement.requestShutdown(SessionManagement.Default); break;
        case "lock": sessionManagement.lock(); break;
        case "suspend": sessionManagement.suspend(); break;
        }
    }

    SessionManagement { id: sessionManagement }
    Plasma5Support.DataSource {
        id: executableSource
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => disconnectSource(sourceName)
    }

    compactRepresentation: Button {
        id: compactButton
        implicitWidth: 72
        implicitHeight: 72
        padding: 0
        Accessible.name: qsTr("Меню Сбера")
        onClicked: root.expanded = !root.expanded
        background: Rectangle {
            anchors.fill: parent
            anchors.margins: root.panelExtent * 8 / 72
            radius: height * 16 / 56
            color: compactButton.down ? root.smartTheme.pressed : compactButton.hovered || root.expanded ? root.smartTheme.hover : root.smartTheme.inner
            border.width: compactButton.visualFocus ? 2 : 0
            border.color: root.smartTheme.focus
        }
        contentItem: Item {
            SmartPanelIcon {
                anchors.centerIn: parent
                width: root.panelExtent / 3
                height: width
                source: Qt.resolvedUrl("../assets/smart-panel/sber.svg")
                isMask: true
                color: root.smartTheme.foreground
            }
        }
    }

    fullRepresentation: FocusScope {
        id: popup
        SmartPopupPlacement {
            content: popup
            anchorItem: root.compactRepresentationItem ?? root
            screenGeometry: Plasmoid.containment.screenGeometry
            alignment: "left"
            overlapPanel: true
            frameSource: Qt.resolvedUrl(root.powerMenuOpen
                ? "../assets/smart-panel/power-popup-frame.svg"
                : "../assets/smart-panel/popup-frame.svg")
            frameBorders: root.powerMenuOpen ? KSvg.FrameSvg.NoBorder : KSvg.FrameSvg.AllBorders
        }
        implicitWidth: root.powerMenuOpen ? 352 : 72
        implicitHeight: root.powerMenuOpen ? 264 : 216
        Layout.minimumWidth: implicitWidth
        Layout.maximumWidth: implicitWidth
        Layout.preferredWidth: implicitWidth
        Layout.minimumHeight: implicitHeight
        Layout.maximumHeight: implicitHeight
        Layout.preferredHeight: implicitHeight
        focus: true

        Keys.onEscapePressed: event => {
            if (root.powerMenuOpen) {
                root.powerMenuOpen = false;
                if (root.selectedAction === 2) menuRepeater.itemAt(2).forceActiveFocus();
            } else root.expanded = false;
            event.accepted = true;
        }
        function moveSelection(backward) {
            root.selectedAction = root.selectedAction < 0 ? (backward ? 3 : 0)
                : (root.selectedAction + (backward ? 3 : 1)) % 4;
            menuRepeater.itemAt(root.selectedAction).forceActiveFocus();
        }
        function movePowerSelection(index, backward) {
            for (let offset = 1; offset <= 5; offset++) {
                const next = (index + (backward ? -offset : offset) + 10) % 5;
                const button = powerRepeater.itemAt(next);
                if (button?.enabled) { button.forceActiveFocus(); return; }
            }
        }
        Keys.onTabPressed: event => { moveSelection(false); event.accepted = true; }
        Keys.onBacktabPressed: event => { moveSelection(true); event.accepted = true; }
        Keys.onDownPressed: event => { moveSelection(false); event.accepted = true; }
        Keys.onUpPressed: event => { moveSelection(true); event.accepted = true; }

        Rectangle {
            width: 72
            height: 216
            anchors.bottom: parent.bottom
            radius: 24
            color: root.smartTheme.shell
            border.width: 1
            border.color: root.smartTheme.edge
            Rectangle {
                anchors.fill: parent
                anchors.margins: 8
                radius: 16
                color: root.smartTheme.inner
            }
            Column {
                anchors.centerIn: parent
                Repeater {
                    id: menuRepeater
                    model: root.menuActions
                    delegate: Button {
                        id: actionButton
                        required property var modelData
                        required property int index
                        width: 46
                        height: 48
                        padding: 0
                        activeFocusOnTab: true
                        Accessible.name: modelData.label
                        onClicked: {
                            root.activateMenu(modelData.action);
                            if (modelData.action === "power" && root.powerMenuOpen && visualFocus) {
                                root.selectedAction = index;
                                popup.movePowerSelection(-1, false);
                            }
                        }
                        background: Rectangle {
                            radius: 11
                            color: actionButton.down ? root.smartTheme.pressed : actionButton.hovered || actionButton.visualFocus || (actionButton.modelData.action === "power" && root.powerMenuOpen) ? root.smartTheme.hover : "transparent"
                            border.width: actionButton.visualFocus ? 2 : 0
                            border.color: root.smartTheme.focus
                        }
                        contentItem: Item {
                            SmartPanelIcon {
                                anchors.centerIn: parent
                                width: 24
                                height: 24
                                source: Qt.resolvedUrl("../assets/smart-panel/" + actionButton.modelData.icon + ".svg")
                                isMask: true
                                color: root.smartTheme.foreground
                            }
                        }
                        PlasmaCore.ToolTipArea {
                            anchors.fill: parent
                            mainText: actionButton.modelData.label
                        }
                    }
                }
            }
        }
        Rectangle {
            id: powerSurface
            visible: root.powerMenuOpen
            x: 80
            y: popup.height - height - 80
            width: 272
            height: 184
            radius: 16
            color: root.smartTheme.inner
            Column {
                anchors.fill: parent
                anchors.topMargin: 8
                Repeater {
                    id: powerRepeater
                    model: root.powerActions
                    delegate: Button {
                        id: powerButton
                        required property var modelData
                        required property int index
                        width: 272
                        height: index === 3 ? 37 : 32
                        topPadding: index === 3 ? 5 : 0
                        leftPadding: 16
                        rightPadding: 16
                        bottomPadding: 0
                        enabled: modelData.enabled
                        Accessible.name: modelData.label
                        onClicked: root.activatePower(modelData.action)
                        Keys.onDownPressed: popup.movePowerSelection(index, false)
                        Keys.onUpPressed: popup.movePowerSelection(index, true)
                        Keys.onTabPressed: popup.movePowerSelection(index, false)
                        Keys.onBacktabPressed: popup.movePowerSelection(index, true)
                        background: Rectangle {
                            color: powerButton.down ? root.smartTheme.pressed : powerButton.hovered || powerButton.visualFocus ? root.smartTheme.hover : "transparent"
                            border.width: powerButton.visualFocus ? 2 : 0
                            border.color: root.smartTheme.focus
                            Rectangle {
                                visible: powerButton.index === 3
                                x: 16
                                width: 240
                                height: 1
                                color: root.smartTheme.separator
                            }
                        }
                        contentItem: RowLayout {
                            spacing: 8
                            Text {
                                Layout.fillWidth: true
                                text: powerButton.modelData.label
                                color: root.smartTheme.foreground
                                opacity: powerButton.enabled ? 1 : .45
                                font.pixelSize: 14
                                font.weight: Font.Medium
                            }
                            Text {
                                text: powerButton.modelData.shortcut
                                color: root.smartTheme.muted
                                font.pixelSize: 12
                            }
                        }
                    }
                }
            }
        }
    }
}
