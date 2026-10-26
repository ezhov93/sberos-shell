import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "../shared/qml/i18n"
import qs.desktop.modules.bar
import qs.desktop.modules.dock
import qs.desktop.modules.quicksearch
import qs.desktop.modules.notifications
import qs.desktop.modules.applauncher
import qs.desktop.modules.deskcenter
import qs.desktop.modules.wallpaper
import qs.desktop.modules.overview
import qs.desktop.modules.stage
import qs.desktop.modules.common
import qs.desktop.modules.platform
import qs.desktop.modules.shortcuts
import qs.desktop.modules.weather

Item {
    id: shell

    IpcHandler {
        target: "notification-settings"
        function snapshot(): string {
            return JSON.stringify({
                ready: NotificationPolicyService.ready,
                sources: NotificationPolicyService.sources,
                blockedKeys: NotificationPolicyService.blockedKeys,
                doNotDisturbEnabled: NotificationPolicyService.doNotDisturbEnabled,
                bannersEnabled: NotificationPolicyService.bannersEnabled,
                historyEnabled: NotificationPolicyService.historyEnabled,
                showPreview: NotificationPolicyService.showPreview,
                showNotificationBadges: ConfigService.showNotificationBadges,
                saveError: NotificationPolicyService.saveError
            });
        }
        function setPreference(key: string, value: bool): string {
            if (key === "showNotificationBadges" && NotificationPolicyService.ready)
                ConfigService.updateNotificationBadgeVisibility(value);
            else
                NotificationPolicyService.setPreference(key, value);
            return snapshot();
        }
        function setBlocked(key: string, blocked: bool): string {
            NotificationPolicyService.setBlocked(key, blocked);
            return snapshot();
        }
    }

    // Settings edits the Quickshell-owned image and presentation preferences
    // through a narrow endpoint. Plasma remains a first-run source only.
    IpcHandler {
        target: "wallpaper-settings"

        function snapshot(): string {
            return JSON.stringify({
                image: WallpaperService.wallpaperUrl.toString(),
                wallpaperMode: WallpaperService.mode,
                themeId: WallpaperService.themeId,
                themeEconomical: WallpaperService.themeEconomical,
                themeAnimated: WallpaperService.themeAnimated,
                themeSpeed: WallpaperService.themeSpeed,
                themeParticleCount: WallpaperService.themeParticleCount,
                themeMotion: {
                    running: ThemeWallpaperService.running,
                    waiting: ThemeWallpaperService.idleDelay.running,
                    hasVisibleWindows: ThemeWallpaperService.hasVisibleWindows,
                    phase: ThemeWallpaperService.phase,
                    preview: ThemeWallpaperService.preview
                },
                previewActive: WallpaperPreviewService.active,
                previewImage: WallpaperPreviewService.image,
                previewMode: WallpaperPreviewService.mode,
                previewSelection: JSON.stringify(WallpaperPreviewService.selectedImages),
                previewCatalog: JSON.stringify(WallpaperPreviewService.imageCatalog),
                previewColors: JSON.stringify(WallpaperPreviewService.colorCatalog),
                previewInterval: WallpaperPreviewService.intervalMinutes,
                previewPending: WallpaperPreviewService.pending,
                previewError: WallpaperPreviewService.errorMessage,
                previewAvailable: WallpaperPreviewService.available,
                fitMode: WallpaperService.fitMode,
                transition: WallpaperService.transition,
                transitionOptions: JSON.stringify(WallpaperService.transitionOptions),
                slideshowImages: JSON.stringify(WallpaperService.slideshowImages),
                library: JSON.stringify(WallpaperService.library),
                slideshowEnabled: WallpaperService.slideshowEnabled,
                slideshowIntervalMinutes: WallpaperService.slideshowIntervalMinutes,
                slideshowFolder: WallpaperService.slideshowFolder,
                takeoverEnabled: WallpaperService.takeoverEnabled,
                takeoverPending: WallpaperService.takeoverPending,
                takeoverError: WallpaperService.errorMessage,
                takeoverAvailable: WallpaperService.takeoverAvailable,
                spatialResources: {
                    available: SpatialResourceService.available,
                    enabled: SpatialResourceService.enabled,
                    ready: SpatialResourceService.modelsReady,
                    busy: SpatialResourceService.busy,
                    checking: SpatialResourceService.checking,
                    stage: SpatialResourceService.stage,
                    progress: SpatialResourceService.progress,
                    error: SpatialResourceService.errorMessage,
                    modelBytes: SpatialResourceService.modelBytes,
                    generatedBytes: SpatialResourceService.generatedBytes
                },
                spatialEnabled: AppearanceConfigService.spatialWallpaperEnabled,
                spatialReady: SpatialWallpaperService.ready,
                spatialPrepared: SpatialWallpaperService.prepared,
                spatialBusy: SpatialWallpaperService.requestInFlight,
                spatialPreparing: SpatialWallpaperService.preparationRequested,
                spatialError: SpatialWallpaperService.errorMessage
            });
        }

        function previewImage(path: string, images: string): string {
            WindowService.minimizeAllWindows();
            WallpaperPreviewService.begin(path, images);
            return snapshot();
        }

        function previewSession(path: string, session: string): string {
            if (WallpaperPreviewService.beginSession(path, session))
                WindowService.minimizeAllWindows();
            return snapshot();
        }

        function setPreviewThumbnails(thumbnails: string): string {
            if (WallpaperPreviewService.active)
                WallpaperPreviewService.setThumbnails(thumbnails);
            return snapshot();
        }

        function setTransitionOptions(options: string): string {
            WallpaperService.setTransitionOptions(options);
            return snapshot();
        }

        function chooseTheme(id: string): string {
            WallpaperService.chooseTheme(id);
            return snapshot();
        }
        function setThemeEconomical(enabled: bool): string {
            WallpaperService.setThemeEconomical(enabled);
            return snapshot();
        }

        function setThemeMotion(animated: bool, speed: real, count: int): string {
            WallpaperService.setThemeMotion(animated, speed, count);
            return snapshot();
        }

        function chooseImage(path: string): string {
            if (path.indexOf("/wallpaper-colors/") >= 0)
                AppearanceConfigService.updateSpatialWallpaperEnabled(false);
            WallpaperService.chooseImage(path, true);
            return snapshot();
        }

        // 图集增删已迁移到 settings 本地托管目录(GNOME 模式),shell 只剩
        // 应用/预览/轮播等展示职责;library 字段保留在快照里供旧数据一次性
        // 迁移读取。

        function chooseColor(path: string): string {
            if (WallpaperPreviewService.chooseColor(path))
                return snapshot();
            AppearanceConfigService.updateSpatialWallpaperEnabled(false);
            WallpaperService.chooseImage(path, true);
            return snapshot();
        }

        function setTakeoverEnabled(enabled: bool): string {
            if (!enabled && AppearanceConfigService.spatialWallpaperEnabled)
                AppearanceConfigService.updateSpatialWallpaperEnabled(false);
            WallpaperService.setTakeoverEnabled(enabled);
            return snapshot();
        }

        function setFitMode(mode: string): string {
            WallpaperService.setFitMode(mode);
            return snapshot();
        }

        function setTransition(style: string): string {
            WallpaperService.setTransition(style);
            return snapshot();
        }

        function setSlideshow(enabled: bool, minutes: int, images: string, folder: string): string {
            if (WallpaperService.setSlideshow(enabled, minutes, images, folder) && enabled)
                AppearanceConfigService.updateSpatialWallpaperEnabled(false);
            return snapshot();
        }

        function setSpatialEnabled(enabled: bool): string {
            if (enabled) {
                SpatialWallpaperService.prepareForEnable();
                return snapshot();
            }
            SpatialWallpaperService.cancelPreparation();
            AppearanceConfigService.updateSpatialWallpaperEnabled(enabled);
            return snapshot();
        }

        function initializeSpatialService(): string {
            SpatialResourceService.initialize();
            return snapshot();
        }
        function disableSpatialService(): string {
            SpatialResourceService.disable();
            return snapshot();
        }
        function cancelSpatial(): string {
            SpatialWallpaperService.cancelActivation();
            SpatialResourceService.cancel();
            return snapshot();
        }
        function inspectSpatialService(): string {
            SpatialResourceService.inspect();
            return snapshot();
        }
        function clearSpatialCache(kind: string): string {
            SpatialResourceService.clear(kind);
            return snapshot();
        }

        function prepareSpatial(): string {
            SpatialWallpaperService.prepareForEnable();
            return snapshot();
        }
    }

    readonly property bool barIntegratedWithDock: AppearanceConfigService.barIntegratedWithDock

    TrayNotificationBridge {}
    IpcHandler {
        target: "control-center"
        function toggle(): void {
            ControlCenterService.toggleRequested();
        }
    }

    Component {
        id: integratedBarStatus
        Item {
            implicitWidth: statusArea.implicitWidth + 24
            implicitHeight: 72
            FrostedSurface {
                anchors.fill: parent
                radius: 24
            }
            BarStatusArea {
                id: statusArea
                anchors.centerIn: parent
                dockHosted: true
                dockEdge: ConfigService.position
                controlCenterPlacement: "without-control-center"
            }
        }
    }

    Component {
        id: integratedSberMenu
        Item {
            readonly property bool menuOpen: sberButton.menuOpen
            function updateMenuAnchor() {
                sberButton.updateMenuAnchor();
            }
            implicitWidth: 72
            implicitHeight: 72
            FrostedSurface {
                anchors.fill: parent
                radius: 24
                visible: !sberButton.menuOpen
            }
            SystemMenu {
                id: sberButton
                anchors.centerIn: parent
                menuAnchorItem: parent
                size: 18
            }
        }
    }

    Component {
        id: integratedOska
        Item {
            id: oskaIsland
            width: 456
            height: 72
            implicitWidth: 456
            implicitHeight: 72
            activeFocusOnTab: true
            Accessible.role: Accessible.Button
            Accessible.name: I18n.tr("Search installed apps")
            FrostedSurface {
                anchors.fill: parent
                radius: 24
            }
            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: "transparent"
                border.width: oskaIsland.activeFocus ? 2 : 0
                border.color: AppearanceTokens.colors.primary
            }
            Row {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12
                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40
                    height: 40
                    source: Qt.resolvedUrl("assets/oska-avatar.svg")
                    fillMode: Image.PreserveAspectFit
                    Accessible.ignored: true
                }
                ThemeText {
                    width: parent.width - 44
                    height: parent.height
                    text: I18n.tr("Найду документ или приложение")
                    color: AppearanceTokens.colors.surfaceVariantForeground
                    font.pixelSize: 16
                    verticalAlignment: Text.AlignVCenter
                    Accessible.ignored: true
                }
            }
            TapHandler {
                acceptedButtons: Qt.LeftButton
                onTapped: quickSearch.show("app", "")
            }
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    quickSearch.show("app", "");
                    event.accepted = true;
                }
            }
        }
    }

    Component {
        id: integratedClock
        Item {
            implicitWidth: clockContent.implicitWidth + 24
            implicitHeight: 72
            FrostedSurface {
                anchors.fill: parent
                radius: 24
            }
            Row {
                id: clockContent
                anchors.centerIn: parent
                spacing: 8
                BarStatusArea {
                    anchors.verticalCenter: parent.verticalCenter
                    dockHosted: true
                    dockEdge: ConfigService.position
                    controlCenterPlacement: "control-center-only"
                }
                BarDateStatus {
                    id: dateStatus
                    anchors.verticalCenter: parent.verticalCenter
                    smartPanelFormat: true
                    onActivated: sourceItem => integratedCalendarPopup.toggle(sourceItem)
                }
            }
        }
    }

    BarCalendarPopup {
        id: integratedCalendarPopup
    }

    // Theme watching is non-visual and only loads a tiny FileView. The
    // AppLauncher and its icon grid remain lazy.
    //
    // ShortcutsService is a QML singleton, so it only instantiates on first
    // access — and nothing else touches it during startup. Touch it here so
    // the global shortcuts are registered on every Shell start (self-heal);
    // An unavailable platform fails the write immediately; ShortcutsService
    // publishes again once its config is ready and the transport reconnects.
    Component.onCompleted: {
        IconThemeReloadService.initialize();
        ShortcutsService.applyToPlatform();
        // Warm the theme pack scan at startup: a persisted pack themeId is
        // validated against installed packs on every shell start, and the
        // scan should not wait for the wallpaper settings to be opened.
        ThemePackService.rescan();
        // Touch the lock screen feed so it exists on every shell start, not
        // only when a widget happens to reference WeatherService: the lock
        // screen cannot read anything the shell does not write out for it.
        LockScreenFeedService.initialize();
        if (shell.barIntegratedWithDock)
            WorkspaceLayoutService.clearBar(ScreenLifecycle.activeScreen);
    }

    onBarIntegratedWithDockChanged: {
        if (shell.barIntegratedWithDock)
            WorkspaceLayoutService.clearBar(ScreenLifecycle.activeScreen);
    }

    // The standalone Settings app is intentionally not allowed to import a
    // desktop module. This narrow IPC endpoint is its only Dock write path.
    IpcHandler {
        target: "dock-settings"

        function snapshot(): string {
            const theme = ConfigService.isValidTheme(ConfigService.theme) ? ConfigService.theme : "dark";
            const position = ConfigService.isValidPosition(ConfigService.position) ? ConfigService.position : "bottom";
            const iconMode = ConfigService.isValidIconMode(ConfigService.iconMode) ? ConfigService.iconMode : "color";
            const visibilityMode = ConfigService.isValidVisibilityMode(ConfigService.visibilityMode) ? ConfigService.visibilityMode : "always";
            const windowGrouping = ConfigService.isValidWindowGrouping(ConfigService.windowGrouping) ? ConfigService.windowGrouping : "grouped";
            const dockStyle = ConfigService.isValidDockStyle(ConfigService.dockStyle) ? ConfigService.dockStyle : "floating";
            const contentStyle = ConfigService.isValidContentStyle(ConfigService.contentStyle) ? ConfigService.contentStyle : "compact";
            const infoCardMode = ConfigService.isValidInfoCardMode(ConfigService.infoCardMode) ? ConfigService.infoCardMode : "carousel";
            return JSON.stringify({
                baseHeight: ConfigService.baseHeight,
                theme: theme,
                position: position,
                dockStyle: dockStyle,
                contentStyle: contentStyle,
                // The one hover control uses the effective peak scale.
                hoverScale: ConfigService.effectiveHoverScale,
                infoCardMode: infoCardMode,
                infoCardAutoRotate: ConfigService.infoCardAutoRotate,
                infoCardOrder: JSON.stringify(ConfigService.infoCardOrder),
                iconMode: iconMode,
                iconOpacity: ConfigService.iconOpacity,
                iconTintColor: ConfigService.iconTintColor,
                visibilityMode,
                windowGrouping,
                showLauncher: ConfigService.showLauncher,
                showTrash: ConfigService.showTrash,
                showNotificationBadges: ConfigService.showNotificationBadges,
                showRevealIndicator: ConfigService.showRevealIndicator
            });
        }

        function updateLayout(height: real): string {
            ConfigService.updateLayout(height);
            return snapshot();
        }

        function updateNotificationBadgeVisibility(visible: bool): string {
            ConfigService.updateNotificationBadgeVisibility(visible);
            return snapshot();
        }

        function updateRevealIndicatorVisibility(visible: bool): string {
            ConfigService.updateRevealIndicatorVisibility(visible);
            return snapshot();
        }

        function updateBuiltinVisibility(id: string, visible: bool): string {
            ConfigService.updateBuiltinVisibility(id, visible);
            return snapshot();
        }

        function updatePosition(newPosition: string): string {
            ConfigService.updatePosition(newPosition);
            return snapshot();
        }

        function updateContentStyle(newStyle: string): string {
            ConfigService.updateContentStyle(newStyle);
            return snapshot();
        }

        function updateDockStyle(newStyle: string): string {
            ConfigService.updateDockStyle(newStyle);
            return snapshot();
        }

        function updateHoverScale(scale: real): string {
            ConfigService.updateHoverScale(scale);
            return snapshot();
        }

        function updateInfoCardMode(mode: string): string {
            ConfigService.updateInfoCardMode(mode);
            return snapshot();
        }

        function updateInfoCardAutoRotate(enabled: bool): string {
            ConfigService.updateInfoCardAutoRotate(enabled);
            return snapshot();
        }

        function updateInfoCardOrder(orderJson: string): string {
            try {
                ConfigService.updateInfoCardOrder(JSON.parse(orderJson));
            } catch (error) {
                console.warn("[DockSettings] invalid info card order: " + error);
            }
            return snapshot();
        }

        function updateTheme(theme: string): string {
            ConfigService.updateTheme(theme);
            return snapshot();
        }

        function updateIconMode(mode: string): string {
            ConfigService.updateIconMode(mode);
            return snapshot();
        }

        function updateIconOpacity(opacity: real): string {
            ConfigService.updateIconOpacity(opacity);
            return snapshot();
        }

        function updateIconTintColor(color: string): string {
            ConfigService.updateIconTintColor(color);
            return snapshot();
        }

        function updateVisibilityMode(mode: string): string {
            ConfigService.updateVisibilityMode(mode);
            return snapshot();
        }

        function updateWindowGrouping(mode: string): string {
            ConfigService.updateWindowGrouping(mode);
            return snapshot();
        }
    }

    // Shell appearance settings used by the standalone Settings app.
    // Activate-or-launch endpoint for remote surfaces (the Settings app's
    // KDE settings link): a running window is raised via the same identity
    // machinery the Dock uses, a stopped app is launched. Unlike the Dock's
    // click flow, an already-focused app is never minimized here.
    IpcHandler {
        target: "app-launch"

        function open(id: string): string {
            const target = String(id || "").trim();
            if (!target)
                return "failed";
            const identity = AppIdentityService.resolve(target);
            const windows = WindowService.windowsForApp(identity.desktopId);
            if (windows.length > 0) {
                const mru = windows.reduce((a, b) => WindowService.lastActivatedAtOf(a.windowId) >= WindowService.lastActivatedAtOf(b.windowId) ? a : b);
                WindowService.activateGroup(windows.map(function (w) {
                    return w.windowId;
                }), mru.windowId);
                return "ok";
            }
            return AppActionService.launch(identity) ? "ok" : "failed";
        }
    }

    IpcHandler {
        target: "appearance-settings"

        function snapshot(): string {
            return JSON.stringify({
                iconMode: IconAppearanceService.mode,
                iconOpacity: IconAppearanceService.opacity,
                iconTintColor: IconAppearanceService.tintColor.toString(),
                spatialWallpaperEnabled: AppearanceConfigService.spatialWallpaperEnabled,
                barVisibilityMode: AppearanceConfigService.barVisibilityMode,
                dockWindowAnimationStyle: AppearanceConfigService.dockWindowAnimationStyle,
                hiddenDeskCenterWidgets: JSON.stringify(AppearanceConfigService.hiddenDeskCenterWidgets),
                hiddenStatusCells: JSON.stringify(AppearanceConfigService.hiddenStatusCells),
                deskCenterWidgetIds: JSON.stringify(AppearanceConfigService.deskCenterWidgetIds),
                statusCellIds: JSON.stringify(AppearanceConfigService.statusCellIds),
                tokenVersion: AppearanceTokens.version
            });
        }

        function updateGlobalIconMode(mode: string): string {
            IconAppearanceService.updateMode(mode);
            return snapshot();
        }

        function updateGlobalIconOpacity(opacity: real): string {
            IconAppearanceService.updateOpacity(opacity);
            return snapshot();
        }

        function updateGlobalIconTintColor(color: string): string {
            IconAppearanceService.updateTintColor(color);
            return snapshot();
        }

        function updateSpatialWallpaperEnabled(enabled: bool): string {
            AppearanceConfigService.updateSpatialWallpaperEnabled(enabled);
            return snapshot();
        }

        function updateBarVisibilityMode(mode: string): string {
            AppearanceConfigService.updateBarVisibilityMode(mode);
            return snapshot();
        }

        function updateDockWindowAnimationStyle(style: string): string {
            AppearanceConfigService.updateDockWindowAnimationStyle(style);
            return snapshot();
        }

        // Per-surface visibility. `visible` is the wanted state, so the switch
        // in the Settings page holds the same value it displays.
        function updateDeskCenterWidgetVisibility(id: string, visible: bool): string {
            AppearanceConfigService.setDeskCenterWidgetVisible(id, visible);
            return snapshot();
        }

        function updateStatusCellVisibility(id: string, visible: bool): string {
            AppearanceConfigService.setStatusCellVisible(id, visible);
            return snapshot();
        }

        // The standalone Settings app talks to this narrow Shell endpoint;
        // only the resident platform daemon performs KDE theme operations.
        function applySystemAppearance(dark: bool): string {
            PlatformClient.request("theme.apply-system", {
                dark: dark
            }, function (response) {
                if (!response?.ok)
                    console.warn("[Appearance] system theme failed: " + (response?.error?.message || "platform unavailable"));
            });
            return JSON.stringify({
                accepted: true
            });
        }
    }

    // AppLauncher settings endpoint for standalone Settings app and IPC clients.
    IpcHandler {
        target: "applauncher-settings"

        function snapshot(): string {
            return JSON.stringify({
                displayMode: AppLauncherConfigService.displayMode,
                layoutProfiles: AppLauncherConfigService.layoutProfiles
            });
        }

        function updateProfileIconSize(mode: string, size: string): string {
            AppLauncherConfigService.updateProfileIconSize(mode, size);
            return snapshot();
        }

        function updateProfileDensity(mode: string, density: string): string {
            AppLauncherConfigService.updateProfileDensity(mode, density);
            return snapshot();
        }

        function updateProfileFontWeight(mode: string, weight: string): string {
            AppLauncherConfigService.updateProfileFontWeight(mode, weight);
            return snapshot();
        }

        function resetProfile(mode: string): string {
            AppLauncherConfigService.resetProfile(mode);
            return snapshot();
        }
    }

    // Global-shortcut endpoint for the standalone Settings app. ShortcutsService
    // owns defaults, overrides, and the kglobalaccel handoff; this handler is
    // the only write path the Settings app gets, matching the other targets.
    IpcHandler {
        target: "shortcuts-settings"

        function snapshot(): string {
            return JSON.stringify(ShortcutsService.snapshot());
        }

        function updateShortcut(id: string, combo: string): string {
            return JSON.stringify(ShortcutsService.updateShortcut(id, combo));
        }

        function resetShortcut(id: string): string {
            return JSON.stringify(ShortcutsService.resetShortcut(id));
        }
    }

    // Read-only health snapshot for the standalone Settings app. Keep these
    // values sourced from the live Shell connections so the UI reports what
    // is actually connected, not merely which units were installed.
    IpcHandler {
        target: "integration-status"

        function snapshot(): string {
            return JSON.stringify({
                shellReady: true,
                platformConnected: PlatformClient.connected,
                dataConnected: DataClient.connected,
                outputAvailable: ScreenLifecycle.outputAvailable,
                desktopWidgetsVisible: ScreenLifecycle.outputAvailable && ScreenLifecycle.activeScreen !== null,
                desktopFilesReady: DesktopFilesService.ready
            });
        }
    }

    // Language preference endpoint for the standalone Settings app. I18nService
    // owns persistence and applies the value to the shared I18n singleton;
    // every I18n.tr() binding re-evaluates when it changes.
    IpcHandler {
        target: "i18n-settings"

        function snapshot(): string {
            return I18nService.snapshot();
        }

        function updateLanguage(language: string): string {
            I18nService.setLanguage(language);
            return I18nService.snapshot();
        }
    }

    // The KWin effect observes pointer presses at compositor scope and routes
    // them through WindowService's existing local bridge. Keep the policy here
    // so individual desktop, Dock, and tray surfaces need no outside-click
    // listeners.
    Connections {
        target: WindowService
        function onGlobalPointerPressed(x, y, button, timestamp) {
            ContextMenuCoordinator.dismissForGlobalPointerPress(x, y, timestamp);
        }
    }

    QuickSearch {
        id: quickSearch
    }
    AppLauncher {}
    Overview {}
    StageSidebar {}
    IpcHandler {
        target: "desktop"
        function toggle(): void {
            WindowService.toggleShowDesktop();
        }
        function show(): void {
            WindowService.toggleShowDesktop();
        }
    }
    NotificationCenter {
        id: notificationCenter
    }

    DeskCenter {}
    DesktopLyrics {}
    Dock {
        leadingAccessory: shell.barIntegratedWithDock ? integratedSberMenu : null
        clockInInfoCarousel: shell.barIntegratedWithDock && ConfigService.position === "bottom"
        trailingAccessory: shell.barIntegratedWithDock ? integratedBarStatus : null
        centerAccessory: shell.barIntegratedWithDock ? integratedOska : null
        clockAccessory: shell.barIntegratedWithDock ? integratedClock : null
    }
}
