pragma Singleton
import QtQuick
import qs.desktop.modules.common

// ────────────────────────────────────────────────────────────────
// DockThemeService — Dark / light colour palette.
// Switches reactively with the shell-wide appearance mode.
// Every visual component binds to these colours; no hardcoded values.
// ────────────────────────────────────────────────────────────────

QtObject {
    id: svc

    // AppearanceTokens owns the global system/light/dark resolution so Dock
    // and every Material surface always select the same palette branch.
    property bool isDark: AppearanceTokens.isDarkTheme

    // ═══════════════════════════════════════════════════
    // Dark palette
    // ═══════════════════════════════════════════════════
    // Liquid Glass keeps a neutral, theme-stable body behind its adaptive
    // reflections.  The material may borrow colour from the wallpaper, but
    // it must not borrow so much luminance that label contrast collapses.
    readonly property color darkBg: Qt.rgba(0, 0, 0, 0.10)
    readonly property color darkFg: Qt.rgba(0.985, 0.990, 1.000, 1.0)
    readonly property color darkSecondaryFg: Qt.rgba(0.985, 0.990, 1.000, 0.82)
    readonly property color darkTertiaryFg: Qt.rgba(0.985, 0.990, 1.000, 0.62)
    readonly property color darkAccent: Qt.rgba(0.20, 0.60, 1.0, 1.0)
    readonly property color darkDivider: Qt.rgba(1.0, 1.0, 1.0, 0.18)
    readonly property color darkTooltipBg: Qt.rgba(0.18, 0.18, 0.20, 0.95)
    readonly property color darkIndicator: Qt.rgba(0.985, 0.990, 1.000, 0.90)
    readonly property color darkBorder: Qt.rgba(1.0, 1.0, 1.0, 0.16)
    readonly property color darkHighlight: Qt.rgba(1.0, 1.0, 1.0, 0.28)

    // ═══════════════════════════════════════════════════
    // Light palette
    // ═══════════════════════════════════════════════════
    readonly property color lightBg: Qt.rgba(0.95, 0.95, 0.97, 0.35)
    readonly property color lightFg: Qt.rgba(0.055, 0.065, 0.085, 1.0)
    readonly property color lightSecondaryFg: Qt.rgba(0.055, 0.065, 0.085, 0.72)
    readonly property color lightTertiaryFg: Qt.rgba(0.055, 0.065, 0.085, 0.62)
    readonly property color lightAccent: Qt.rgba(0.0, 0.50, 0.90, 1.0)
    readonly property color lightDivider: Qt.rgba(0.055, 0.065, 0.085, 0.16)
    readonly property color lightTooltipBg: Qt.rgba(0.92, 0.92, 0.94, 0.95)
    readonly property color lightIndicator: Qt.rgba(0.055, 0.065, 0.085, 0.85)
    readonly property color lightBorder: Qt.rgba(0.055, 0.065, 0.085, 0.14)
    readonly property color lightHighlight: Qt.rgba(1.0, 1.0, 1.0, 0.55)

    // ═══════════════════════════════════════════════════
    // Exposed (reactively toggled)
    // ═══════════════════════════════════════════════════
    readonly property color backgroundColor: AppearanceTokens.colors.layer0
    // Glass foreground follows the resolved appearance: clean dark ink on a
    // light surface, and light ink on a dark surface. This role is shared by
    // launcher labels, symbolic tray icons, Dock glyphs and status content.
    readonly property color foregroundColor: AppearanceTokens.colors.surfaceForeground
    readonly property color barInk: foregroundColor
    readonly property color secondaryForegroundColor: AppearanceTokens.colors.surfaceVariantForeground
    readonly property color tertiaryForegroundColor: Qt.rgba(AppearanceTokens.colors.surfaceVariantForeground.r, AppearanceTokens.colors.surfaceVariantForeground.g, AppearanceTokens.colors.surfaceVariantForeground.b, 0.70)
    readonly property color accentColor: AppearanceTokens.colors.primary
    readonly property color dividerColor: AppearanceTokens.colors.outline
    readonly property color tooltipBackground: AppearanceTokens.colors.layer3
    // Material keeps the running dot on the high-contrast on-surface ink so it
    // never falls back to a seed-driven primary that may not reach AA contrast
    // against the tonal dock layer. Glass branches use the indicator inks above.
    readonly property color indicatorColor: AppearanceTokens.colors.surfaceForeground
    readonly property color borderColor: AppearanceTokens.colors.outline
    // ── Control-centre tiles ─────────────────────────────────────────────
    // A tile is a container, not a glass card: in the tonal form it takes the
    // scheme's container fills and the ink that reads on them. Each role keeps
    // exactly the literal the tiles were drawn with as its glass value while
    // the tile is dark, so the default glass form stays byte-identical and only
    // the tonal form (or a light glass) changes.
    readonly property color tileGlyph: AppearanceTokens.colors.surfaceVariantForeground
    readonly property color tileActiveGlyph: AppearanceTokens.colors.primaryContainerForeground
    // The fill `tileActiveGlyph` is cut for: an enabled toggle reads as a
    // primaryContainer tile carrying its own on-container ink, not as the
    // accent with a borrowed foreground.
    readonly property color tileActiveFill: AppearanceTokens.colors.primaryContainer
    readonly property color tileAccent: AppearanceTokens.colors.primary
    readonly property color tileDanger: AppearanceTokens.colors.error
    readonly property color highlightColor: Qt.rgba(AppearanceTokens.colors.primary.r, AppearanceTokens.colors.primary.g, AppearanceTokens.colors.primary.b, 0.22)
}
