import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import ".."
import org.kde.plasma.workspace.keyboardlayout as Keyboard

// Compact panel representation for the File Search widget
Item {
    id: compactRoot

    // Required properties from parent
    required property bool isButtonMode
    required property bool isWideMode
    required property bool isExtraWideMode
    required property bool expanded
    required property string truncatedText
    required property int responsiveFontSize
    required property color bgColor
    required property color textColor
    required property color accentColor
    required property int searchTextLength
    required property string searchText
    property bool searchActive: false
    property Item searchPopupHost: null
    required property int panelRadius
    required property bool showSearchButton
    required property bool showSearchButtonBackground
    // New properties for animated ticker
    property var logic: null
    property bool rssPlaceholderCycling: true
    property bool rssShowFullHeadline: true
    property int rssFrequency: 3
    property bool rssShowSource: true
    property bool isUltraWideMode: false
    required property int maxChars

    readonly property SmartPanelTheme smartTheme: SmartPanelTheme {}
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: qsTr("Поиск документов и приложений")
    Keys.onReturnPressed: compactRoot.toggleExpanded()
    Keys.onSpacePressed: compactRoot.toggleExpanded()

    readonly property bool oskaMode: compactRoot.isExtraWideMode

    Keyboard.KeyboardLayout { id: keyboardLayout }

    // Signals
    signal toggleExpanded()
    signal openNotifications()
    signal searchTextEdited(string text)
    signal searchCleared()
    signal queryAccepted()
    property int notificationCount: 0

    onExpandedChanged: {
        if (!expanded) compactRoot.searchCleared();
    }
    onSearchPopupHostChanged: if (searchPopupHost) Qt.callLater(focusSearch)
    function focusSearch() {
        if (!searchActive || !searchPopupHost) return;
        searchInput.forceActiveFocus();
        searchInput.Window.window?.requestActivate();
    }
    Connections {
        target: searchInput.Window.window ?? null
        function onActiveChanged() {
            if (searchInput.Window.window?.active && compactRoot.searchActive)
                Qt.callLater(() => compactRoot.focusSearch());
        }
    }

    // Button Mode - icon only (no background)
    Kirigami.Icon {
        id: buttonModeIcon
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height)
        height: width
        source: "plasma-search"
        color: compactRoot.textColor
        visible: compactRoot.isButtonMode

        MouseArea {
            anchors.fill: parent
            anchors.margins: -8
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onEntered: buttonModeIcon.color = compactRoot.accentColor
            onExited: buttonModeIcon.color = compactRoot.textColor

            onClicked: compactRoot.toggleExpanded()
        }
    }



    // Main Button Container (for non-button modes)
    Rectangle {
        id: mainButton
        // Share the popup's keyboard window while keeping the island's screen position.
        parent: compactRoot.searchPopupHost ?? compactRoot
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        radius: compactRoot.oskaMode ? height / 3 : (compactRoot.panelRadius === 0 ? height / 2 : (compactRoot.panelRadius === 1 ? 12 : (compactRoot.panelRadius === 2 ? 6 : 0)))
        color: compactRoot.oskaMode ? smartTheme.shell : Qt.rgba(compactRoot.bgColor.r, compactRoot.bgColor.g, compactRoot.bgColor.b, 0.95)
        visible: !compactRoot.isButtonMode

        border.color: compactRoot.activeFocus ? smartTheme.focus : smartTheme.edge
        border.width: compactRoot.activeFocus ? 2 : 1

        Rectangle {
            anchors.fill: parent
            anchors.margins: Math.min(7, mainButton.height * 7 / 72)
            radius: Math.max(0, mainButton.radius - mainButton.height * 7 / 72)
            color: compactRoot.oskaMode ? (searchMouse.pressed ? smartTheme.pressed : searchMouse.containsMouse || compactRoot.expanded ? smartTheme.hover : smartTheme.inner) : "transparent"
            visible: compactRoot.oskaMode
        }

        RowLayout {
            z: 1
            anchors.fill: parent
            anchors.leftMargin: compactRoot.oskaMode ? mainButton.height * 16 / 72 : ((compactRoot.isWideMode || compactRoot.isExtraWideMode || compactRoot.isUltraWideMode) ? 10 : 0)
            anchors.rightMargin: compactRoot.oskaMode ? mainButton.height * 16 / 72 : ((compactRoot.isWideMode || compactRoot.isExtraWideMode || compactRoot.isUltraWideMode) ? (compactRoot.showSearchButton ? 4 : 10) : 0)
            spacing: compactRoot.oskaMode ? mainButton.height / 6 : 6

            Button {
                id: notificationsButton
                Layout.preferredWidth: Math.max(0, mainButton.height * 40 / 72)
                Layout.minimumWidth: Layout.preferredWidth
                Layout.maximumWidth: Layout.preferredWidth
                Layout.preferredHeight: Layout.preferredWidth
                padding: 0
                visible: compactRoot.oskaMode
                Accessible.name: qsTr("Уведомления: %1").arg(compactRoot.notificationCount)
                onClicked: compactRoot.openNotifications()
                contentItem: OskaAvatar {}
                background: Rectangle {
                    radius: width / 2
                    color: "transparent"
                    border.width: notificationsButton.visualFocus ? 2 : 0
                    border.color: smartTheme.focus
                }
                Rectangle {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    width: Math.max(16, badgeText.implicitWidth + 6)
                    height: 16
                    radius: 8
                    color: "#f12f55"
                    border.width: 1
                    border.color: "white"
                    visible: compactRoot.notificationCount > 0
                    Text {
                        id: badgeText
                        anchors.centerIn: parent
                        text: compactRoot.notificationCount > 99 ? "99+" : String(compactRoot.notificationCount)
                        color: "white"
                        font.pixelSize: 10
                    }
                }
            }

            Text {
                id: displayText
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: compactRoot.oskaMode && compactRoot.searchTextLength === 0
                    ? i18nd("plasma_applet_com.mcc45tr.filesearch", "Найду документ или приложение")
                    : compactRoot.truncatedText
                color: compactRoot.oskaMode ? smartTheme.searchText : compactRoot.textColor
                font.pixelSize: compactRoot.responsiveFontSize
                font.family: compactRoot.oskaMode ? Kirigami.Theme.defaultFont.family : "Roboto Condensed"
                horizontalAlignment: (compactRoot.isWideMode || compactRoot.isExtraWideMode || compactRoot.isUltraWideMode) ? Text.AlignLeft : Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                visible: (compactRoot.searchTextLength > 0 || compactRoot.oskaMode) && !searchInput.visible
            }

            TextField {
                id: searchInput
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                visible: compactRoot.oskaMode && compactRoot.searchActive
                text: compactRoot.searchText
                placeholderText: qsTr("Найду документ или приложение")
                Accessible.name: qsTr("Поиск документов и приложений")
                color: compactRoot.smartTheme.foreground
                placeholderTextColor: compactRoot.smartTheme.searchText
                font.pixelSize: 16
                leftPadding: 0
                rightPadding: 0
                background: Item {}
                onTextEdited: compactRoot.searchTextEdited(text)
                onAccepted: compactRoot.queryAccepted()
                Keys.onEscapePressed: event => {
                    compactRoot.toggleExpanded();
                    event.accepted = true;
                }
            }

            RssTicker {
                id: tickerContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: !compactRoot.isButtonMode && compactRoot.searchTextLength === 0 && !compactRoot.oskaMode

                logic: compactRoot.logic
                rssFrequency: compactRoot.rssFrequency
                rssPlaceholderCycling: compactRoot.rssPlaceholderCycling
                rssShowFullHeadline: compactRoot.rssShowFullHeadline
                rssShowSource: compactRoot.rssShowSource
                maxChars: compactRoot.maxChars

                textColor: compactRoot.textColor
                fontSize: compactRoot.responsiveFontSize
                fontFamily: "Roboto Condensed"
                defaultText: (compactRoot.isExtraWideMode || compactRoot.isUltraWideMode) ? i18nd("plasma_applet_com.mcc45tr.filesearch", "Start searching...") : (compactRoot.isWideMode ? i18nd("plasma_applet_com.mcc45tr.filesearch", "Search...") : i18nd("plasma_applet_com.mcc45tr.filesearch", "Search"))
                horizontalAlignment: (compactRoot.isWideMode || compactRoot.isExtraWideMode || compactRoot.isUltraWideMode) ? Text.AlignLeft : Text.AlignHCenter

                rightMarginValue: 0
                textOpacity: 0.35
                isSearching: compactRoot.searchTextLength > 0
            }

            Button {
                id: layoutButton
                visible: compactRoot.oskaMode
                enabled: keyboardLayout.layoutsList.length > 0
                Layout.preferredWidth: implicitContentWidth + 6
                Layout.minimumWidth: Layout.preferredWidth
                Layout.maximumWidth: Layout.preferredWidth
                Layout.preferredHeight: 18
                padding: 2
                text: keyboardLayout.layout >= 0 && keyboardLayout.layoutsList.length > keyboardLayout.layout
                    ? keyboardLayout.layoutsList[keyboardLayout.layout].shortName.toLocaleUpperCase() : "—"
                Accessible.name: enabled ? qsTr("Переключить раскладку клавиатуры: %1").arg(text)
                    : qsTr("Раскладка клавиатуры недоступна")
                onClicked: keyboardLayout.switchToNextLayout()
                contentItem: Text {
                    text: layoutButton.text
                    font.pixelSize: 11
                    color: smartTheme.foreground
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: 2
                    color: layoutButton.hovered ? smartTheme.hover : "transparent"
                    border.width: 1
                    border.color: layoutButton.visualFocus ? smartTheme.focus : smartTheme.foreground
                }
            }

            Rectangle {
                id: searchIconButton
                Layout.preferredWidth: ((compactRoot.isWideMode || compactRoot.isExtraWideMode || compactRoot.isUltraWideMode) && compactRoot.showSearchButton) ? (mainButton.height - 6) : 0
                Layout.preferredHeight: mainButton.height - 6
                Layout.alignment: Qt.AlignVCenter
                radius: compactRoot.panelRadius === 0 ? width / 2 : (compactRoot.panelRadius === 1 ? 8 : (compactRoot.panelRadius === 2 ? 4 : 0))
                color: compactRoot.showSearchButtonBackground ? compactRoot.accentColor : "transparent"
                visible: (compactRoot.isWideMode || compactRoot.isExtraWideMode || compactRoot.isUltraWideMode) && compactRoot.showSearchButton && !compactRoot.oskaMode

                Behavior on Layout.preferredWidth { NumberAnimation { duration: 200 } }

                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: parent.width * 0.55
                    height: width
                    source: "search"
                    color: compactRoot.showSearchButtonBackground ? "#ffffff" : compactRoot.textColor
                }
            }
        }

        // The label follows the popup input; no imperative palette assignments.
        MouseArea {
            id: searchMouse
            anchors.fill: parent
            enabled: !searchInput.visible
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true


            onClicked: compactRoot.toggleExpanded()
        }
    }

}
