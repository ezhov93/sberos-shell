pragma Singleton
import QtQuick
import "../../../Kos/Ui"
import Sber.Core
import Sber.Theme

// Shared shape, colour and motion values for the supported SberOS appearance.
QtObject {
    id: tokens

    readonly property int version: 9

    readonly property SystemPalette systemPalette: SystemPalette {
        colorGroup: SystemPalette.Active
    }
    readonly property bool systemIsDark: systemPalette.window.r * 0.2126 + systemPalette.window.g * 0.7152 + systemPalette.window.b * 0.0722 < 0.5
    // Explicit light/dark choices must override KDE; only "system" follows
    // SystemPalette.
    readonly property bool resolvedAppearanceIsDark: AppearanceConfigService.themeMode === "dark" ? true : AppearanceConfigService.themeMode === "light" ? false : systemIsDark
    readonly property bool isDarkTheme: resolvedAppearanceIsDark

    // ────────────────────────────────────────────────────────────────
    // Wallpaper colour bridge
    // ────────────────────────────────────────────────────────────────
    // `WallpaperColorSource` lives in the shared Kos.Ui layer, which must not
    // import `qs.desktop.modules.*`. Feed it the resolved light/dark branch.
    //
    // The bridge is a direct child of this singleton so that instantiating
    // AppearanceTokens is enough to create it — a nested QtObject without a
    // consumer could otherwise be elided, leaving the sampler unwired.
    readonly property Connections _wallpaperRequest: Connections {
        target: tokens
        function onIsDarkThemeChanged() {
            WallpaperColorSource.darkMode = tokens.isDarkTheme;
        }
    }

    // The Shell owns the appearance choice. Drive the shared UI Kit theme from
    // the resolved Shell mode rather than its independent QSettings value.
    function _syncUiKitThemeMode() {
        Core.Settings.setThemeMode(tokens.isDarkTheme ? Settings.Dark : Settings.Light);
    }

    readonly property Connections _uiKitThemeModeSync: Connections {
        target: tokens
        function onIsDarkThemeChanged() {
            tokens._syncUiKitThemeMode();
            tokens._uiKitThemeRevision += 1;
        }
    }

    property int _uiKitThemeRevision: 0

    // Set the shared palette before the first shell surface is drawn.
    Component.onCompleted: {
        _syncUiKitThemeMode();
        WallpaperColorSource.darkMode = tokens.isDarkTheme;
    }

    function _mix(base, tint, amount, alpha) {
        return Qt.rgba(base.r + (tint.r - base.r) * amount, base.g + (tint.g - base.g) * amount, base.b + (tint.b - base.b) * amount, alpha === undefined ? 1.0 : alpha);
    }

    // Canvas consumers read palette colours only while painting.
    readonly property int colorRevision: _uiKitThemeRevision
    readonly property QtObject colors: QtObject {
        readonly property color primary: Theme.Palette.Surface.Default.Accent
        readonly property color primaryForeground: Theme.Palette.Text.OnDark.Primary
        readonly property color primaryContainer: Theme.Palette.Background.Default.Secondary
        readonly property color primaryContainerForeground: Theme.Palette.Text.Default.Primary
        readonly property color secondary: Theme.Palette.Surface.Default.SolidPrimary
        readonly property color secondaryForeground: Theme.Palette.Text.Default.Primary
        readonly property color secondaryContainer: Theme.Palette.Background.Default.Tertiary
        readonly property color secondaryContainerForeground: Theme.Palette.Text.Default.Primary
        readonly property color tertiary: Theme.Palette.Surface.Default.SolidSecondary
        readonly property color tertiaryContainer: Theme.Palette.Background.Default.Quaternary
        readonly property color tertiaryContainerForeground: Theme.Palette.Text.Default.Primary
        readonly property color background: Theme.Palette.Background.Default.Primary
        readonly property color surface: Theme.Palette.Background.Default.Basic
        readonly property color surfaceContainerLow: Theme.Palette.Background.Default.Secondary
        readonly property color surfaceContainer: Theme.Palette.Background.Default.Tertiary
        readonly property color surfaceContainerHigh: Theme.Palette.Background.Default.Quaternary
        readonly property color surfaceContainerHighest: Theme.Palette.Background.Default.Basic
        readonly property color layer0: Theme.Palette.Background.Default.Primary
        readonly property color layer1: Theme.Palette.Background.Default.Secondary
        readonly property color layer2: Theme.Palette.Background.Default.Tertiary
        readonly property color layer3: Theme.Palette.Background.Default.Quaternary
        readonly property color layer4: Theme.Palette.Background.Default.Basic
        readonly property bool surfaceIsDark: tokens.isDarkTheme
        readonly property color surfaceForeground: tokens.isDarkTheme ? Theme.Palette.Text.OnDark.Primary : Theme.Palette.Text.OnLight.Primary
        readonly property color surfaceVariantForeground: tokens.isDarkTheme ? Theme.Palette.Text.OnDark.Secondary : Theme.Palette.Text.OnLight.Secondary
        readonly property color outline: Theme.Palette.Outline.Default.SolidPrimary
        readonly property color outlineVariant: Theme.Palette.Outline.Default.SolidSecondary
        readonly property color error: Theme.Palette.Surface.Default.Negative
        readonly property color scrim: Theme.Palette.Overlay.Default.Soft
    }

    readonly property QtObject shape: QtObject {
        // Matches the practical scale used by end4-pC: 6/8/12/17/23/30.
        readonly property real unsharpened: 5
        readonly property real extraSmall: 5
        readonly property real small: 10
        readonly property real medium: 14
        readonly property real large: 20
        readonly property real extraLarge: 26
        readonly property real full: 999
        // Shared corner profile for shell surfaces that use SquircleMask.
        // This controls geometry only; every surface remains an opaque QML fill.
        readonly property real cornerExponent: 3.0
    }

    // Shell surfaces use opaque fills from the UI Kit palette.
    readonly property QtObject surface: QtObject {
        readonly property color panelFill: tokens.colors.layer1
        readonly property color barFill: tokens.colors.layer1
        readonly property color widgetFill: tokens.colors.layer1
        readonly property color widgetForeground: tokens.colors.surfaceVariantForeground
        readonly property color outline: tokens.colors.outlineVariant
    }

    // ────────────────────────────────────────────────────────────────
    // Widget content colours
    // ────────────────────────────────────────────────────────────────
    readonly property QtObject content: QtObject {
        readonly property bool onBackdrop: false

        function shellInk(alpha) {
            return IconAppearanceService.contentColor(alpha);
        }

        // Ink over the backdrop, or the caller's own colour when the card is its
        // own artwork. `alpha` is optional and applies only to the ink.
        function ink(ownColor, alpha) {
            if (!onBackdrop)
                return ownColor;
            return alpha === undefined ? IconAppearanceService.contentColor() : IconAppearanceService.contentColor(alpha);
        }

        function accent(themeColor, ownColor, alpha) {
            return ink(ownColor, alpha);
        }
    }

    readonly property QtObject state: QtObject {
        readonly property color hover: tokens._mix(tokens.colors.layer2, tokens.colors.surfaceForeground, 0.08)
        readonly property color pressed: tokens._mix(tokens.colors.layer2, tokens.colors.surfaceForeground, 0.12)
        readonly property color selected: tokens.colors.primaryContainer
        readonly property color disabled: Qt.rgba(tokens.colors.surfaceVariantForeground.r, tokens.colors.surfaceVariantForeground.g, tokens.colors.surfaceVariantForeground.b, 0.38)
    }

    readonly property QtObject typography: QtObject {
        readonly property string recommendedDisplayFamily: "SF Pro Display"
        readonly property bool hasRecommendedDisplayFamily: Qt.fontFamilies().indexOf(recommendedDisplayFamily) >= 0
        // An empty family delegates fallback to the user's Qt/KDE font setup.
        readonly property string displayFamily: hasRecommendedDisplayFamily ? recommendedDisplayFamily : ""
    }

    readonly property QtObject dock: QtObject {
        readonly property string form: "floatingDock"
        readonly property string position: "bottom"
        // Pill radius as a fraction of the Dock's height, so the cap keeps its
        // shape as the Dock grows. 0.5 is the ceiling that still means
        // something -- the cap becomes a half circle -- and both glass
        // styles are pinned to it; Windows 12 stays a taskbar, where a
        // full-round cap would be out of place.
        readonly property real radiusRatio: 0.50
        readonly property real horizontalPaddingRatio: 0.40
        readonly property real verticalPaddingRatio: 0.20
        readonly property real itemSpacingRatio: 0.09
        readonly property real dividerMarginRatio: 0.20
        readonly property int edgeMargin: 5
        // Match the float between the glass and the screen edge with an equal
        // visual breathing space between the glass and windows. DockWindow
        // applies this only while the Dock is permanently visible, so hidden
        // modes do not create an invisible spatial dead strip.
        readonly property int workspaceGap: edgeMargin
        readonly property string indicatorStyle: "dot"
        readonly property real indicatorLengthRatio: 0.13
        readonly property real indicatorThicknessRatio: 0.13
        readonly property real activeRadiusRatio: 0.30
        readonly property bool magnificationEnabled: true
        readonly property real hoverScale: 1.20
        readonly property real hoverLiftRatio: 0.08
        // The pointer influence is intentionally wider than one icon. Each
        // icon scales visually inside a fixed slot, so magnification never
        // changes the Dock's measured width.
        readonly property real magnificationRadius: 140
        readonly property real magnificationMaxScale: 1.19
        readonly property real magnificationLiftRatio: 0.04
    }

    readonly property QtObject bar: QtObject {
        // Bar keeps one visual language across shell styles. Integration is a
        // user choice, not an implicit Windows-theme side effect.
        readonly property string placement: "top"
        readonly property int height: 35
        readonly property int radius: 0
        readonly property string surfaceMode: "solid"
        readonly property bool unifiedWithDock: AppearanceConfigService.barIntegratedWithDock
    }

    readonly property QtObject widget: QtObject {
        readonly property int radius: tokens.shape.large
        readonly property int gap: 10
        readonly property int elevation: 1
        readonly property string surfaceMode: "solid"
        readonly property color surfaceColor: tokens.colors.surfaceContainer
        readonly property color elevatedSurfaceColor: tokens.colors.surfaceContainerHigh
    }

    readonly property QtObject motion: QtObject {
        readonly property int fastDuration: 135
        readonly property int normalDuration: 200
        readonly property int slowDuration: 360
        readonly property int standardEasing: Easing.OutCubic
        readonly property bool springEnabled: true
        readonly property bool popupAnimatesOnShow: true
        // Whether the shell draws the extra faces a form brings with it -- the
        // Dock clock's dial, for instance. Same reason as above.
        readonly property bool drawsFormDecorations: true
        // Anchored popups share Launchpad's entrance rhythm: a short cubic
        // settle from 0.96 scale with a directional fade/translation.
        readonly property int popupOpenDuration: 150
        readonly property int popupCloseDuration: 140
        readonly property real popupStartScale: 0.96
        readonly property real popupAnchorOffset: 20
    }
}
