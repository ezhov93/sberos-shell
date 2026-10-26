import QtQuick

import Sber.Controls
import Sber.Core
import Sber.Theme

MouseArea {
    id: control

    property alias title: titleLabel.text
    property alias text: textLabel.text
    property alias icon: icon

    property int index: 0
    property bool checked: false
    property int lineHeight: Core.Settings.LineHeight
    property var rightStep

    implicitWidth: Math.max(indicator.width, titleLabel.width + titleLabel.anchors.leftMargin, textLabel.width + textLabel.anchors.leftMargin)
    width: implicitWidth
    implicitHeight: textLabel.y + textLabel.height
    height: implicitHeight

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    opacity: enabled ? 1 : 0.4

    Item {
        id: indicator
        width: lineHeight >= Theme.Sizes.LineHeight.M ? 36 : 24
        height: width

        property bool isCurrent: control.parent.currentIndex == control.index
        property color bgColor: isCurrent ? "transparent" : control.checked ? Theme.Palette.Surface.Default.SolidPrimary : Theme.Palette.Surface.Default.TransparentSecondary
        property color textColor: isCurrent ? Theme.Palette.Text.Default.Primary : control.checked ? Theme.Palette.Text.Inverse.Primary : Theme.Palette.Text.Default.Secondary

        Rectangle {
            id: background
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            width: !control.parent.bullet ? indicator.isCurrent ? indicator.width : 24 : indicator.isCurrent ? 16 : 8
            height: width
            color: indicator.bgColor
            radius: width / 2
            border.width: control.parent.bullet || indicator.isCurrent ? 2 : 0
            border.color: control.checked ? Theme.Palette.Surface.Default.SolidPrimary : Theme.Palette.Surface.Default.TransparentSecondary
        }
        Rectangle {
            id: line
            anchors.verticalCenter: background.verticalCenter
            anchors.left: background.right
            width: control.rightStep ? control.rightStep.x - control.x - background.width : 0
            height: 2
            visible: control.parent.linesVisible
            color: control.checked && control.rightStep && control.rightStep.checked ? Theme.Palette.Surface.Default.SolidPrimary : Theme.Palette.Surface.Default.TransparentSecondary
        }

        Label {
            id: indexLabel
            anchors.centerIn: background
            lineHeight: control.lineHeight
            text: control.index
            color: indicator.textColor

            visible: !icon.visible && !control.parent.bullet
        }
        Icon {
            id: icon
            anchors.centerIn: background
            size: background.width - 10
            visible: (name != "" || source != "") && !control.parent.bullet
            color: indicator.textColor
        }
    }

    Label {
        id: titleLabel
        anchors.left: parent.left
        anchors.top: indicator.bottom
        anchors.topMargin: control.lineHeight <= Theme.Sizes.LineHeight.Xs ? 6 : control.lineHeight <= Theme.Sizes.LineHeight.S ? 8 : control.lineHeight <= Theme.Sizes.LineHeight.M ? 10 : 12
        lineHeight: control.lineHeight
        bold: true
        color: control.parent.clickable && control.containsMouse ? Theme.Palette.Text.Default.Secondary : Theme.Palette.Text.Default.Primary
        height: text != "" ? implicitHeight : 0
    }
    Label {
        id: textLabel
        anchors.left: parent.left
        anchors.top: titleLabel.bottom
        anchors.topMargin: control.lineHeight <= Theme.Sizes.LineHeight.Xs ? 4 : 6
        lineHeight: control.lineHeight
        secondary: true
        height: text != "" ? implicitHeight : 0
    }

    onReleased: {
        if (control.parent.clickable)
            control.parent.currentIndex = control.index;
    }

    Connections {
        target: control.parent
        function onCurrentIndexChanged() {
            updateChecked();
        }
    }
    Component.onCompleted: updateChecked()
    function updateChecked() {
        if (indicator.isCurrent) {
            control.checked = true;
        }
    }
}
