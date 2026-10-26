/*
    SPDX-FileCopyrightText: 2026 SberOS Shell contributors
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid
import org.kde.plasma.private.sessions

PlasmoidItem {
    id: root

    preferredRepresentation: compactRepresentation
    Plasmoid.title: i18n("Меню Сбера")
    Plasmoid.icon: "start-here-kde"
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    Layout.minimumWidth: 88
    Layout.maximumWidth: 88
    Layout.preferredWidth: 88
    Layout.minimumHeight: 64
    Layout.maximumHeight: 64
    Layout.preferredHeight: 64

    readonly property int menuWidth: 72
    readonly property int menuHeight: 216
    readonly property int powerWidth: 272
    readonly property int powerHeight: 184
    property bool powerMenuOpen: false

    function toggleMenu() {
        root.expanded = !root.expanded;
    }

    function closeMenu() {
        root.expanded = false;
        powerMenuOpen = false;
    }

    onExpandedChanged: () => {
        if (!root.expanded) {
            powerMenuOpen = false;
        }
    }

    function activatePowerAction(action) {
        closeMenu();
        switch (action) {
        case "logout": sessionManagement.requestLogout(SessionManagement.Default); break;
        case "reboot": sessionManagement.requestReboot(SessionManagement.Default); break;
        case "shutdown": sessionManagement.requestShutdown(SessionManagement.Default); break;
        case "lock": sessionManagement.lock(); break;
        case "suspend": sessionManagement.suspend(); break;
        }
    }

    SessionManagement {
        id: sessionManagement
    }

    Plasma5Support.DataSource {
        id: executableSource
        engine: "executable"
        connectedSources: []

        onNewData: (sourceName, data) => disconnectSource(sourceName)

        function run(command) {
            connectSource(command);
        }
    }

    compactRepresentation: Item {
        implicitWidth: 88
        implicitHeight: 64

        Rectangle {
            x: 16
            y: 4
            width: 56
            height: 56
            radius: 20
            color: Kirigami.Theme.backgroundColor
            opacity: 0.92

            Kirigami.Icon {
                anchors.centerIn: parent
                width: 24
                height: 24
                // Copied from the Smart Panel mock asset; source hashes are in its manifest.
                source: Qt.resolvedUrl("sber.svg")
                color: Kirigami.Theme.textColor
            }
        }

        MouseArea {
            x: 16
            y: 4
            width: 56
            height: 56
            acceptedButtons: Qt.LeftButton
            Accessible.name: i18n("Меню Сбера")
            Accessible.role: Accessible.Button
            onClicked: root.toggleMenu()
        }
    }

    fullRepresentation: FocusScope {
        id: popupContent
        readonly property int contentWidth: root.powerMenuOpen ? root.menuWidth + 8 + root.powerWidth : root.menuWidth
        readonly property int contentHeight: root.powerMenuOpen
                                              ? Math.max(root.menuHeight, root.powerHeight + 80)
                                              : root.menuHeight

        width: contentWidth
        height: contentHeight
        implicitWidth: contentWidth
        implicitHeight: contentHeight
        Layout.minimumWidth: contentWidth
        Layout.maximumWidth: contentWidth
        Layout.preferredWidth: contentWidth
        Layout.minimumHeight: contentHeight
        Layout.maximumHeight: contentHeight
        Layout.preferredHeight: contentHeight

        Keys.onEscapePressed: event => {
            if (root.powerMenuOpen) {
                root.powerMenuOpen = false;
            } else {
                root.closeMenu();
            }
            event.accepted = true;
        }

            Rectangle {
                id: menuSurface
                x: 0
                y: popupContent.contentHeight - root.menuHeight
                width: root.menuWidth
                height: root.menuHeight
                radius: 24
                color: Kirigami.Theme.backgroundColor
                opacity: 0.72
                border.width: 1
                border.color: Qt.rgba(Kirigami.Theme.textColor.r,
                                      Kirigami.Theme.textColor.g,
                                      Kirigami.Theme.textColor.b,
                                      0.22)

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 8
                    radius: 16
                    color: Kirigami.Theme.backgroundColor
                    opacity: 0.92
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 0

                    Repeater {
                        model: [
                            { "action": "settings", "icon": "configure", "label": i18n("Настройки оболочки") },
                            { "action": "terminal", "icon": "utilities-terminal", "label": i18n("Терминал") },
                            { "action": "power", "icon": "system-shutdown", "label": i18n("Питание и сеанс") },
                            { "action": "collapse", "icon": "arrow-down", "label": i18n("Свернуть меню") }
                        ]

                        delegate: Item {
                            required property var modelData
                            width: 46
                            height: 48
                            property bool hovered: false

                            Rectangle {
                                anchors.fill: parent
                                radius: 11
                                color: parent.hovered ? Kirigami.Theme.hoverColor : "transparent"
                            }

                            Kirigami.Icon {
                                anchors.centerIn: parent
                                width: 24
                                height: 24
                                source: modelData.icon
                                color: Kirigami.Theme.textColor
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton
                                onEntered: parent.hovered = true
                                onExited: parent.hovered = false
                                onClicked: {
                                    if (modelData.action === "power") {
                                        root.powerMenuOpen = !root.powerMenuOpen;
                                    } else if (modelData.action === "collapse") {
                                        if (root.powerMenuOpen) {
                                            root.powerMenuOpen = false;
                                        } else {
                                            root.closeMenu();
                                        }
                                    } else {
                                        root.closeMenu();
                                        executableSource.run(modelData.action === "settings"
                                                             ? "kstart systemsettings"
                                                             : "kstart konsole");
                                    }
                                }
                            }

                            Accessible.name: modelData.label
                            Accessible.role: Accessible.Button
                        }
                    }
                }
            }

            Rectangle {
                id: powerSurface
                readonly property int xOffset: root.menuWidth + 8
                visible: root.powerMenuOpen
                x: xOffset
                y: popupContent.contentHeight - root.powerHeight - 80
                width: root.powerWidth
                height: root.powerHeight
                radius: 16
                color: Kirigami.Theme.backgroundColor
                opacity: 0.92
                border.width: 1
                border.color: Qt.rgba(Kirigami.Theme.textColor.r,
                                      Kirigami.Theme.textColor.g,
                                      Kirigami.Theme.textColor.b,
                                      0.16)

                Column {
                    anchors.fill: parent
                    anchors.topMargin: 8
                    anchors.bottomMargin: 8
                    spacing: 0

                    Repeater {
                        model: [
                            { "action": "logout", "label": i18n("Завершить сеанс"), "shortcut": "", "enabled": sessionManagement.canLogout },
                            { "action": "reboot", "label": i18n("Перезагрузить"), "shortcut": "", "enabled": sessionManagement.canReboot },
                            { "action": "shutdown", "label": i18n("Выключить"), "shortcut": "Ctrl+Alt+Delete", "enabled": sessionManagement.canShutdown },
                            { "action": "lock", "label": i18n("Заблокировать экран"), "shortcut": "Win+L", "enabled": sessionManagement.canLock },
                            { "action": "suspend", "label": i18n("Спящий режим"), "shortcut": "", "enabled": sessionManagement.canSuspend }
                        ]

                        delegate: Item {
                            required property int index
                            required property var modelData
                            width: root.powerWidth
                            height: index === 3 ? 37 : 32

                            Rectangle {
                                visible: parent.index === 3
                                x: 16
                                y: 0
                                width: parent.width - 32
                                height: 1
                                color: Qt.rgba(Kirigami.Theme.textColor.r,
                                               Kirigami.Theme.textColor.g,
                                               Kirigami.Theme.textColor.b,
                                               0.16)
                            }

                            Rectangle {
                                x: 4
                                y: index === 3 ? 5 : 0
                                width: parent.width - 8
                                height: 32
                                radius: 8
                                color: actionMouseArea.containsMouse ? Kirigami.Theme.hoverColor : "transparent"
                                opacity: modelData.enabled ? 1 : 0.45

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 8

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.label
                                        color: Kirigami.Theme.textColor
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: modelData.shortcut
                                        color: Kirigami.Theme.disabledTextColor
                                        font.pixelSize: 12
                                        visible: text.length > 0
                                    }
                                }

                                MouseArea {
                                    id: actionMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: modelData.enabled
                                    onClicked: root.activatePowerAction(modelData.action)
                                }
                            }

                            Accessible.name: modelData.label
                            Accessible.role: Accessible.Button
                        }
                    }
                }
            }
    }

}
