import QtQuick
import QtQuick.Effects
import qs.desktop.modules.bar
import qs.desktop.modules.common
import qs.desktop.modules.dock
import "../../../../shared/qml/i18n"

ControlCenterCard {
    id: root
    required property string title
    required property string iconName

    enabled: false
    opacity: 0.72
    Accessible.role: Accessible.Button
    Accessible.name: root.title + ", " + I18n.tr("Unavailable")
    Accessible.description: I18n.tr("This system feature is not available yet")

    Rectangle {
        x: 12
        width: 32
        height: 32
        radius: 16
        anchors.verticalCenter: parent.verticalCenter
        color: AppearanceTokens.colors.surfaceContainerHigh
    }
    Image {
        anchors {
            left: parent.left
            leftMargin: 19
            verticalCenter: parent.verticalCenter
        }
        width: 18
        height: 18
        source: BundledIcons.source(root.iconName)
        sourceSize.width: 48
        sourceSize.height: 48
        fillMode: Image.PreserveAspectFit
        smooth: true
        opacity: 0.55
        layer.enabled: true
        layer.effect: MultiEffect {
            colorization: 1.0
            colorizationColor: ThemeService.foregroundColor
        }
    }
    Column {
        anchors {
            left: parent.left
            leftMargin: 56
            right: parent.right
            rightMargin: 8
            verticalCenter: parent.verticalCenter
        }
        spacing: 1
        ThemeText {
            width: parent.width
            text: root.title
            elide: Text.ElideRight
            color: AppearanceTokens.colors.surfaceForeground
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }
        ThemeText {
            width: parent.width
            text: I18n.tr("Unavailable")
            elide: Text.ElideRight
            color: AppearanceTokens.colors.surfaceVariantForeground
            font.pixelSize: 11
        }
    }
}
