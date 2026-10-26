import QtQuick

import Sber.Controls
import Sber.Core
import Sber.Theme

Rectangle {
    id: chip

    property alias text: label.text
    property string idx: ""
    property alias icon: label.icon
    property alias closable: closeIcon.visible
    property bool circle: false

    property int lineHeight: Core.Settings.LineHeight
    property int spacing: lineHeight <= Theme.Sizes.LineHeight.Xs ? 4 : 6
    property alias type: backgroundConfig.type

    signal closed(string idx)

    implicitWidth: chip.horizontalPadding + label.implicitWidth + (closable ? closeIcon.width + (height - closeIcon.height) / 2 + spacing : chip.horizontalPadding)
    implicitHeight: lineHeight <= Theme.Sizes.LineHeight.Xs ? Theme.Sizes.LineHeight.Xxs : lineHeight <= Theme.Sizes.LineHeight.S ? Theme.Sizes.LineHeight.Xs : lineHeight <= Theme.Sizes.LineHeight.M ? Theme.Sizes.LineHeight.S : Theme.Sizes.LineHeight.M
    width: implicitWidth
    height: implicitHeight

    property int horizontalPadding: lineHeight <= Theme.Sizes.LineHeight.Xs ? 8 : lineHeight <= Theme.Sizes.LineHeight.S ? 10 : lineHeight <= Theme.Sizes.LineHeight.M ? 12 : 14
    color: colorizer.currentColor
    radius: circle ? height / 2 : backgroundConfig.radius - 2

    property BackgroundConfig backgroundConfig: BackgroundConfig {
        id: backgroundConfig
        lineHeight: chip.lineHeight
        type: Widget.Default
    }
    property Colorizer colorizer: Colorizer {
        id: colorizer
        defaultColor: backgroundConfig.defaultColor
        hovered: chip.enabled && closeArea.containsMouse
        hoverColor: backgroundConfig.hoverColor
        activated: closeArea.pressed
        activeColor: backgroundConfig.activeColor
    }

    IconLabel {
        id: label
        x: chip.horizontalPadding
        anchors.verticalCenter: chip.verticalCenter
        lineHeight: chip.lineHeight
        type: backgroundConfig.type
        spacing: chip.spacing
        icon.size: lineHeight <= Theme.Sizes.LineHeight.Xs ? 12 : lineHeight <= Theme.Sizes.LineHeight.S ? 16 : 24
    }

    MouseArea {
        id: closeArea
        x: closeIcon.x - chip.spacing / 2
        y: 0
        width: chip.width - x
        height: chip.height
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
        onClicked: chip.closed(chip.idx)
        z: 1000
        visible: closeIcon.visible
    }

    Icon {
        id: closeIcon
        x: chip.width - (chip.height - height) / 2 - width
        y: (chip.height - height) / 2
        name: "Close"
        color: label.color
        size: chip.lineHeight <= Theme.Sizes.LineHeight.Xs ? 12 : chip.lineHeight <= Theme.Sizes.LineHeight.S ? 16 : 24
    }
}
