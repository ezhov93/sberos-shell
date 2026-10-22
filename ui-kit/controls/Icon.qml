import QtQuick
import QtQuick.Controls

import Sber.Controls
import Sber.Core
import Sber.Theme


Item {
    id: control
    property int lineHeight: Core.Settings.LineHeight
    property int size: lineHeight < Theme.Sizes.LineHeight.S ? 14 : 20

    property string name
    property string source
    property string imageProvider: "Default"
    property color color: Theme.Palette.Text.Default.Primary

    visible: source != "" || name != ""
    width: visible ? control.size : 0
    height: visible ? control.size : 0

    Image {
        id: image
        anchors.fill: parent
        source: control.name   != "" ? `image://${control.imageProvider}/${control.name}/${control.color}` :
                control.source != "" ? control.source : ""

        sourceSize.width: width
        sourceSize.height: height
    }
}
