import QtQuick
import Quickshell
import qs.desktop.modules.common
import qs.desktop.modules.dock
import "../../../Kos/Ui"

// Opaque control-center card container for the single-block panel.
Item {
    id: root
    default property alias content: cardContent.data

    // ── Grid position & size (top-right origin, matching the old coordinator) ──
    property int offsetTop: 0
    property int offsetRight: 0
    property int cardWidth: 296
    property int cardHeight: 59
    property real cardRadius: AppearanceTokens.shape.large
    property real cardOpacity: 1.0
    property real cardScale: 1.0
    property real contentOpacity: 1.0
    property real contentOffsetY: 0
    // Sub-page morph geometry. During a page transition the host animates a
    // card between its full rectangle and the source control it grew from
    // (the Wi-Fi pill, the brightness slider, ...). `morphRect` is the card's
    // current visible window in CARD coordinates: it starts at the full card
    // and shrinks toward the source. The surface follows it,
    // while `cardContent` keeps its natural size and is clipped, so the card
    // reads as collapsing into the capsule instead of squashing its content.
    // A zero/empty rect means "no morph" and behaves exactly like before.
    property rect morphRect: Qt.rect(0, 0, -1, -1)
    readonly property rect _morph: morphRect.width > 0 && morphRect.height > 0 ? morphRect : Qt.rect(0, 0, root.width, root.height)
    property bool managedByCoordinator: true

    // Marker for the single-block panel's positioning pass.
    readonly property bool isControlCenterCard: true
    // Host shows/hides a card (submenus and the session sheet toggle this).
    property bool cardShown: true
    property bool surfaceVisible: true
    // Which navigation page this card belongs to. The panel multiplies the
    // card's opacity by that page's crossfade factor, so a card fades with
    // its page -- surface and content together. "" is the primary page.
    property string pageTag: ""
    clip: _morph.width < width || _morph.height < height || _morph.x !== 0 || _morph.y !== 0

    // Content uses the foreground roles from the UI Kit surface.
    readonly property color surfaceForegroundColor: cardSurface.foregroundColor
    readonly property color surfaceSecondaryForegroundColor: cardSurface.secondaryForegroundColor
    readonly property color surfaceTertiaryForegroundColor: cardSurface.tertiaryForegroundColor

    width: cardWidth
    height: cardHeight
    visible: root.cardShown

    OpaqueSurface {
        id: cardSurface
        anchors.fill: parent
        visible: root.surfaceVisible
        radius: Math.max(1, Math.min(Math.round(root.cardRadius), Math.floor(Math.min(root.cardWidth, root.cardHeight) / 2)))
    }

    // Content is a sibling of the optional surface: cards that omit a backing
    // still need to render their controls and labels.
    Item {
        id: cardContent
        anchors.fill: parent
        visible: root.cardOpacity > 0.001
        scale: root.cardScale
        opacity: root.contentOpacity
        transform: Translate {
            y: root.contentOffsetY
        }
    }
}
