pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.desktop.modules.platform
import "VisibilityPolicy.mjs" as VisibilityPolicy

// Persistent settings shared by shell surfaces. This service contains only
// supported SberOS appearance and visibility options.
QtObject {
    id: service

    readonly property string configDir: Quickshell.stateDir + "/appearance"
    readonly property string configPath: configDir + "/config.json"

    property string themeMode: "system"
    property bool spatialWallpaperEnabled: false
    property bool spatialServiceEnabled: false
    readonly property bool barIntegratedWithDock: true
    property string barVisibilityMode: "always"
    property string dockWindowAnimationStyle: "scale"
    property bool ready: false
    property var hiddenDeskCenterWidgets: []
    property var hiddenStatusCells: []

    readonly property var deskCenterWidgetIds: VisibilityPolicy.deskCenterWidgetIds
    readonly property var statusCellIds: VisibilityPolicy.statusCellIds

    function isValidThemeMode(value) {
        return value === "system" || value === "light" || value === "dark";
    }

    function isValidDockWindowAnimationStyle(value) {
        return value === "scale" || value === "genie";
    }

    function isValidBarVisibilityMode(value) {
        return value === "always" || value === "smart" || value === "persistent";
    }

    function _toBool(value) {
        return value === true || value === 1 || String(value).toLowerCase() === "true";
    }

    function isKnownDeskCenterWidget(id) {
        return VisibilityPolicy.isKnownDeskCenterWidget(id);
    }

    function isKnownStatusCell(id) {
        return VisibilityPolicy.isKnownStatusCell(id);
    }

    function isDeskCenterWidgetHidden(id) {
        return VisibilityPolicy.isHidden(service.hiddenDeskCenterWidgets, id);
    }

    function isStatusCellHidden(id) {
        return VisibilityPolicy.isHidden(service.hiddenStatusCells, id);
    }

    function setDeskCenterWidgetVisible(id, visible) {
        const next = VisibilityPolicy.withVisibility(service.hiddenDeskCenterWidgets, id, visible, VisibilityPolicy.deskCenterWidgetIds);
        if (next === null)
            return false;
        service.hiddenDeskCenterWidgets = next;
        saveTimer.restart();
        return true;
    }

    function setStatusCellVisible(id, visible) {
        const next = VisibilityPolicy.withVisibility(service.hiddenStatusCells, id, visible, VisibilityPolicy.statusCellIds);
        if (next === null)
            return false;
        service.hiddenStatusCells = next;
        saveTimer.restart();
        return true;
    }

    function updateThemeMode(rawMode) {
        const mode = String(rawMode);
        if (!isValidThemeMode(mode) || themeMode === mode)
            return false;
        themeMode = mode;
        saveTimer.restart();
        return true;
    }

    function updateSpatialServiceEnabled(rawValue) {
        const value = _toBool(rawValue);
        if (spatialServiceEnabled === value)
            return false;
        spatialServiceEnabled = value;
        saveTimer.restart();
        return true;
    }

    function updateSpatialWallpaperEnabled(rawValue) {
        const value = _toBool(rawValue);
        if (spatialWallpaperEnabled === value)
            return false;
        spatialWallpaperEnabled = value;
        saveTimer.restart();
        return true;
    }

    function updateDockWindowAnimationStyle(rawStyle) {
        const style = String(rawStyle);
        if (!isValidDockWindowAnimationStyle(style) || dockWindowAnimationStyle === style)
            return false;
        dockWindowAnimationStyle = style;
        saveTimer.restart();
        dockAnimationEffectSyncTimer.restart();
        return true;
    }

    function updateBarVisibilityMode(rawMode) {
        const mode = String(rawMode);
        if (!isValidBarVisibilityMode(mode) || barVisibilityMode === mode)
            return false;
        barVisibilityMode = mode;
        saveTimer.restart();
        return true;
    }

    property Timer saveTimer: Timer {
        interval: 350
        repeat: false
        onTriggered: service._save()
    }

    property Timer dockAnimationEffectSyncTimer: Timer {
        interval: 80
        repeat: false
        onTriggered: service._syncDockWindowAnimationEffect()
    }

    property Connections platformTransport: Connections {
        target: PlatformClient
        function onTransportChanged(connected) {
            if (connected)
                service.dockAnimationEffectSyncTimer.restart();
        }
    }

    function _save() {
        const payload = JSON.stringify({
            version: 1,
            themeMode: service.themeMode,
            spatialWallpaperEnabled: service.spatialWallpaperEnabled,
            spatialServiceEnabled: service.spatialServiceEnabled,
            barVisibilityMode: service.barVisibilityMode,
            dockWindowAnimationStyle: service.dockWindowAnimationStyle,
            hiddenDeskCenterWidgets: service.hiddenDeskCenterWidgets.slice().sort(),
            hiddenStatusCells: service.hiddenStatusCells.slice().sort()
        }, null, 2);
        JsonConfigStore.writePath(service.configPath, payload);
    }

    function _syncDockWindowAnimationEffect() {
        PlatformClient.request("theme.sync-dock-animation", {
            style: service.dockWindowAnimationStyle
        }, function (response) {
            if (!response?.ok)
                console.warn("[AppearanceConfig] Dock animation sync failed: " + (response?.error?.message || "platform unavailable"));
        });
    }

    function _load() {
        JsonConfigStore.readPath(service.configPath, function (data, exists) {
            if (exists && data) {
                try {
                    const object = JSON.parse(data);
                    if (service.isValidThemeMode(String(object.themeMode ?? "")))
                        service.themeMode = String(object.themeMode);
                    if (typeof object.spatialWallpaperEnabled === "boolean")
                        service.spatialWallpaperEnabled = object.spatialWallpaperEnabled;
                    if (typeof object.spatialServiceEnabled === "boolean")
                        service.spatialServiceEnabled = object.spatialServiceEnabled;
                    if (service.isValidBarVisibilityMode(String(object.barVisibilityMode ?? "")))
                        service.barVisibilityMode = String(object.barVisibilityMode);
                    if (service.isValidDockWindowAnimationStyle(String(object.dockWindowAnimationStyle ?? "")))
                        service.dockWindowAnimationStyle = String(object.dockWindowAnimationStyle);
                    service.hiddenDeskCenterWidgets = VisibilityPolicy.normalizeHiddenIds(object.hiddenDeskCenterWidgets, VisibilityPolicy.deskCenterWidgetIds);
                    service.hiddenStatusCells = VisibilityPolicy.normalizeHiddenIds(object.hiddenStatusCells, VisibilityPolicy.statusCellIds);
                } catch (error) {
                    console.warn("[AppearanceConfig] parse error: " + error);
                }
            }
            service.ready = true;
            service.dockAnimationEffectSyncTimer.restart();
        });
    }

    Component.onCompleted: _load()
}
