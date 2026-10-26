pragma ComponentBehavior: Bound

/*
    SPDX-FileCopyrightText: 2026 SberOS Shell contributors
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore

Item {
    id: root

    readonly property SmartPanelTheme smartTheme: SmartPanelTheme {}
    property int cellSize: 48
    property int iconSize: 32
    property string label
    property var iconSource
    property int runningCount: 0
    property bool active: false
    property bool separatorBefore: false

    signal activated
    signal newInstanceRequested
    signal contextRequested
    signal previewHoverEntered
    signal previewHoverExited

    implicitWidth: cellSize + (separatorBefore ? 8 : 0)
    implicitHeight: cellSize
    Accessible.role: Accessible.Button
    Accessible.name: label
    activeFocusOnTab: true

    Accessible.onPressAction: root.activated()
    Keys.onMenuPressed: root.contextRequested()
    Keys.onReturnPressed: root.activated()
    Keys.onSpacePressed: event => {
        root.activated()
        event.accepted = true
    }

    Rectangle {
        visible: root.separatorBefore
        x: 3
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: root.cellSize * 2 / 3
        color: smartTheme.separator
    }

    Rectangle {
        x: root.separatorBefore ? 8 : 0
        y: 0
        width: root.cellSize
        height: root.cellSize
        radius: 10
        color: mouse.pressed ? smartTheme.pressed : mouse.containsMouse || root.activeFocus ? smartTheme.hover : "transparent"
        border.width: root.activeFocus ? 2 : 0
        border.color: smartTheme.focus

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
                    color: smartTheme.foreground
                    opacity: root.active ? 1 : 0.72
                }
            }
        }

        PlasmaCore.ToolTipArea {
            anchors.fill: parent
            visible: root.runningCount === 0
            mainText: root.label
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onEntered: root.previewHoverEntered()
            onExited: root.previewHoverExited()
            onClicked: mouse => {
                if (mouse.button === Qt.MiddleButton) {
                    root.newInstanceRequested()
                } else if (mouse.button === Qt.RightButton) {
                    root.contextRequested()
                } else {
                    root.activated()
                }
            }
            onPressAndHold: root.contextRequested()
        }
    }
}
