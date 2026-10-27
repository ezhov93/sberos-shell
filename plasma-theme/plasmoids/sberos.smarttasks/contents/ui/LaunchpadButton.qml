/* SPDX-License-Identifier: GPL-2.0-or-later */
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic
import org.kde.kirigami as Kirigami

Button {
    id: button
    property bool launcherOpen: false
    property int iconSize: 32
    readonly property SmartPanelTheme smartTheme: SmartPanelTheme {}
    text: qsTr("Все приложения")
    Accessible.name: text
    padding: 0
    background: Rectangle {
        anchors.centerIn: parent
        width: Math.min(button.width, button.height)
        height: width
        radius: 10
        color: button.down ? button.smartTheme.pressed
            : button.hovered || button.visualFocus || button.launcherOpen ? button.smartTheme.hover : "transparent"
        border.width: button.visualFocus ? 2 : 0
        border.color: button.smartTheme.focus
    }
    contentItem: Item {
        implicitWidth: button.iconSize
        implicitHeight: button.iconSize
        Kirigami.Icon {
            anchors.centerIn: parent
            width: button.iconSize
            height: width
            source: Qt.resolvedUrl("../assets/launchpad.svg")
            roundToIconSize: false
        }
    }
    Keys.onReturnPressed: clicked()
    Keys.onEnterPressed: clicked()
}
