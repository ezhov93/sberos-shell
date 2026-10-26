import QtQuick 2.15
import ".."
import QtQuick.Layouts 1.15
import org.kde.kirigami as Kirigami

Item {
    id: tile

    property string title
    property string subtitle
    property string iconName
    property bool active: false
    property bool available: true
    property bool actionable: available
    property bool hasSubpage: false
    property bool dark: root.smartTheme.dark
    property real uiScale: root.scale
    property color innerColor: dark ? "#2b323b" : Qt.rgba(1, 1, 1, 0.92)
    property color hoverColor: dark ? "#363e48" : "#ebedf2"
    property color foregroundColor: dark ? "#e5e8ed" : "#484c5b"
    property color mutedColor: dark ? "#959ba8" : "#9296a6"

    signal activated()

    Layout.fillWidth: true
    Layout.preferredHeight: 56 * uiScale
    implicitHeight: 56 * uiScale

    Accessible.role: Accessible.Button
    Accessible.name: title + ", " + subtitle
    Accessible.description: available ? "" : qsTr("Недоступно")
    activeFocusOnTab: actionable

    Rectangle {
        id: surface
        anchors.fill: parent
        radius: 17 * tile.uiScale
        color: hovered ? tile.hoverColor : tile.innerColor
        border.width: tile.activeFocus ? 2 : 1
        border.color: tile.activeFocus ? "#14a996" : tile.dark ? "#1affffff" : "#20ffffff"

        property bool hovered: false

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12 * tile.uiScale
            anchors.rightMargin: 12 * tile.uiScale
            spacing: 12 * tile.uiScale

            Rectangle {
                Layout.preferredWidth: 32 * tile.uiScale
                Layout.preferredHeight: 32 * tile.uiScale
                radius: width / 2
                color: tile.active && tile.available ? "#54b7b1" : tile.dark ? "#414a55" : "#e8eaf0"

                SmartPanelIcon {
                    anchors.centerIn: parent
                    width: 16 * tile.uiScale
                    height: 16 * tile.uiScale
                    source: tile.iconName
                    isMask: true
                    color: tile.active && tile.available ? "white" : tile.foregroundColor
                    opacity: tile.available ? 1 : 0.55
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: tile.title
                    color: tile.foregroundColor
                    font.family: "Ubuntu"
                    font.pixelSize: 16 * tile.uiScale
                    font.weight: Font.DemiBold
                    fontSizeMode: Text.HorizontalFit
                    minimumPixelSize: 14 * tile.uiScale
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: tile.subtitle
                    color: tile.mutedColor
                    font.family: "Ubuntu"
                    font.pixelSize: 12 * tile.uiScale
                    elide: Text.ElideRight
                }
            }

            SmartPanelIcon {
                visible: tile.hasSubpage
                Layout.preferredWidth: visible ? 18 * tile.uiScale : 0
                Layout.preferredHeight: visible ? 18 * tile.uiScale : 0
                source: Qt.resolvedUrl("../../assets/smart-panel/right.svg")
                isMask: true
                color: tile.mutedColor
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: tile.actionable
        hoverEnabled: true
        cursorShape: tile.actionable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onEntered: surface.hovered = true
        onExited: surface.hovered = false
        onClicked: tile.activated()
    }

    Keys.onReturnPressed: if (actionable) activated()
    Keys.onEnterPressed: if (actionable) activated()
    Keys.onSpacePressed: if (actionable) activated()
}
