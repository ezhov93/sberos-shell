import QtQuick
import Kos.SurfaceShape 1.0

// Material used by the Smart Panel mock: translucent tint over compositor blur.
// The fallback keeps the surface legible when the KWin shape protocol is absent.
Item {
    id: root

    property real radius: 24
    property real cornerExponent: 2
    property real blurSigma: 22
    readonly property bool dark: AppearanceTokens.isDarkTheme
    readonly property color tintColor: dark ? "#2d3e3a" : "#f7f9fb"
    readonly property color outlineColor: Qt.rgba(1, 1, 1, dark ? 0.22 : 0.52)
    readonly property real tintOpacity: dark ? 0.85 : 0.72

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: glass.active ? "transparent" : Qt.rgba(root.tintColor.r, root.tintColor.g, root.tintColor.b, root.tintOpacity)
        border.width: 1
        border.color: root.outlineColor
    }

    SurfaceShape {
        id: glass
        target: root
        radius: root.radius
        exponent: root.cornerExponent
        effectType: SurfaceShape.Frosted
        material: SurfaceShape.Regular
        blurSigma: root.blurSigma
        tintMode: SurfaceShape.Fixed
        tintColor: root.tintColor
        tintOpacity: root.tintOpacity
        scrimEnabled: false
    }
}
