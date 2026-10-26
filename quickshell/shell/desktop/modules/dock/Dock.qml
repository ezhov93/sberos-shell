import Quickshell
import QtQuick
import qs.desktop.modules.common
import qs.desktop.modules.applauncher

// Keep one Dock window alive across output churn. ScreenLifecycle hides it
// while no real output exists and restores it without binding to Qt's
// synthetic placeholder screen.
Scope {
    id: root

    property Component leadingAccessory: null
    property Component trailingAccessory: null
    property Component centerAccessory: null
    property Component clockAccessory: null
    property bool clockInInfoCarousel: false

    readonly property var targetScreen: ScreenLifecycle.activeScreen
    // Never map a surface with the provisional "always" mode: KWin may keep
    // its initial exclusive zone after the saved smart mode arrives, keeping
    // maximized windows outside the Dock's collision area until mode toggles.
    readonly property bool surfaceReady: ConfigService.ready && ScreenLifecycle.outputAvailable && root.targetScreen !== null

    // Keep position-specific components so each newly selected edge commits
    // its final layer-shell anchors on the window's first frame. The Loader
    // remains instantiated while outputs disappear, so suspend/resume does not
    // tear down the active Dock window.
    Component {
        id: bottomDock
        DockWindow {
            position: "bottom"
            screen: root.targetScreen
            visible: root.surfaceReady && !(AppLauncherService.open && AppLauncherConfigService.displayMode === "fullscreen")
            leadingAccessory: root.leadingAccessory
            trailingAccessory: root.trailingAccessory
            centerAccessory: root.centerAccessory
            clockAccessory: root.clockAccessory
            clockInInfoCarousel: root.clockInInfoCarousel
        }
    }

    Component {
        id: leftDock
        DockWindow {
            position: "left"
            screen: root.targetScreen
            visible: root.surfaceReady && !(AppLauncherService.open && AppLauncherConfigService.displayMode === "fullscreen")
            leadingAccessory: root.leadingAccessory
            trailingAccessory: root.trailingAccessory
            centerAccessory: root.centerAccessory
            clockAccessory: root.clockAccessory
            clockInInfoCarousel: root.clockInInfoCarousel
        }
    }

    Component {
        id: rightDock
        DockWindow {
            position: "right"
            screen: root.targetScreen
            visible: root.surfaceReady && !(AppLauncherService.open && AppLauncherConfigService.displayMode === "fullscreen")
            leadingAccessory: root.leadingAccessory
            trailingAccessory: root.trailingAccessory
            centerAccessory: root.centerAccessory
            clockAccessory: root.clockAccessory
            clockInInfoCarousel: root.clockInInfoCarousel
        }
    }

    Loader {
        sourceComponent: ConfigService.position === "left" ? leftDock : (ConfigService.position === "right" ? rightDock : bottomDock)
    }
}
