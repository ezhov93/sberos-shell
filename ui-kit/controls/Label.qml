import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Theme

T.Label {
    id: label

    verticalAlignment: Text.AlignVCenter
    width: implicitWidth
    height: implicitHeight

    property alias type: textConfig.type
    property alias backgroundType: textConfig.backgroundType
    property alias lineHeight: textConfig.lineHeight
    property alias bold: textConfig.bold
    property alias secondary: textConfig.secondary
    property alias smaller: textConfig.smaller
    property alias status: textConfig.status
    font: textConfig.font
    color: textConfig.defaultColor

    property QtObject textConfig: TextConfig {
        id: textConfig
    }
}
