import QtQuick
import Sber.Controls as Sber
import Sber.Theme

Item {
    id: root
    required property var colors
    required property string symbol
    required property color tint
    property bool highlighted: false
    property int size: 29
    width: size
    height: size
    Sber.Icon {
        anchors.centerIn: parent
        size: parent.size
        name: ({
                "◈": "SettingsOutline",
                "◇": "SettingsOutline",
                "▧": "AppsOutline",
                "⎍": "PanelSidebarLOutline",
                "▰": "PanelSidebarROutline",
                "▭": "PanelSidebarROutline",
                "▣": "WindowOutline",
                "▦": "AppsOutline",
                "❖": "AppsFill",
                "⌘": "KeyboardOutline",
                "✓": "DoneCircleFill",
                "⚙": "SettingsOutline",
                "♲": "RepeatOutline",
                "↔": "ArrowsMoveHoriz",
                "◉": "CircleFill",
                "◌": "CircleOutline",
                "●": "CircleFill",
                "◐": "Contrast0Outline",
                "◔": "Contrast1Outline",
                "◒": "Contrast2Outline",
                "≈": "Waves",
                "≋": "Waves",
                "⧉": "CopyOutline",
                "⌂": "HomeAltOutline",
                "⌕": "Search",
                "⇲": "WindowMaximize",
                "↺": "RepeatOutline",
                "B": "Text",
                "▢": "SquareOutline",
                "◧": "Contrast2Outline",
                "↓": "ArrowDown",
                "×": "Close"
            })[parent.symbol] || "SettingsOutline"
        color: parent.highlighted ? Theme.Palette.Surface.Default.Accent : Theme.Palette.Text.Default.Secondary
    }
}
