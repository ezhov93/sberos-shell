import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.desktop.modules.common
import qs.desktop.modules.bar
import qs.desktop.modules.dock
import qs.desktop.modules.applauncher
import qs.desktop.modules.notifications

ShellRoot {
    id: test
    property int stage: 0
    property real savedProgress: 0
    property int stableSurfaceChecks: 0
    property int launcherVariant: 0
    property real launcherClosedAt: 0
    property var launcherFrame: null
    property var launcherLayout: null
    property real stableLayoutWidth: 0
    property real stableLayoutHeight: 0
    readonly property var launcherVariants: [
        {
            mode: "bottom",
            edge: "bottom"
        },
        {
            mode: "bottomWide",
            edge: "bottom"
        },
        {
            mode: "bottom",
            edge: "left"
        },
        {
            mode: "bottom",
            edge: "right"
        },
        {
            mode: "center",
            edge: "bottom"
        },
        {
            mode: "fullscreen",
            edge: "bottom"
        }
    ]

    FloatingWindow {
        id: host
        visible: true
        width: 500
        height: 700
        Item {
            id: anchorItem
            x: 150
            y: 20
            width: 40
            height: 30
        }
        Item {
            id: geometryParent
            x: 30
            y: 45
            width: 200
            height: 200
            Item {
                id: geometryItem
                x: 15
                y: 20
                width: 100
                height: 60
            }
            transform: Translate {
                id: geometryTranslation
                x: 0
                y: 0
            }
        }
        ControlCenterCard {
            id: contentProbe
            x: 300
            y: 100
            contentOpacity: 0.25
            contentOffsetY: 6
            cardScale: 0.9
            Item {
                id: probeChild
                width: 10
                height: 10
            }
        }
    }
    RoundedInputRegion {
        id: region
        item: geometryItem
        radius: 10
    }
    ControlCenterPanel {
        id: center
        anchorItem: anchorItem
    }
    AnimatedPopupWindow {
        id: popup
        anchor.item: anchorItem
        implicitWidth: 100
        implicitHeight: 70
        Rectangle {
            anchors.fill: parent
            color: "gray"
        }
    }
    ContextMenu {
        id: menu
        anchorItem: anchorItem
    }
    DockInfoPopup {
        id: info
        anchorItem: anchorItem
        page: 2
    }
    AppLauncherWindow {
        id: launcher
        outputAvailable: true
    }

    QtObject {
        id: notificationGroups
        property ListModel groupsModel: ListModel {}
        property int sidecarRevision: 0
        property var dismissed: []
        property var notice: ({
                summary: "Notification motion",
                body: "The surface stays with the card.",
                appName: "Motion test",
                image: "",
                appIcon: "",
                urgency: 2,
                expireTimeout: 0,
                actions: [],
                hasInlineReply: false
            })
        function latestForKey(key) {
            return dismissed.indexOf(key) < 0 ? notice : null;
        }
        function dismissGroupByKey(key) {
            dismissed = dismissed.concat([key]);
            sidecarRevision++;
            for (let index = 0; index < groupsModel.count; ++index) {
                if (groupsModel.get(index).groupKey === key) {
                    groupsModel.remove(index);
                    return;
                }
            }
        }
        function expireGroupByKey(key) {
            dismissGroupByKey(key);
        }
    }
    NotificationWindow {
        id: notifications
        groupService: notificationGroups
        visible: true
        exitDuration: 600
    }

    function checkNotificationCards(expectedCount) {
        const cards = notifications.visibleCards;
        check(cards.length === expectedCount, "notification delegates survive until their slide finishes: " + cards.length + " vs " + expectedCount);
        for (const card of cards) {
            if (card.removing) {
                check(!card.enabled && card.displaySummary === "Notification motion", "departing card retains its content without accepting input");
            }
        }
    }

    Connections {
        target: center
        function onPageProgressChanged() {
            Qt.callLater(test.checkPersistentSurface);
        }
    }

    // Shipping cards are reparented into the scrolling panel canvas. Walk
    // that actual hierarchy rather than assuming direct contentItem children.
    function visibleCards(item) {
        let cards = [];
        for (const child of item.children || []) {
            if (child.isControlCenterCard && child.visible)
                cards.push(child);
            else
                cards = cards.concat(visibleCards(child));
        }
        return cards;
    }

    function checkPersistentSurface() {
        if (!center.isOpen || center.revealProgress !== 1 || center.pageProgress === 1 || center.displayedSubmenu === "confirm")
            return;
        try {
            const cards = visibleCards(center.contentItem);
            check(cards.length > 0, "a page transition always retains its card surfaces");
            for (const card of cards) {
                check(card.contentOpacity === 1 && card.opacity >= 0 && card.opacity <= 1, "the card surface follows the page opacity");
                check(card.opacity >= 0 && card.opacity <= 1, "a transitioning card stays inside the fade range");
            }
            stableSurfaceChecks++;
        } catch (error) {
            console.error("POPUP_MOTION_FAIL " + error);
            Qt.quit();
        }
    }

    function check(condition, message) {
        if (!condition)
            throw new Error(message);
    }

    function findItem(item, name) {
        if (item.objectName === name)
            return item;
        for (const child of item.children || []) {
            const found = findItem(child, name);
            if (found)
                return found;
        }
        return null;
    }

    function checkLauncherFrame() {
        check(launcherFrame.width > 0 && launcherFrame.height > 0 && launcherFrame.width === stableLayoutWidth && launcherFrame.height === stableLayoutHeight, "the launcher surface keeps its full dimensions during tile motion");
        check(launcherLayout.width === stableLayoutWidth && launcherLayout.height === stableLayoutHeight, "grid layout remains fixed throughout the panel animation");
        const surface = findItem(launcherFrame, "launcher-opaque-surface");
        const content = findItem(launcherFrame, "launcher-motion-content");
        check(launcherFrame.opacity === 1 && content.opacity === 1 && content.y === 0 && content.scale === 1, "tile animations keep the surface and content container stationary");
        check(surface && surface.opacity >= 0 && surface.opacity <= 1, "launcher surface opacity remains in range during tile motion");
        check(launcherFrame.x === 0 && launcherFrame.y === 0, "tile animations do not displace the backdrop");
    }

    function checkGeometry() {
        const expected = geometryItem.mapToItem(null, Qt.rect(0, 0, geometryItem.width, geometryItem.height));
        check(Math.abs(region.itemRect.x - expected.x) < 0.01 && Math.abs(region.itemRect.y - expected.y) < 0.01 && Math.abs(region.itemRect.width - expected.width) < 0.01, "blur mask follows the complete transformed scene rectangle");
    }

    Timer {
        id: steps
        running: true
        repeat: true
        interval: 400
        onTriggered: {
            try {
                console.log("POPUP_MOTION_STAGE " + test.stage);
                switch (test.stage++) {
                case 0:
                    checkGeometry();
                    check(probeChild.parent !== contentProbe && probeChild.parent.opacity === 0.25 && probeChild.parent.scale === 0.9, "declared card children use the animated content host");
                    geometryParent.scale = 0.8;
                    geometryParent.x = 60;
                    geometryTranslation.y = 13;
                    center.toggle(anchorItem);
                    popup.show();
                    info.show();
                    interval = 60;
                    break;
                case 1:
                    checkGeometry();
                    check(center.visible && center.revealProgress > 0 && center.revealProgress < 1, "control center animates its entrance");
                    savedProgress = center.revealProgress;
                    center.close();
                    check(!center.isOpen && center.visible && !center.contentItem.enabled, "closing immediately releases input but retains the surface");
                    check(center.revealProgress === savedProgress, "close never snaps progress");
                    center.toggle(anchorItem);
                    check(center.isOpen && center.revealProgress === savedProgress, "reopening reverses from current progress");
                    popup.hide();
                    check(popup.visible && !popup.interactive, "common popup releases input on exit");
                    popup.show();
                    interval = 300;
                    break;
                case 2:
                    check(info.visible && info.width > 0, "clock details open with a visible surface");
                    info.page = 1;
                    check(center.revealProgress === 1 && popup.revealProgress === 1, "old exit callbacks cannot close reopened surfaces");
                    center.openSubmenu("wifi");
                    check(center.activeSubmenu === "wifi" && center.displayedSubmenu === "wifi", "crossfade commits the incoming page on the first frame");
                    center.closeSubmenu();
                    check(center.activeSubmenu === "", "back clears logical state synchronously");
                    center.openSubmenu("wifi");
                    interval = 60;
                    break;
                case 3:
                    check(center.displayedSubmenu === "wifi" && center.pageProgress < 1, "the Wi-Fi page fades in while the main controls fade out");
                    check(center.outgoingPage === "", "the primary page is the fading side of the crossfade");
                    savedProgress = center.pageProgress;
                    center.close();
                    center.toggle(anchorItem);
                    center.openSubmenu("wifi");
                    check(center.pageProgress === savedProgress, "closing and reopening during navigation preserves the current frame");
                    interval = 350;
                    break;
                case 4:
                    check(info.title === "天气" && info.visible, "weather details retain the same surface");
                    info.page = 3;
                    check(center.displayedSubmenu === "wifi" && center.pageProgress === 1, "Wi-Fi page settles");
                    center.closeSubmenu();
                    check(center.activeSubmenu === "" && center.displayedSubmenu === "" && center.outgoingPage === "wifi", "back keeps outgoing Wi-Fi content alive");
                    interval = 60;
                    break;
                case 5:
                    savedProgress = center.pageProgress;
                    center.openSubmenu("wifi");
                    check(center.pageProgress === savedProgress, "page reversal is continuous");
                    interval = 300;
                    break;
                case 6:
                    check(info.title === "资源占用" && info.visible, "metrics details retain the same surface");
                    center.openSubmenu("bluetooth");
                    center.openSubmenu("sound");
                    center.openSubmenu("brightness");
                    interval = 400;
                    break;
                case 7:
                    check(center.displayedSubmenu === "brightness" && center.pageProgress === 1, "rapid navigation commits only the latest destination");
                    center.close();
                    check(center.activeSubmenu === "" && !center.submenuOpen && center.displayedSubmenu === "brightness", "close freezes the visible page");
                    interval = 250;
                    break;
                case 8:
                    check(!center.visible, "control center unmaps only after exit completes");
                    center.toggle(anchorItem);
                    check(center.displayedSubmenu === "", "fresh open never shows a stale submenu");
                    interval = 300;
                    break;
                case 9:
                    center.openSessionPanel();
                    interval = 400;
                    break;
                case 10:
                    check(center.displayedSubmenu === "session", "session is an animated page");
                    center.pendingConfirmAction = "poweroff";
                    interval = 350;
                    break;
                case 11:
                    check(center.displayedSubmenu === "confirm", "confirmation replaces session card");
                    center.pendingConfirmAction = "";
                    interval = 400;
                    break;
                case 12:
                    check(center.displayedSubmenu === "session" && center.isOpen, "cancel restores session without closing control center");
                    center.close();
                    menu.setItems([
                        {
                            label: "Root",
                            children: [
                                {
                                    label: "Child",
                                    cmd: "child"
                                }
                            ]
                        }
                    ]);
                    menu.show();
                    interval = 300;
                    break;
                case 13:
                    menu.enter([
                        {
                            label: "Child",
                            cmd: "child"
                        }
                    ]);
                    check(menu.displayedPage.items[0].label === "Root", "menu retains outgoing rows");
                    interval = 400;
                    break;
                case 14:
                    // Exercise a populated, scrolling catalog without depending on
                    // the applications installed in the VM.
                    launcher.applications = Array.from({
                        length: 80
                    }, (_, i) => ({
                                id: "motion-" + i + ".desktop",
                                name: "Motion " + i,
                                icon: ""
                            }));
                    launcher.applicationsDirty = false;
                    check(menu.displayedPage.items[0].label === "Child", "menu page animation settles");
                    menu.hide();
                    menu.show();
                    AppLauncherService.dockWidth = 800;
                    AppLauncherService.dockHeight = 60;
                    launcher.open = true;
                    interval = 380;
                    break;
                case 15:
                    check(menu.visible, "context menu close can reverse");
                    check(launcher.panelVisible, "launcher entrance retains the panel");
                    launcher.open = false;
                    check(launcher.panelVisible, "launcher close retains its surface until tiles finish");
                    interval = 60;
                    break;
                case 16:
                    check(launcher.panelVisible && !launcher.open, "launcher remains mapped during the tile exit animation");
                    launcher.open = true;
                    popup.hide();
                    menu.hide();
                    info.hide();
                    interval = 300;
                    break;
                case 17:
                    check(stableSurfaceChecks > 10, "surfaces remain stable across animation frames");
                    check(!info.visible, "the detail popup closes");
                    check(!popup.visible && !menu.visible, "popups unmap after closing");
                    check(launcher.panelVisible && launcher.open, "launcher exit can reverse");
                    launcher.open = false;
                    launcher.outputAvailable = true;
                    interval = 300;
                    break;
                case 18:
                    AppLauncherConfigService.displayMode = launcherVariants[launcherVariant].mode;
                    AppLauncherService.dockPosition = launcherVariants[launcherVariant].edge;
                    AppLauncherService.dockWidth = 800;
                    AppLauncherService.dockHeight = 60;
                    launcherFrame = findItem(launcher.contentItem, "launcher-motion-frame");
                    launcherLayout = findItem(launcher.contentItem, "launcher-stable-layout");
                    check(launcherFrame !== null && launcherLayout !== null, "launcher frame loads");
                    launcher.open = true;
                    interval = 65;
                    break;
                case 19:
                    stableLayoutWidth = launcherLayout.width;
                    stableLayoutHeight = launcherLayout.height;
                    checkLauncherFrame();
                    interval = 350;
                    break;
                case 20:
                    check(launcherFrame.width === stableLayoutWidth && launcherFrame.height === stableLayoutHeight, "panel settles to full size");
                    launcher.open = false;
                    check(!launcherFrame.enabled, "exit immediately disables card input");
                    check(launcherFrame.width === stableLayoutWidth, "close starts without a geometry jump");
                    interval = 70;
                    break;
                case 21:
                    checkLauncherFrame();
                    launcher.open = true;
                    checkLauncherFrame();
                    interval = 330;
                    break;
                case 22:
                    check(launcherFrame.width === stableLayoutWidth && launcherFrame.height === stableLayoutHeight, "reopening restores full panel size");
                    launcher.open = false;
                    launcherClosedAt = Date.now();
                    interval = 350;
                    break;
                case 23:
                    // VM render-thread jobs can start later than GUI timers.
                    // Keep a finite deadline while checking the actual lifetime.
                    if (launcher.panelVisible && Date.now() - launcherClosedAt < 2000) {
                        test.stage = 23;
                        interval = 50;
                        break;
                    }
                    check(!launcherFrame.visible, "the launcher surface retires after the closing tile animations finish");
                    launcherVariant++;
                    if (launcherVariant < launcherVariants.length) {
                        test.stage = 18;
                        interval = 40;
                    } else {
                        interval = 40;
                    }
                    break;
                case 24:
                    notificationGroups.groupsModel.append({
                        groupKey: "first",
                        count: 1,
                        collapsed: true
                    });
                    notificationGroups.groupsModel.append({
                        groupKey: "second",
                        count: 1,
                        collapsed: true
                    });
                    interval = 280;
                    break;
                case 25:
                    checkNotificationCards(2);
                    notifications.visibleCards.find(card => card.groupKey === "first").close(false);
                    interval = 80;
                    break;
                case 26:
                    checkNotificationCards(2);
                    check(notificationGroups.groupsModel.count === 1, "dismiss removes the model row immediately");
                    check(notifications.visibleCards.some(card => card.removing && card.x > 0), "removed notification and its blur continue sliding together");
                    check(notifications.mask.regions.length === 1, "departing card releases its input region");
                    interval = 600;
                    break;
                case 27:
                    checkNotificationCards(1);
                    notifications.visibleCards[0].close(true);
                    interval = 80;
                    break;
                case 28:
                    checkNotificationCards(1);
                    check(notificationGroups.groupsModel.count === 0 && notifications.mask.regions.length === 0, "last notification keeps its exiting blur without blocking input");
                    notificationGroups.groupsModel.append({
                        groupKey: "replacement",
                        count: 1,
                        collapsed: true
                    });
                    interval = 50;
                    break;
                case 29:
                    checkNotificationCards(2);
                    interval = 600;
                    break;
                case 30:
                    checkNotificationCards(1);
                    notifications.visibleCards[0].close(false);
                    interval = 650;
                    break;
                case 31:
                    check(notifications.visibleCards.length === 0, "notification cards retire after their exit animations");
                    console.log("POPUP_MOTION_PASS");
                    Qt.quit();
                    break;
                }
            } catch (error) {
                console.error("POPUP_MOTION_FAIL stage=" + (test.stage - 1) + " " + error);
                Qt.quit();
            }
        }
    }
}
