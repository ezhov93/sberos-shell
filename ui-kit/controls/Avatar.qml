import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T
import QtQuick.Effects

import Sber.Controls
import Sber.Core
import Sber.Theme


T.Control {
    id: control

    property int lineHeight: Core.Settings.LineHeight
    property alias source: image.source
    property int size: lineHeight
    property bool inGroup: false
    property int status: Widget.None

    implicitWidth: size
    width: size
    implicitHeight: size
    height: size

    hoverEnabled: true

    Rectangle {
        id: container
        anchors.centerIn: parent
        width: control.width + (control.inGroup ? border.width * 2 : 0)
        height: control.height + (control.inGroup ? border.width * 2 : 0)
        radius: width / 2
        color: "transparent"
        border.width: control.inGroup ? control.lineHeight / 10 : 0
        border.color: Theme.Palette.Background.Default.Primary
        z: 0
    }

    MultiEffect {
        id: avatar
        anchors.fill: parent
        z: 1

        source: Image {
            id: image
            fillMode: Image.PreserveAspectCrop
        }

        maskEnabled: true
        maskSource: ShaderEffectSource {
            width: avatar.width
            height: avatar.height
            sourceItem: mask
            layer.enabled: true
        }

        Rectangle {
            id: mask
            anchors.fill: parent
            radius: Math.min(width, height)
            layer.enabled: true
            visible: false
        }
    }

    Rectangle {
        id: indicator
        anchors.bottom: avatar.bottom
        anchors.right: avatar.right
        width: 12
        height: 12
        radius: width
        visible: control.status != Widget.None
        z: 2

        color: control.status === Widget.Online ? Theme.Palette.Surface.Default.Positive :
               control.status === Widget.Afk    ? Theme.Palette.Surface.Default.Warning :
                                                  Theme.Palette.Surface.Default.Negative
        border.color: Theme.Palette.Background.Default.Primary
        border.width: 2
    }
}
