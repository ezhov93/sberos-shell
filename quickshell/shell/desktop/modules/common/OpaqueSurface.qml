import QtQuick

Rectangle {
    id: surface

    property color foregroundColor: AppearanceTokens.colors.surfaceForeground
    property color secondaryForegroundColor: AppearanceTokens.colors.surfaceVariantForeground
    property color tertiaryForegroundColor: Qt.rgba(AppearanceTokens.colors.surfaceVariantForeground.r, AppearanceTokens.colors.surfaceVariantForeground.g, AppearanceTokens.colors.surfaceVariantForeground.b, 0.70)
    property real contentRadius: Math.max(0, radius - 4)

    color: AppearanceTokens.surface.panelFill
    border.width: 1
    border.color: AppearanceTokens.surface.outline
}
