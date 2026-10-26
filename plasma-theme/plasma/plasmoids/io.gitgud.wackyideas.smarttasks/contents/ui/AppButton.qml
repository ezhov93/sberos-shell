pragma ComponentBehavior: Bound

/*
    SPDX-FileCopyrightText: 2026 SberOS Shell contributors
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: root

    property int cellSize: 48
    property int iconSize: 32
    property string label
    property var iconSource
    property int runningCount: 0
    property bool active: false
    property bool separatorBefore: false

    signal activated
    signal contextRequested

    implicitWidth: cellSize + (separatorBefore ? 8 : 0)
    implicitHeight: cellSize
    Accessible.role: Accessible.Button
    Accessible.name: label
    activeFocusOnTab: true

    Keys.onReturnPressed: root.activated()
    Keys.onSpacePressed: event => {
        root.activated()
        event.accepted = true
    }

    Rectangle {
        x: root.separatorBefore ? 8 : 0
        y: 0
        width: root.cellSize
        height: root.cellSize
        radius: 10
        color: mouse.containsMouse || root.activeFocus
               ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.10)
               : "transparent"

        Kirigami.Icon {
            anchors.centerIn: parent
            width: root.iconSize
            height: root.iconSize
            source: root.iconSource
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 1
            spacing: 3
            Repeater {
                model: Math.min(4, root.runningCount)
                delegate: Rectangle {
                    required property int index
                    width: 4
                    height: 4
                    radius: 2
                    color: root.active ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                    opacity: root.active ? 1 : 0.72
                }
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    root.contextRequested()
                } else {
                    root.activated()
                }
            }
            onPressAndHold: root.contextRequested()
        }
    }
}
