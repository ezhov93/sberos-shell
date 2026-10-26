import QtQuick
import qs.desktop.modules.common
import qs.desktop.modules.dock
import "../../../shared/qml/controls" as Controls

// One visual language for every slider inside Control Center.
Controls.ThemeSlider {
    id: root
    height: 30

    trackColor: AppearanceTokens.colors.surfaceContainerHighest
    accentColor: AppearanceTokens.colors.primary
}
