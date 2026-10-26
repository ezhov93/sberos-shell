import QtQuick

import Sber.Controls
import Sber.Theme

Rectangle {
    id: control

    property alias lineHeight: backgroundConfig.lineHeight
    property alias type: backgroundConfig.type
    property alias status: backgroundConfig.status

    implicitWidth: lineHeight <= Theme.Sizes.LineHeight.S ? 8 : lineHeight <= Theme.Sizes.LineHeight.M ? 10 : 14
    width: implicitWidth
    implicitHeight: implicitWidth
    height: implicitHeight
    radius: height / 2
    color: backgroundConfig.defaultColor

    property BackgroundConfig backgroundConfig: BackgroundConfig {
        id: backgroundConfig
    }
}
