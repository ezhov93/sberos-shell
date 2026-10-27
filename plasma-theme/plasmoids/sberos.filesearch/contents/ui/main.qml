import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import "components" as Components
import org.kde.notificationmanager as NotificationManager

PlasmoidItem {
    id: root

    // ===== CORE PROPERTIES =====
    property string searchText: ""
    property alias logic: controller
    property bool notificationsOpen: false
    readonly property bool editingSmartSearch: isExtraWideMode && expanded && !notificationsOpen
    property bool searchFocusSettling: false
    onExpandedChanged: {
        if (!expanded) {
            notificationsOpen = false
            searchFocusSettling = false
            searchFocusGuard.stop()
        } else if (editingSmartSearch) {
            searchFocusSettling = true
            searchFocusGuard.restart()
        }
    }
    Timer {
        id: searchFocusGuard
        interval: 600
        onTriggered: root.searchFocusSettling = false
    }
    NotificationManager.Notifications {
        id: notificationModel
        showExpired: true
        showDismissed: false
        showJobs: false
        groupMode: NotificationManager.Notifications.GroupDisabled
        sortMode: NotificationManager.Notifications.SortByDate
    }

    function notificationIndexForId(notificationId) {
        for (let row = 0; row < notificationModel.count; row++) {
            const index = notificationModel.index(row, 0)
            if (Number(notificationModel.data(index, NotificationManager.Notifications.IdRole))
                    === Number(notificationId)) {
                return index
            }
        }
        return undefined
    }

    function closeNotification(notificationId) {
        const index = notificationIndexForId(notificationId)
        if (index) notificationModel.close(index)
    }

    function clearNotifications() {
        notificationModel.clear(NotificationManager.Notifications.ClearExpired)
        for (let row = notificationModel.count - 1; row >= 0; row--) {
            const index = notificationModel.index(row, 0)
            if (notificationModel.data(index, NotificationManager.Notifications.TypeRole)
                    === NotificationManager.Notifications.NotificationType) {
                notificationModel.close(index)
            }
        }
    }
    function openNotifications() {
        if (root.expanded && root.notificationsOpen) root.expanded = false;
        else {
            root.notificationsOpen = true;
            notificationModel.lastRead = new Date();
            root.expanded = true;
        }
    }

    // Responsive font size based on height (40% of panel height)
    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property real panelExtent: Math.max(1, vertical ? width : height)
    readonly property int responsiveFontSize: Math.max(1, Math.round(panelExtent * 2 / 9))

    // ===== PANEL DETECTION =====
    // Check if widget is in a panel (horizontal or vertical)
    // FormFactor: 0=Planar (Desktop), 1=Horizontal, 2=Vertical, 3=Application
    readonly property bool isInPanel: Plasmoid.formFactor === PlasmaCore.Types.Horizontal ||
                                       Plasmoid.formFactor === PlasmaCore.Types.Vertical

    // ===== DISPLAY MODE CONFIGURATION =====
    // 0 = Button, 1 = Medium, 2 = Wide, 3 = Extra Wide
    // If not in panel, force button mode
    readonly property int configDisplayMode: Plasmoid.configuration.displayMode
    readonly property int displayMode: isInPanel ? configDisplayMode : 0
    readonly property bool isButtonMode: displayMode === 0 || !isInPanel
    readonly property bool isMediumMode: isInPanel && displayMode === 1
    readonly property bool isWideMode: isInPanel && displayMode === 2
    readonly property bool isExtraWideMode: isInPanel && displayMode === 3
    readonly property bool isUltraWideMode: isInPanel && displayMode === 4

    // ===== LAYOUT CALCULATIONS =====
    readonly property real textContentWidth: isButtonMode ? 0 : (textMetrics.width + ((isWideMode || isExtraWideMode || isUltraWideMode) ? (panelExtent + 30) : 20))
    readonly property real baseWidth: isButtonMode ? panelExtent : (isUltraWideMode ? panelExtent * 9 : (isExtraWideMode ? panelExtent * 456 / 72 : (isWideMode ? panelExtent * 4 : panelExtent * 70 / 72)))

    readonly property real preferredLength: Math.max(baseWidth, textContentWidth, placeholderContentWidth)
    Layout.preferredWidth: vertical ? 72 : preferredLength
    Layout.minimumWidth: vertical ? 0 : (isButtonMode ? panelExtent : panelExtent * 3)
    Layout.maximumWidth: vertical ? Infinity : preferredLength
    Layout.preferredHeight: vertical ? panelExtent : 72
    Layout.minimumHeight: vertical ? panelExtent : 0
    Layout.maximumHeight: vertical ? panelExtent : Infinity

    // Character limits
    readonly property int maxCharsWide: 65
    readonly property int maxCharsMedium: 35
    readonly property int maxCharsUltra: 110
    readonly property int maxChars: isUltraWideMode ? maxCharsUltra : (isWideMode ? maxCharsWide : maxCharsMedium)

    // Truncated text for display
    readonly property string placeholderText: (isExtraWideMode || isUltraWideMode) ? i18nd("plasma_applet_com.mcc45tr.filesearch", "Start searching...") : (isWideMode ? i18nd("plasma_applet_com.mcc45tr.filesearch", "Search...") : i18nd("plasma_applet_com.mcc45tr.filesearch", "Search"))
    readonly property string rawSearchText: searchText.length > 0 ? searchText : placeholderText
    readonly property string truncatedText: rawSearchText.length > maxChars ? rawSearchText.substring(0, maxChars) + "..." : rawSearchText

    TextMetrics {
        id: textMetrics
        font.family: "Roboto Condensed"
        font.pixelSize: root.responsiveFontSize
        text: root.truncatedText
    }

    TextMetrics {
        id: placeholderMetrics
        font.family: textMetrics.font.family
        font.pixelSize: textMetrics.font.pixelSize
        text: root.placeholderText
    }

    readonly property real placeholderContentWidth: isButtonMode ? 0 : (placeholderMetrics.width + ((isWideMode || isExtraWideMode || isUltraWideMode) ? (panelExtent + 30) : 20))

    // No background - transparent
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    // Prevent closing when interacting with external dialogs (like auth)
    property bool preventClosing: false
    hideOnWindowDeactivate: !preventClosing && !(editingSmartSearch && searchFocusSettling)

    // ===== VIEW MODE CONFIGURATION =====
    readonly property int viewMode: Plasmoid.configuration.viewMode
    readonly property bool isTileView: viewMode === 1

    // Icon sizes
    readonly property int iconSize: Math.max(16, Plasmoid.configuration.iconSize || 48)
    readonly property int listIconSize: Math.max(16, Plasmoid.configuration.listIconSize || 22)

    // ===== THEME COLORS =====
    readonly property color bgColor: Kirigami.Theme.backgroundColor
    readonly property color textColor: Kirigami.Theme.textColor
    readonly property color accentColor: Kirigami.Theme.highlightColor

    // ===== LOGIC CONTROLLER (Non-visual) =====
    Components.LogicController {
        id: controller
        plasmoidConfig: Plasmoid.configuration
    }

    // ===== LOCALIZATION =====
    // Localization removed
    // Use standard i18nd("plasma_applet_com.mcc45tr.filesearch", )

    // ===== CONTEXTUAL ACTIONS (Right-Click Menu) =====
    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18nd("plasma_applet_com.mcc45tr.filesearch", "Button Mode (Icon only)")
            checkable: true
            checked: root.displayMode === 0
            onTriggered: Plasmoid.configuration.displayMode = 0
        },
        PlasmaCore.Action {
            text: i18nd("plasma_applet_com.mcc45tr.filesearch", "Medium Mode (Button only)")
            checkable: true
            checked: root.displayMode === 1
            onTriggered: Plasmoid.configuration.displayMode = 1
        },
        PlasmaCore.Action {
            text: i18nd("plasma_applet_com.mcc45tr.filesearch", "Wide Mode (Search bar + icon)")
            checkable: true
            checked: root.displayMode === 2
            onTriggered: Plasmoid.configuration.displayMode = 2
        },
        PlasmaCore.Action {
            text: i18nd("plasma_applet_com.mcc45tr.filesearch", "Extra Wide Mode (Wide + Long Placeholder)")
            checkable: true
            checked: root.displayMode === 3
            onTriggered: Plasmoid.configuration.displayMode = 3
        },
        PlasmaCore.Action {
            text: i18nd("plasma_applet_com.mcc45tr.filesearch", "Ultra Wide Mode (Maximum Coverage)")
            checkable: true
            checked: root.displayMode === 4
            onTriggered: Plasmoid.configuration.displayMode = 4
        }
    ]

    // ===== COMPACT REPRESENTATION (Panel Widget) =====
    compactRepresentation: Components.CompactView {
        anchors.fill: parent

        isButtonMode: root.isButtonMode
        isWideMode: root.isWideMode
        isExtraWideMode: root.isExtraWideMode
        isUltraWideMode: root.isUltraWideMode
        expanded: root.expanded
        searchText: root.searchText
        searchActive: root.editingSmartSearch
        searchPopupHost: root.editingSmartSearch ? (root.fullRepresentationItem?.inputHost ?? null) : null
        truncatedText: root.truncatedText
        responsiveFontSize: root.responsiveFontSize
        maxChars: root.maxChars
        bgColor: root.bgColor
        textColor: root.textColor
        accentColor: root.accentColor
        searchTextLength: root.searchText.length
        panelRadius: Plasmoid.configuration.panelRadius
        showSearchButton: Plasmoid.configuration.showSearchButton
        showSearchButtonBackground: Plasmoid.configuration.showSearchButtonBackground

        logic: controller
        rssPlaceholderCycling: Plasmoid.configuration.rssPlaceholderCycling
        rssShowFullHeadline: Plasmoid.configuration.rssShowFullHeadline
        rssShowSource: Plasmoid.configuration.rssShowSource
        rssFrequency: Plasmoid.configuration.rssFrequency

        notificationCount: notificationModel.unreadNotificationsCount
        onOpenNotifications: root.openNotifications()
        onSearchTextEdited: text => root.searchText = text
        onSearchCleared: root.searchText = ""
        onQueryAccepted: {
            const popup = root.fullRepresentationItem;
            if (popup && popup.activateFirst) popup.activateFirst();
        }
        onToggleExpanded: {
            const closeSearch = root.expanded && !root.notificationsOpen;
            root.notificationsOpen = false;
            root.expanded = !closeSearch;
        }
    }

    // ===== FULL REPRESENTATION (Popup) =====
    fullRepresentation: root.isExtraWideMode ? smartPanelRepresentation : standardSearchRepresentation

    Component {
        id: smartPanelRepresentation
        FocusScope {
            id: panelPopup
            property alias inputHost: popupInputHost
            implicitWidth: 456
            implicitHeight: root.notificationsOpen ? 282 : 669
            Layout.minimumWidth: implicitWidth
            Layout.maximumWidth: implicitWidth
            Layout.preferredWidth: implicitWidth
            Layout.minimumHeight: implicitHeight
            Layout.maximumHeight: implicitHeight
            Layout.preferredHeight: implicitHeight
            SmartPopupPlacement {
                content: panelPopup
                anchorItem: root.compactRepresentationItem ?? root
                screenGeometry: Plasmoid.containment.screenGeometry
                overlapPanel: !root.notificationsOpen
                frameSource: root.notificationsOpen ? Qt.resolvedUrl("../assets/smart-panel/popup-frame.svg")
                    : Qt.resolvedUrl("../assets/smart-panel/search-popup-frame.svg")
                frameBorders: root.notificationsOpen ? KSvg.FrameSvg.AllBorders : 0
            }
            Loader {
                id: representationLoader
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: root.notificationsOpen ? parent.height : 589
                active: root.expanded
                sourceComponent: root.notificationsOpen ? notificationsRepresentation : smartSearchRepresentation
                onLoaded: {
                    if (root.notificationsOpen) {
                        item.forceActiveFocus();
                        panelPopup.Window.window?.requestActivate();
                    } else Qt.callLater(() => root.compactRepresentationItem.focusSearch());
                }
            }
            Item {
                id: popupInputHost
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 72
                visible: !root.notificationsOpen
            }
            Keys.onEscapePressed: root.expanded = false
            function activateFirst() {
                if (representationLoader.status !== Loader.Ready || !representationLoader.item
                        || !representationLoader.item.activateFirst) return;
                representationLoader.item.activateFirst();
            }
        }
    }

    Component {
        id: notificationsRepresentation
        Components.SmartNotificationsPopup {
            id: notificationPopup
            notifications: notificationModel
            serviceAvailable: NotificationManager.Server.valid
            onDismissed: root.expanded = false
            onCloseNotification: notificationId => root.closeNotification(notificationId)
            onActivateNotification: notificationId => {
                const index = root.notificationIndexForId(notificationId)
                if (index) notificationModel.invokeDefaultAction(index)
                root.expanded = false;
            }
            onClearRequested: root.clearNotifications()
        }
    }

    Component {
        id: smartSearchRepresentation
        Components.SmartSearchPopup {
            id: searchPopup
            searchQuery: root.searchText
            logic: controller
            onDismissed: root.expanded = false
        }
    }

    Component {
        id: standardSearchRepresentation
        Components.SearchPopup {
            id: popup
            logic: controller
            plasmoidConfig: Plasmoid.configuration

            // Data binding
            searchText: root.searchText
            expanded: root.expanded

            displayMode: root.displayMode
            viewMode: root.viewMode
            iconSize: root.iconSize
            listIconSize: root.listIconSize

            textColor: root.textColor
            accentColor: root.accentColor
            bgColor: root.bgColor

            // Pass panel status for styling decisions
            isInPanel: root.isInPanel


            showDebug: Plasmoid.configuration.debugOverlay && Plasmoid.configuration.userProfile === 1
            showBootOptions: Plasmoid.configuration.showBootOptions
            showPinnedBar: Plasmoid.configuration.showPinnedBar
            autoMinimizePinned: Plasmoid.configuration.autoMinimizePinned
            compactTileMode: Plasmoid.configuration.compactPinnedView
            previewEnabled: Plasmoid.configuration.previewEnabled
            previewShowResults: Plasmoid.configuration.previewShowResults !== undefined ? Plasmoid.configuration.previewShowResults : true
            previewShowHistory: Plasmoid.configuration.previewShowHistory !== undefined ? Plasmoid.configuration.previewShowHistory : true
            previewInlineMode: Plasmoid.configuration.previewInlineMode !== undefined ? Plasmoid.configuration.previewInlineMode : 1
            previewSize: Plasmoid.configuration.previewSize !== undefined ? Plasmoid.configuration.previewSize : 1
            previewSettings: {
                try {
                    return JSON.parse(Plasmoid.configuration.previewSettings || '{"images": false, "videos": false, "text": false, "documents": false, "applications": false}')
                } catch (e) {
                    return {"images": false, "videos": false, "text": false, "documents": false, "applications": false}
                }
            }

            // Signal handlers
            onRequestSearchTextUpdate: (text) => root.searchText = text
            onRequestExpandChange: (exp) => root.expanded = exp
            onRequestViewModeChange: (mode) => Plasmoid.configuration.viewMode = mode
            onRequestPreventClosing: (prevent) => root.preventClosing = prevent
        }
    }
}
