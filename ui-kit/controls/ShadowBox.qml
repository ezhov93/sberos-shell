import QtQuick
import QtQuick.Effects

import Sber.Controls
import Sber.Core
import Sber.Theme

MultiEffect {
    anchors.fill: source

    autoPaddingEnabled: true
    shadowVerticalOffset: 16
    shadowEnabled: true
    shadowColor: Core.Settings.IsDarkTheme ? Theme.Palette.Background.Default.Basic : Theme.Palette.Background.Dark.Secondary
    blurMultiplier: 1
    blurMax: 40
    shadowOpacity: 0.24
}
