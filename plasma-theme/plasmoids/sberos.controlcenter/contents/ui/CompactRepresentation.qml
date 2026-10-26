/* SPDX-License-Identifier: GPL-3.0-or-later */
import QtQuick
import QtQuick.Controls.Basic
import org.kde.kirigami as Kirigami

Button {
    id: button
    Accessible.name: qsTr("Быстрые настройки")
    padding: 0
    onClicked: root.expanded = !root.expanded
    background: Item {
        Rectangle {
            anchors.fill: parent
            anchors.margins: button.height * 8 / 72
            anchors.rightMargin: 0
            radius: 10
            color: button.down ? root.smartTheme.pressed : button.hovered || root.expanded ? root.smartTheme.hover : "transparent"
            border.width: button.visualFocus ? 2 : 0
            border.color: root.smartTheme.focus
        }
    }
    contentItem: Item {
        SmartPanelIcon {
            anchors.centerIn: parent
            width: button.height / 3
            height: width
            source: Qt.resolvedUrl("../assets/smart-panel/controls.svg")
            isMask: true
            color: root.smartTheme.foreground
        }
    }
}
