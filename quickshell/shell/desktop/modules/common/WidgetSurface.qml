import QtQuick

Item {
    id: surface

    property real radius: AppearanceTokens.widget.radius
    property color fillColor: AppearanceTokens.surface.widgetFill
    property bool flowerShaped: false

    Rectangle {
        anchors.fill: parent
        radius: surface.radius
        visible: !surface.flowerShaped
        color: surface.fillColor
    }

    MaterialFlower {
        anchors.centerIn: parent
        width: Math.max(0, Math.min(parent.width, parent.height) - 18)
        height: width
        visible: surface.flowerShaped
        lobes: 12
        amplitude: 0.075
        fillColor: surface.fillColor
        outlineWidth: 0
    }
}
