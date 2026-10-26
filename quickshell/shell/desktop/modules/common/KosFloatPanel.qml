import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.desktop.modules.common
import "../../../Kos/Ui"

// Reusable important-interaction surface. One layer-shell surface carries both
// the optional backdrop dim and the opaque card.
Scope {
    id: root

    default property alias content: cardHost.data
    property real contentPadding: 20
    property var targetScreen: ScreenLifecycle.activeScreen
    property bool modal: false
    property bool backdropEnabled: false
    readonly property bool backdropVisible: root.modal && root.backdropEnabled
    property real backdropOpacity: -1
    // A wash exists to push the desktop back, so it is dark in both appearances
    // rather than polarized against the final glass tone.
    property color backdropTint: "black"
    // An explicit backdropOpacity wins; otherwise the wash is lighter where the
    // screen it covers is already dark.
    readonly property real backdropEffectiveOpacity: root.backdropOpacity >= 0 ? Math.min(1, root.backdropOpacity) : (AppearanceTokens.resolvedAppearanceIsDark ? 0.38 : 0.48)
    property bool dismissOnBackdrop: true
    // Important dialogs are a fixed-content, fixed-size family, so their corner
    // is a literal rather than a shape token: it holds still if the token scale
    // moves, and it is deliberately rounder than shape.extraLarge (26/30).
    property real radius: 32
    property real cornerExponent: AppearanceTokens.shape.cornerExponent
    // Outer shadow. It is cast entirely outside the card's outline (see
    // KosCardShadow): a translucent card cannot carry a shadow underneath
    // itself, because the glass would show that darkening through the material.
    property bool shadowEnabled: true
    property real shadowOffsetX: 12
    property real shadowOffsetY: 16
    property real shadowSoftness: 18
    property color shadowColor: Qt.rgba(0.5, 0.5, 0.5, 0.30)
    // 0 = real shadow. 1/2/3 paint the diagnostics described in KosCardShadow --
    // a probe is the only way to tell a clipped surface apart from a
    // mis-shaped or mis-wired one without guessing.
    property real shadowDebugMode: 0
    readonly property color contentForegroundColor: AppearanceTokens.colors.surfaceForeground
    readonly property color contentSecondaryColor: AppearanceTokens.colors.surfaceVariantForeground
    readonly property color contentTertiaryColor: Qt.rgba(AppearanceTokens.colors.surfaceVariantForeground.r, AppearanceTokens.colors.surfaceVariantForeground.g, AppearanceTokens.colors.surfaceVariantForeground.b, 0.54)
    readonly property color contentControlFill: AppearanceTokens.state.hover
    readonly property color contentControlBorder: AppearanceTokens.surface.outline
    property bool animateOnShow: AppearanceTokens.motion.popupAnimatesOnShow
    property real startScale: AppearanceTokens.motion.popupStartScale
    property real anchorOffset: AppearanceTokens.motion.popupAnchorOffset

    property alias visible: cardWindow.visible
    readonly property bool requestedOpen: root.animateOnShow ? popupMotion.requestedOpen : cardWindow.visible
    readonly property alias width: cardWindow.width
    readonly property alias height: cardWindow.height

    signal aboutToShow
    signal aboutToHide
    signal backdropClicked

    function show() {
        cardWindow.visible = true;
        if (root.animateOnShow)
            popupMotion.open();
    }
    function hide() {
        if (root.animateOnShow && cardWindow.visible) {
            popupMotion.close();
            return;
        }
        cardWindow.visible = false;
    }
    function open() {
        root.show();
    }
    function close() {
        root.hide();
    }
    function toggle() {
        root.requestedOpen ? root.hide() : root.show();
    }

    PanelWindow {
        id: cardWindow
        screen: root.targetScreen
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-kosfloatpanel-overlay"
        WlrLayershell.keyboardFocus: root.modal && root.requestedOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }
        exclusionMode: ExclusionMode.Ignore
        visible: false

        // The underlay is a plain theme-independent dim over the desktop.
        Rectangle {
            id: backdrop
            anchors.fill: parent
            visible: root.backdropVisible
            color: Qt.rgba(root.backdropTint.r, root.backdropTint.g, root.backdropTint.b, root.backdropEffectiveOpacity)
            Behavior on color {
                ColorAnimation {
                    duration: 140
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.modal && root.requestedOpen
            onClicked: {
                root.backdropClicked();
                if (root.dismissOnBackdrop)
                    root.close();
            }
        }

        // The card's shadow: a sibling *below* the card, never a backdrop for
        // it. Geometry mirrors the card exactly, motion included -- the same
        // scale and translate are re-stated here with the scale origin moved to
        // the card's top-left corner, which sits `margin` into this item.
        KosCardShadow {
            id: cardShadow
            castEnabled: root.shadowEnabled
            cardWidth: cardPanel.width
            cardHeight: cardPanel.height
            cornerRadius: cardPanel.radius
            cornerExponent: root.cornerExponent
            offsetX: root.shadowOffsetX
            offsetY: root.shadowOffsetY
            softness: root.shadowSoftness
            shadowColor: root.shadowColor
            debugMode: root.shadowDebugMode
            x: cardPanel.x - margin
            y: cardPanel.y - margin
            opacity: cardPanel.opacity
            transform: [
                Scale {
                    origin.x: cardShadow.margin
                    origin.y: cardShadow.margin
                    xScale: cardPanel.scale
                    yScale: cardPanel.scale
                },
                Translate {
                    y: (root.animateOnShow && popupMotion.progress < 0.999) ? Math.round((1 - popupMotion.progress) * root.anchorOffset) : 0
                }
            ]
        }

        OpaqueSurface {
            id: cardPanel
            z: 1
            radius: root.radius

            width: cardHost.width + root.contentPadding * 2
            height: cardHost.height + root.contentPadding * 2
            x: Math.round((cardWindow.width - width) / 2)
            y: Math.round((cardWindow.height - height) / 2)
            scale: (root.animateOnShow && popupMotion.progress < 0.999) ? root.startScale + (1 - root.startScale) * popupMotion.progress : 1
            transformOrigin: Item.Top
            opacity: root.animateOnShow ? popupMotion.progress : 1
            enabled: !root.animateOnShow || popupMotion.interactive
            transform: Translate {
                y: (root.animateOnShow && popupMotion.progress < 0.999) ? Math.round((1 - popupMotion.progress) * root.anchorOffset) : 0
            }

            Column {
                id: cardHost
                anchors.centerIn: parent
                width: childrenRect.width
                height: childrenRect.height
                spacing: 8
            }
        }

        mask: !root.requestedOpen ? emptyInputRegion : (root.modal ? null : cardRegion)
        Region {
            id: emptyInputRegion
        }
        Region {
            id: cardRegion
            item: cardPanel
        }
    }

    PopupMotion {
        id: popupMotion
        onClosed: {
            if (!popupMotion.requestedOpen)
                cardWindow.visible = false;
        }
    }

    Connections {
        target: cardWindow
        function onVisibleChanged() {
            if (cardWindow.visible)
                root.aboutToShow();
            else
                root.aboutToHide();
        }
    }
}
