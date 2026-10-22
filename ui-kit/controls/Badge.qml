import QtQuick

import Sber.Controls
import Sber.Theme


Rectangle {
    id: control

    property alias text: label.text
    property alias icon: label.icon
    property alias lineHeight: label.lineHeight
    property alias type: label.type
    property alias backgroundType: label.backgroundType
    property alias status: label.status
    property bool circle: false

    radius: circle ? height / 2 :
            lineHeight <= Theme.Sizes.LineHeight.Xs ? 4 :
            lineHeight <= Theme.Sizes.LineHeight.S  ? 6 :
            lineHeight <= Theme.Sizes.LineHeight.M  ? 6 :
                                                      8
    color: backgroundConfig.backgroundType == Widget.Solid ? backgroundConfig.defaultColor : "transparent"
    border.width: backgroundConfig.backgroundType == Widget.Outline ? 1.5 : 0
    border.color: backgroundConfig.defaultColor
    opacity: enabled ? 1 : 0.4

    property int horizontalPadding: (text != "" ? 3 : 0) +
                                    (lineHeight <= Theme.Sizes.LineHeight.Xs ? 1 :
                                    lineHeight <= Theme.Sizes.LineHeight.S   ? 4 :
                                    lineHeight <= Theme.Sizes.LineHeight.M   ? 6 :
                                                                               8)
    implicitHeight: lineHeight <= Theme.Sizes.LineHeight.Xs ? 16 :
                    lineHeight <= Theme.Sizes.LineHeight.S  ? 20 :
                    lineHeight <= Theme.Sizes.LineHeight.M  ? 24 :
                                                              28
    height: implicitHeight
    implicitWidth: text != "" ? label.width + horizontalPadding * 2 : height
    width: implicitWidth


    property BackgroundConfig backgroundConfig: BackgroundConfig {
        id: backgroundConfig
        type: control.type
        backgroundType: control.backgroundType
        status: control.status
    }

    IconLabel {
        id: label
        anchors.centerIn: parent
        spacing: lineHeight <= Theme.Sizes.LineHeight.S  ? 2 :
                 lineHeight <= Theme.Sizes.LineHeight.M  ? 3 :
                                                           4
        icon.size: lineHeight <= Theme.Sizes.LineHeight.Xs ? 10 :
                   lineHeight <= Theme.Sizes.LineHeight.S  ? 12 :
                   lineHeight <= Theme.Sizes.LineHeight.M  ? 12 :
                                                             14
        smaller: true
        type: Widget.Default
    }
}
