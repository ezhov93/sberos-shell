/* SPDX-License-Identifier: GPL-3.0-or-later */
import QtQuick
import ".."
import QtQuick.Controls.Basic
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support
Button {
    id: button
    property bool mini: false
    property bool noMargins: true
    property string title: ""
    visible: root.showScreenshot
    Accessible.name: qsTr("Сделать снимок экрана")
    onClicked: executable.connectSource("spectacle")
    background: Rectangle {
        radius: 16
        color: button.down ? root.smartTheme.pressed : button.hovered ? root.smartTheme.hover : "transparent"
        border.width: button.visualFocus ? 2 : 0
        border.color: root.smartTheme.focus
    }
    contentItem: Item {
        SmartPanelIcon {
            anchors.centerIn: parent
            width: 24 * root.scale
            height: width
            source: Qt.resolvedUrl("../../assets/smart-panel/capture.svg")
            isMask: true
            color: root.smartTheme.foreground
        }
    }
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => disconnectSource(sourceName)
    }
}
