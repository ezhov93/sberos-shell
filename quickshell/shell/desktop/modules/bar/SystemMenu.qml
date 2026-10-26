import QtQuick
import Quickshell
import qs.desktop
import qs.desktop.modules.common
import qs.desktop.modules.dock
import "../../../shared/qml/i18n"

// The leftmost Sber panel button routes through existing desktop services.
Item {
    id: root

    property real size: 18
    property color color: ThemeService.barInk
    // In the integrated Dock, the popup uses the whole Sber island as its
    // anchor so its last row can replace the button inside one continuous menu.
    property Item menuAnchorItem: null
    readonly property bool menuOpen: menu.visible
    implicitWidth: 30
    implicitHeight: 28
    width: implicitWidth
    height: implicitHeight
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: I18n.tr(root.menuOpen ? "Collapse" : "Sber menu")

    function updateMenuAnchor() {
        if (menu.visible)
            menu.anchor.updateAnchor();
    }

    function installedId(candidates) {
        for (const id of candidates) {
            if (AppPresentationService.entryFor(id))
                return id;
        }
        return "";
    }

    function openMenu() {
        const terminalId = installedId(["org.kde.konsole.desktop", "konsole.desktop", "org.gnome.Terminal.desktop", "org.xfce.terminal.desktop"]);
        const sessionReady = !ControlCenterService.sessionActionInProgress;
        const missing = " " + I18n.tr("(Not installed)");
        menu.setItems([
            {
                icon: "preferences-system",
                label: I18n.tr("Shell settings"),
                cmd: "settings"
            },
            {
                icon: "terminal",
                label: I18n.tr("Terminal") + (terminalId ? "" : missing),
                cmd: "terminal",
                desktopId: terminalId,
                enabled: terminalId.length > 0
            },
            {
                icon: "power",
                label: I18n.tr("Power and session"),
                children: [
                    {
                        icon: "system-log-out",
                        label: I18n.tr("Log Out"),
                        cmd: "logout",
                        enabled: sessionReady
                    },
                    {
                        icon: "system-reboot",
                        label: I18n.tr("Restart"),
                        cmd: "reboot",
                        enabled: sessionReady
                    },
                    {
                        icon: "system-shutdown",
                        label: I18n.tr("Power Off"),
                        cmd: "poweroff",
                        enabled: sessionReady
                    },
                    {
                        separator: true,
                        label: ""
                    },
                    {
                        icon: "system-lock-screen",
                        label: I18n.tr("Lock Screen"),
                        cmd: "lock",
                        enabled: sessionReady
                    },
                    {
                        icon: "system-suspend",
                        label: I18n.tr("Sleep"),
                        cmd: "suspend",
                        enabled: sessionReady && ControlCenterService.canSuspend
                    }
                ]
            },
            {
                icon: "arrow-down",
                label: I18n.tr("Collapse"),
                cmd: "collapse"
            }
        ]);
        menu.show();
    }

    Rectangle {
        anchors.fill: parent
        visible: !root.menuOpen
        radius: 8
        color: (pointer.containsMouse || root.menuOpen) ? Qt.rgba(root.color.r, root.color.g, root.color.b, 0.16) : "transparent"
    }

    BundledIcon {
        anchors.centerIn: parent
        visible: !root.menuOpen
        size: root.size + 2
        name: "sber"
        color: root.color
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (menu.visible)
                menu.dismissTopLevel();
            else
                root.openMenu();
        }
    }

    ContextMenu {
        id: menu
        anchorItem: root.menuAnchorItem || root
        iconOnlyRoot: true
        sideBySideSubmenu: true
        iconMenuWidth: 72
        iconMenuItemHeight: 48
        macosPopupMotion: false
        customAnchorEdges: Edges.Bottom | Edges.Left
        customGravity: Edges.Top | Edges.Right
        customMargins: ({
                top: 0,
                bottom: 0,
                left: 0,
                right: 0
            })
        anchor.adjustment: PopupAdjustment.SlideX
        globalDismissGraceMs: 250
        onAction: function (cmd, item) {
            if (cmd === "settings")
                DesktopAppLauncher.openSettings();
            else if (cmd === "terminal")
                AppActionService.launchById(item.desktopId);
            else if (cmd === "launch")
                AppActionService.launchById(item.desktopId);
            else if (cmd === "lock")
                ControlCenterService.lockSession();
            else if (cmd === "suspend")
                ControlCenterService.suspendSystem();
            else if (cmd === "reboot" || cmd === "poweroff" || cmd === "logout") {
                // Let ContextMenu finish its click dispatch before presenting
                // the existing control-center confirmation dialog.
                Qt.callLater(function () {
                    ControlCenterService.requestSessionAction(cmd);
                });
            }
        }
    }
}
