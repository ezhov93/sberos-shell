/* SPDX-License-Identifier: GPL-3.0-or-later */
import QtQuick
import ".."
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.battery
import org.kde.plasma.private.batterymonitor
Button {
    id: button
    property bool noMargins: true
    readonly property bool profileAvailable: profiles.profiles.length > 0
    readonly property string activeProfileLabel: !profileAvailable ? qsTr("Недоступно")
        : profiles.activeProfile === "power-saver" ? qsTr("Энергосбережение")
        : profiles.activeProfile === "performance" ? qsTr("Производительность") : qsTr("Сбалансированный")
    BatteryControlModel { id: battery }
    PowerProfilesControl { id: profiles }
    visible: battery.hasBatteries && root.showBattery
    Accessible.name: qsTr("Батарея: %1%").arg(battery.percent)
    onClicked: fullRep.togglePage(344 * root.scale, 400 * root.scale, batteryPage)
    background: Rectangle {
        radius: 16
        color: button.down ? root.smartTheme.pressed : button.hovered ? root.smartTheme.hover : "transparent"
        border.width: button.visualFocus ? 2 : 0
        border.color: root.smartTheme.focus
    }
    contentItem: RowLayout {
        spacing: 8 * root.scale
        SmartPanelIcon {
            Layout.preferredWidth: 24 * root.scale
            Layout.preferredHeight: 24 * root.scale
            source: Qt.resolvedUrl("../../assets/smart-panel/battery.svg")
            isMask: true
            color: root.smartTheme.foreground
        }
        Text {
            text: qsTr("%1%").arg(battery.percent)
            color: root.smartTheme.foreground
            font.pixelSize: 16 * root.scale
        }
    }
}
