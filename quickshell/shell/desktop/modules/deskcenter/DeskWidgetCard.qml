import QtQuick
import qs.desktop.modules.common

// Desktop widget card with an opaque theme surface and optional flower shape.
Item {
    id: root

    property string title: ""
    property bool flowerShapedSurface: false
    property bool showSurface: true
    property color surfaceColor: AppearanceTokens.surface.widgetFill
    readonly property real radius: AppearanceTokens.widget.radius

    clip: true

    WidgetSurface {
        anchors.fill: parent
        visible: root.showSurface
        radius: root.radius
        fillColor: root.surfaceColor
        flowerShaped: root.flowerShapedSurface
    }

    Text {
        visible: root.title.length > 0
        text: root.title
        color: AppearanceTokens.surface.widgetForeground

        anchors {
            left: parent.left
            top: parent.top
            leftMargin: 18
            topMargin: 15
        }

        font {
            pixelSize: 12
            weight: Font.DemiBold
        }
    }
}
