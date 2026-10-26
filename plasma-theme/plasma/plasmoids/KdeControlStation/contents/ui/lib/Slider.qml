import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents2
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Card {
    id: sliderComp
    signal moved
    signal clicked
    signal togglePage

    property alias title: title.text
    property alias secondaryTitle: secondaryTitle.text
    property alias value: slider.value
    property bool useIconButton: false
    property string source

    property bool canTogglePage: false

    property bool showTitle: true
    property bool thinSlider: false
    property bool quickSettingsStyle: false

    property int from: 0
    property int to: 100

    property color highlightColor: root.useSystemColorsOnSliders ? root.themeHighlightColor : root.slidersColor

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: sliderComp.togglePage()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: quickSettingsStyle ? 0 : root.largeSpacing
        clip: true
        spacing: quickSettingsStyle ? 0 : 1

        RowLayout {
            Layout.fillHeight: !quickSettingsStyle
            Layout.fillWidth: true
            Layout.preferredHeight: quickSettingsStyle ? 28 * root.scale : -1
            spacing: 1
            visible: showTitle

            PlasmaComponents.Label {
                id: title
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
                font.pixelSize: quickSettingsStyle ? 14 * root.scale : root.largeFontSize
                font.weight: quickSettingsStyle ? Font.Medium : Font.Bold
                font.capitalization: Font.Capitalize
                elide: Text.ElideRight
                color: quickSettingsStyle ? "#484c5b" : Kirigami.Theme.textColor
            }

            PlasmaComponents.Label {
                id: secondaryTitle
                visible: root.showPercentage
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                font.pixelSize: root.largeFontSize
                font.weight: Font.Bold
                font.capitalization: Font.Capitalize
                horizontalAlignment: Text.AlignRight
                color: quickSettingsStyle ? "#9296a6" : Kirigami.Theme.textColor
            }


        }
        RowLayout {
            Layout.fillHeight: !quickSettingsStyle
            Layout.fillWidth: true
            Layout.preferredHeight: quickSettingsStyle ? 40 * root.scale : -1
            spacing: 0

            Kirigami.Icon {
                id: icon
                source: sliderComp.source
                visible: !sliderComp.useIconButton
                color: quickSettingsStyle ? "#484c5b" : Kirigami.Theme.textColor
                Layout.preferredHeight: quickSettingsStyle ? 24 * root.scale : root.largeFontSize * 2
                Layout.preferredWidth: Layout.preferredHeight
                Layout.margins: 0
                Layout.leftMargin: quickSettingsStyle ? 8 * root.scale : 0
            }

            PlasmaComponents2.ToolButton {
                id: iconButton
                visible: sliderComp.useIconButton
                icon.name: sliderComp.source
                icon.color: quickSettingsStyle ? "#484c5b" : Kirigami.Theme.textColor
                Layout.preferredHeight: quickSettingsStyle ? 24 * root.scale : root.largeFontSize * 2
                Layout.preferredWidth: Layout.preferredHeight
                flat: quickSettingsStyle
                onClicked: sliderComp.clicked()
            }

            Slider {
                id: slider
                Layout.fillWidth: true
                Layout.margins: 0
                Layout.leftMargin: quickSettingsStyle ? 24 * root.scale : 0
                from: sliderComp.from
                to: sliderComp.to
                stepSize: 2
                snapMode: Slider.SnapAlways

                background: Rectangle {
                    x: slider.leftPadding
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: quickSettingsStyle ? 16 * root.scale : thinSlider ? 7 : 22
                    width: slider.availableWidth
                    height: quickSettingsStyle ? 16 * root.scale : parent.height
                    radius: height / 2
                    color: quickSettingsStyle
                        ? Qt.rgba(148 / 255, 154 / 255, 170 / 255, 0.5)
                        : root.disabledBgColor
                    border.width: quickSettingsStyle ? 0 : 1
                    border.color: root.isDarkTheme ? root.disabledBgColor : Qt.rgba(0, 0, 0, 0.27)

                    Rectangle {
                        id: levelIndicator
                        width: (value - from) / (to - from) * (slider.width - handle.width) + (handle.width)
                        height: parent.height - 2
                        color: quickSettingsStyle ? "white" : highlightColor
                        radius: height / 2
                        border.width: 0
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                handle: Rectangle {
                    id: handle
                    x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth: quickSettingsStyle ? 16 * root.scale : thinSlider ? 17 : levelIndicator.height
                    implicitHeight: quickSettingsStyle ? 16 * root.scale : thinSlider ? 17 : levelIndicator.height
                    radius: height / 2
                    color: slider.pressed ? "#f0f0f0" : "#f6f6f6"
                    border.width: quickSettingsStyle ? 0 : 1
                    border.color: "#bdbebf"
                }

                onMoved: {
                    sliderComp.moved()
                }
            }

            PlasmaComponents2.ToolButton {
                id: openVolumePageButton
                visible: sliderComp.canTogglePage
                icon.name: "arrow-right"
                icon.color: quickSettingsStyle ? "#9296a6" : Kirigami.Theme.textColor
                Layout.preferredHeight: quickSettingsStyle ? 24 * root.scale : root.largeFontSize * 2
                Layout.preferredWidth: Layout.preferredHeight
                flat: quickSettingsStyle
                onClicked: sliderComp.togglePage()
            }
        }
    }
}
