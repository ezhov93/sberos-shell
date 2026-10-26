import Quickshell
import Quickshell.Io
import qs.desktop.modules.bar
import qs.desktop.modules.common

// Hide the layer-shell window while ScreenLifecycle settles the output list
// around sleep/resume, then bind it to the newly elected output.
Scope {
    id: root

    property bool enabled: true

    readonly property var targetScreen: ScreenLifecycle.activeScreen

    BarWindow {
        screen: root.targetScreen
        visible: root.enabled && ScreenLifecycle.outputAvailable && root.targetScreen !== null
        barEnabled: root.enabled
    }
}
