// One screen's worth of shell: its wallpaper, and (if this screen is set to have them) its bar and its dock. Main makes one
// of these per screen. The primary screen has bar and dock unless switched off in edit mode > Screens; every other screen
// starts with the wallpaper only, and gets a bar or a dock when its switches are turned on there (config key "screens":
// { "<output name>": { "bar": true, "dock": false } }).
// The bar and the dock are ALWAYS built for the primary screen (much of the shell talks to main.topBar / main.dock:
// shortcuts, D-Bus, popups); "off" there means unmapped, not absent. On the other screens they exist only when on.
import QtQuick
import SircaShell

QtObject {
    id: set
    property string screenName: ""               // the output this set belongs to (Main's list model row)
    property var screen: null                    // its QScreen, looked up by name; kept while the name is gone (the set is being destroyed then)
    function findScreen() { for (const s of Qt.application.screens) if (s.name === screenName) { screen = s; return } }
    onScreenNameChanged: findScreen()
    property var _screens: Connections { target: Qt.application; function onScreensChanged() { set.findScreen() } }   // a re-plugged output is a new QScreen with the old name
    property var host: null                      // the root (Main.qml). Not named "main": a property called main shadows the id
    readonly property string name: screen ? screen.name : ""
    readonly property bool primary: name === Shell.primaryScreenName
    readonly property var choice: (Config.get("screens", {}) || {})[name] || {}
    readonly property bool wantBar: choice.bar !== undefined ? !!choice.bar : primary
    readonly property bool wantDock: choice.dock !== undefined ? !!choice.dock : primary
    readonly property int ox: screen ? screen.virtualX : 0
    readonly property int oy: screen ? screen.virtualY : 0

    property var wallpaper: Wallpaper { screen: set.screen; onPressedAnywhere: { set.host.closePopups(); set.host.closeDesktopMenu() }
        onMenuRequested: (x, y) => set.host.openDesktopMenu(set.screen, x, y) }
    // plasmashell's desktop window can end up ABOVE the wallpaper again (whichever of the two mapped last is on top); then
    // a right click on the desktop opens Plasma's menu. D-Bus remapWallpaper re-maps ours on top.
    property var _remap: Connections { target: Shell; function onRemapWallpaperRequested() { if (set.wallpaper) set.wallpaper.remapNow() } }

    // the bar and the dock: built at once on the primary screen, on demand elsewhere
    readonly property bool wantPanel: choice.panel !== undefined ? !!choice.panel : wantBar || wantDock
    property var panel: null
    property var _layout: Connections { target: Config; function onUnifiedPanelChanged() { set.sync() } }
    property var splitBar: null
    property var splitDock: null
    readonly property var bar: Config.unifiedPanel ? panel : splitBar
    readonly property var dock: Config.unifiedPanel ? panel : splitDock
    readonly property var _cBar: Component { TopBar { screen: set.screen; userHidden: !set.wantBar; maximizedHere: set.dock ? set.dock.anyMaximized : false
        recorder: set.host.recorder; editing: set.host.editing; onEditRequested: set.host.setEditing(true)
        quiet: set.host.fullscreenActive; busy: set.host.fullscreenActive || set.host.gameActive; showingDesktop: set.host.showingDesktop
        activeTitle: set.host.activeTitle; activeApp: set.host.activeApp; activeIcon: set.host.activeIcon
        onOpenLobeChanged: if (openLobe !== "") set.host.closeLauncher()
        onShowDesktopRequested: set.host.toggleShowDesktop()
        covered: { set.host.rev; return !set.host.showingDesktop && set.host.overlaps(Qt.rect(set.ox + x + sidePad, set.oy, barW, strutSize)) } } }
    readonly property var _cDock: Component { Dock { screen: set.screen; userHidden: !set.wantDock
        editing: set.host.editing; onEditRequested: set.host.setEditing(true); onLauncherOpenChanged: if (launcherOpen) set.host.closeLobes()
        covered: { set.host.rev; return !set.host.showingDesktop && set.host.overlaps(Qt.rect(set.ox + x + (width - dockW) / 2, set.oy + y + height - strutSize, dockW, strutSize)) } } }
    readonly property var _cPanel: Component { UnifiedPanel {
        screen: set.screen; userHidden: !set.wantPanel
        recorder: set.host.recorder; editing: set.host.editing
        showingDesktop: set.host.showingDesktop
        activeTitle: set.host.activeTitle; activeApp: set.host.activeApp; activeIcon: set.host.activeIcon
        onEditRequested: set.host.setEditing(true)
        onSearchRequested: set.host.win("search").toggle()
        onShowDesktopRequested: set.host.toggleShowDesktop()
        onLauncherOpenChanged: if (launcherOpen) set.host.closeLobes()
        covered: { set.host.rev; return !set.host.showingDesktop && set.host.overlaps(Qt.rect(set.ox + x + (width - dockW) / 2, set.oy + y + height - strutSize, dockW, strutSize)) }
    } }
    property bool _syncing: false
    property int _syncCalls: 0
    function sync() {
        if (!host || !screen || _syncing) return
        _syncing = true; _syncCalls++             // building a bar re-evaluates bindings that call sync again: one at a time
        if (Config.unifiedPanel) {
            if (splitBar) { splitBar.destroy(); splitBar = null }
            if (splitDock) { splitDock.destroy(); splitDock = null }
            if (!panel && (primary || wantPanel)) panel = _cPanel.createObject(set)
            else if (panel && !primary && !wantPanel) { panel.destroy(); panel = null }
        } else {
            if (panel) { panel.destroy(); panel = null }
            if (!splitBar && (primary || wantBar)) splitBar = _cBar.createObject(set)
            else if (splitBar && !primary && !wantBar) { splitBar.destroy(); splitBar = null }
            if (!splitDock && (primary || wantDock)) splitDock = _cDock.createObject(set)
            else if (splitDock && !primary && !wantDock) { splitDock.destroy(); splitDock = null }
        }
        _syncing = false
    }
    onWantPanelChanged: sync(); onWantBarChanged: sync(); onWantDockChanged: sync(); onPrimaryChanged: sync(); onHostChanged: sync(); onScreenChanged: sync()
    Component.onCompleted: { findScreen(); sync() }
    Component.onDestruction: { if (panel) panel.destroy(); if (splitBar) splitBar.destroy(); if (splitDock) splitDock.destroy(); if (wallpaper) wallpaper.destroy() }
}
