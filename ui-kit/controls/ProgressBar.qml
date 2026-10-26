import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Core
import Sber.Theme

T.ProgressBar {
    id: control

    from: 0
    to: 100
    value: 0

    property bool circular: false
    property bool warning: false
    property bool error: false
    property int indicatorWidth: circular ? lineHeight <= Theme.Sizes.LineHeight.S ? 2 : lineHeight <= Theme.Sizes.LineHeight.M ? 3 : lineHeight <= Theme.Sizes.LineHeight.L ? 4 : 4 : 4
    property color color: Theme.Palette.Surface.Default.Accent
    spacing: 8

    property alias lineHeight: circularIndicator.lineHeight
    implicitWidth: circular ? internal.smallIndicator ? lineHeight : text.x + text.width : spacing + text.width
    implicitHeight: lineHeight
    height: implicitHeight

    QtObject {
        id: internal
        property color color: control.error ? Theme.Palette.Surface.Default.Negative : control.warning ? Theme.Palette.Surface.Default.Warning : control.color
        property bool smallIndicator: control.circular && control.lineHeight < Theme.Sizes.LineHeight.M
        property bool bigIndicator: control.circular && control.lineHeight > Theme.Sizes.LineHeight.L
        property real loadingPercent: (control.value - control.from) / (control.to - control.from)
    }

    Rectangle {
        id: linearIndicator
        anchors.left: parent.left
        anchors.right: text.left
        anchors.rightMargin: control.spacing
        anchors.verticalCenter: parent.verticalCenter
        visible: !control.circular
        height: control.indicatorWidth
        radius: control.indicatorWidth / 2
        color: Theme.Palette.Surface.Default.SolidSecondary

        Rectangle {
            id: linearProgress
            x: 0
            y: (linearIndicator.height - linearProgress.height) / 2
            width: linearIndicator.width * internal.loadingPercent
            height: control.indicatorWidth
            radius: control.indicatorWidth / 2
            color: internal.color

            Behavior on width {
                PropertyAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuint
                }
            }
        }
    }

    BusyIndicator {
        id: circularIndicator
        x: 0
        y: 0
        lineHeight: Core.Settings.LineHeight
        color: internal.color
        indicatorWidth: control.indicatorWidth
        loadingPercent: internal.loadingPercent * 100
        visible: control.circular
    }
    Label {
        id: text
        x: circular ? (circularIndicator.width - text.width) / 2 : control.width - text.width
        anchors.verticalCenter: circular ? circularIndicator.verticalCenter : control.verticalCenter
        lineHeight: control.lineHeight
        text: control.value.toLocaleString(control.locale, 'f', 0) + '%'
    }
}
