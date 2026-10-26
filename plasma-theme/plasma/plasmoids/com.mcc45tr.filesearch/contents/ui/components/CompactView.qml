import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami

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
    required property int panelRadius
    required property int panelHeight
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

    readonly property bool oskaMode: compactRoot.isExtraWideMode

    // Signals
    signal toggleExpanded()

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
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: compactRoot.panelHeight > 0 ? compactRoot.panelHeight : parent.height
        radius: compactRoot.oskaMode ? 24 : (compactRoot.panelRadius === 0 ? height / 2 : (compactRoot.panelRadius === 1 ? 12 : (compactRoot.panelRadius === 2 ? 6 : 0)))
        color: compactRoot.oskaMode ? "#b8f7f9fb" : Qt.rgba(compactRoot.bgColor.r, compactRoot.bgColor.g, compactRoot.bgColor.b, 0.95)
        visible: !compactRoot.isButtonMode

        border.width: 1
        border.color: compactRoot.expanded ? compactRoot.accentColor : (compactRoot.oskaMode ? "#85ffffff" : Qt.rgba(compactRoot.textColor.r, compactRoot.textColor.g, compactRoot.textColor.b, 0.1))

        Rectangle {
            anchors.fill: parent
            anchors.margins: 7
            radius: 17
            color: compactRoot.oskaMode ? "#ebffffff" : "transparent"
            visible: compactRoot.oskaMode
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: compactRoot.oskaMode ? 16 : ((compactRoot.isWideMode || compactRoot.isExtraWideMode || compactRoot.isUltraWideMode) ? 10 : 0)
            anchors.rightMargin: compactRoot.oskaMode ? 16 : ((compactRoot.isWideMode || compactRoot.isExtraWideMode || compactRoot.isUltraWideMode) ? (compactRoot.showSearchButton ? 4 : 10) : 0)
            spacing: compactRoot.oskaMode ? 12 : 6

            Image {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                source: Qt.resolvedUrl("../../assets/oska-avatar.svg")
                sourceSize: Qt.size(40, 40)
                fillMode: Image.PreserveAspectFit
                visible: compactRoot.oskaMode && compactRoot.searchTextLength === 0
                Accessible.ignored: true
            }

            Text {
                id: displayText
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: compactRoot.oskaMode && compactRoot.searchTextLength === 0
                    ? i18nd("plasma_applet_com.mcc45tr.filesearch", "Найду документ или приложение")
                    : compactRoot.truncatedText
                color: compactRoot.oskaMode ? "#6d7e92" : compactRoot.textColor
                font.pixelSize: compactRoot.oskaMode ? 16 : compactRoot.responsiveFontSize
                font.family: compactRoot.oskaMode ? Kirigami.Theme.defaultFont.family : "Roboto Condensed"
                horizontalAlignment: (compactRoot.isWideMode || compactRoot.isExtraWideMode || compactRoot.isUltraWideMode) ? Text.AlignLeft : Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                visible: compactRoot.searchTextLength > 0 || compactRoot.oskaMode
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

        // Click handler - opens popup
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onEntered: mainButton.color = compactRoot.oskaMode ? "#d6f7f9fb" : Qt.rgba(compactRoot.bgColor.r, compactRoot.bgColor.g, compactRoot.bgColor.b, 1.0)
            onExited: mainButton.color = compactRoot.oskaMode ? "#b8f7f9fb" : Qt.rgba(compactRoot.bgColor.r, compactRoot.bgColor.g, compactRoot.bgColor.b, 0.95)

            onClicked: compactRoot.toggleExpanded()
        }
    }

}
