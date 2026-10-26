import QtQuick
import QtQuick.Controls

import Sber.Controls as SberControls
import Sber.Core
import Sber.Theme

Item {
    id: root

    property int lineHeight: Core.Settings.LineHeight
    property int timeData: 0
    property int maxValue: 60
    property bool isNeedDropDown: true
    readonly property int iconsWidth: 40
    readonly property int iconsHeight: 40

    signal timePartDataChanged(int value)

    function incTimePart() {
        timeData = (timeData + 1) % maxValue;
        root.timePartDataChanged(timeData);
    }

    function decTimePart() {
        timeData = (timeData + maxValue - 1) % maxValue;
        root.timePartDataChanged(timeData);
    }

    SberControls.IconButton {
        id: incButton

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: root.iconsWidth
        height: root.iconsHeight
        backgroundType: Widget.Clear
        iconItem.name: "ChevronUp"

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
        onClicked: root.incTimePart()
    }
    SberControls.Label {
        id: dataLabel
        anchors.top: incButton.bottom
        lineHeight: root.lineHeight
        font: Theme.Fonts.DisplaySB
        horizontalAlignment: Text.AlignHCenter

        text: root.timeData.toString().padStart(2, '0')
        width: root.width
        height: 102
        bold: true

        MouseArea {
            anchors.fill: parent
            onClicked: if (root.isNeedDropDown)
                popup.open()
        }
    }
    SberControls.IconButton {
        id: decButton
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.iconsWidth
        height: root.iconsHeight
        backgroundType: Widget.Clear
        iconItem.name: "ChevronDown"
        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
        onClicked: root.decTimePart()
    }
    onActiveFocusChanged: {
        if (activeFocus && root.isNeedDropDown)
            popup.open();
        else
            popup.close();
    }
    SberControls.Popup {
        id: popup

        readonly property int maxNumbersShown: 5
        readonly property int delegateHeight: 56
        readonly property int delegateWidth: 88

        x: dataLabel.x
        y: decButton.y
        width: 100
        height: popup.delegateHeight * maxNumbersShown
        clip: true
        onOpened: scrollbar.position = Math.max((timeData - maxNumbersShown / 2), 0) / maxValue
        Flickable {
            anchors.fill: parent
            anchors.margins: 6
            contentHeight: popup.delegateHeight * maxValue
            ScrollBar.vertical: ScrollBar {
                id: scrollbar
            }
            Column {
                Repeater {
                    id: repeater
                    model: maxValue
                    SberControls.Button {
                        id: buttonDelegate

                        colorizer.hoverColor: Theme.Palette.Background.Default.Quaternary
                        backgroundConfig.defaultColor: popup.background.color
                        width: popup.delegateWidth
                        height: popup.delegateHeight
                        text: modelData
                        type: Widget.Secondary
                        backgroundType: Widget.Solid
                        textItem.font: Theme.Fonts.BodyLB
                        onClicked: {
                            popup.close();
                            root.timePartDataChanged(modelData);
                        }
                    }
                }
            }
        }
    }
}
