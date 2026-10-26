pragma ComponentBehavior: Bound

/*
    SPDX-FileCopyrightText: 2026 SberOS Shell contributors
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

FocusScope {
    id: root

    property var appModel
    signal activated(int index)
    signal dismissed

    implicitWidth: 600
    implicitHeight: 424
    focus: true

    Keys.onEscapePressed: event => {
        root.dismissed()
        event.accepted = true
    }

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: Kirigami.Theme.backgroundColor
        border.width: 1
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.14)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            Text {
                Layout.fillWidth: true
                text: qsTr("Приложения")
                color: Kirigami.Theme.textColor
                font.pixelSize: 20
                font.weight: Font.DemiBold
            }

            GridView {
                id: appGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                cellWidth: 88
                cellHeight: 88
                clip: true
                model: root.appModel
                keyNavigationEnabled: true
                focus: true
                delegate: Item {
                    id: appDelegate
                    required property int index
                    required property var model
                    width: appGrid.cellWidth
                    height: appGrid.cellHeight
                    focus: true
                    Accessible.role: Accessible.Button
                    Accessible.name: String(model.display || "")

                    Keys.onReturnPressed: root.activated(appDelegate.index)
                    Keys.onSpacePressed: event => {
                        root.activated(appDelegate.index)
                        event.accepted = true
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 3
                        radius: 12
                        color: appMouse.containsMouse || appMouse.pressed
                               ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.09)
                               : "transparent"

                        Column {
                            anchors.fill: parent
                            anchors.margins: 5
                            spacing: 6

                            Kirigami.Icon {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 36
                                height: 36
                                source: appDelegate.model.decoration
                            }

                            Text {
                                width: parent.width
                                height: 30
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignTop
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                maximumLineCount: 2
                                color: Kirigami.Theme.textColor
                                font.pixelSize: 11
                                text: appDelegate.model.display
                            }
                        }

                        MouseArea {
                            id: appMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.activated(appDelegate.index)
                        }
                    }
                }
            }
        }
    }
}
