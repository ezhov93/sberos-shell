import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Sber.Controls
import Sber.Core
import Sber.Theme


Item {
    id: control

    default property alias data: itemContainer.data

    property int contentPadding: 16
    property alias contentSpacing: itemContainer.spacing
    property bool opened: false
    property bool arrow: false
    property bool hasBackground: false

    property alias title: titleText.text
    property alias titleFont: titleText.font
    property alias titleColor: titleText.color

    property int lineHeight: Core.Settings.LineHeight
    implicitHeight: mouseArea.height + (opened ? container.height : 0)
    height: implicitHeight
    implicitWidth: Math.max(titleLayout.implicitWidth,
                            itemContainer.implicitWidth + itemContainer.anchors.leftMargin
                                                        + itemContainer.anchors.rightMargin)
    width: implicitWidth
    property int horizontalPadding: control.lineHeight <= Theme.Sizes.LineHeight.S ? 12 :
                                    control.lineHeight <= Theme.Sizes.LineHeight.M ? 14 :
                                    control.lineHeight <= Theme.Sizes.LineHeight.L ? 18 :
                                                                                     20
    clip: true
    opacity: enabled ? 1 : 0.4

    property Colorizer colorizer: Colorizer {
        id: colorizer
        defaultColor: Theme.Palette.Outline.Default.SolidPrimary
        hovered: control.enabled && mouseArea.containsMouse
        hoverColor: Theme.Palette.Outline.Default.SolidPrimaryHover
        activated: mouseArea.containsPress
        activeColor: Theme.Palette.Outline.Default.SolidPrimaryActive
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: colorizer.borderWidth
        border.color: colorizer.currentColor
        visible: control.hasBackground
        radius: control.lineHeight <= Theme.Sizes.LineHeight.S ? 8 :
                control.lineHeight <= Theme.Sizes.LineHeight.M ? 10 :
                control.lineHeight <= Theme.Sizes.LineHeight.L ? 12 :
                                                                 14
        z: -1
    }

    MouseArea {
        id: mouseArea
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: control.lineHeight
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onPressed: {
            control.opened = !control.opened
        }

        RowLayout {
            id: titleLayout
            spacing: 8
            anchors.fill: parent
            anchors.leftMargin: control.horizontalPadding
            anchors.rightMargin: control.horizontalPadding
            layoutDirection: control.arrow ? Qt.RightToLeft : Qt.LeftToRight
            z: 1

            Label {
                id: titleText
                Layout.alignment: (control.arrow ? Qt.AlignRight : Qt.AlignLeft) | Qt.AlignVCenter
                Layout.fillWidth: true
            }
            Icon {
                id: arrowIcon
                name: arrow ? opened ? "DisclosureUpFill" : "DisclosureDownFill" :
                              opened ? "Minus" : "Plus"
                lineHeight: control.lineHeight
                size: control.lineHeight <= Theme.Sizes.LineHeight.Xs ? 12 :
                      control.lineHeight <= Theme.Sizes.LineHeight.S  ? 14 :
                      control.lineHeight <= Theme.Sizes.LineHeight.M  ? 16 :
                                                                        22
                color: Theme.Palette.Text.Default.Primary
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }
        }
    }

    Item {
        id: container
        anchors.top: mouseArea.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        clip: false

        ColumnLayout {
            id: itemContainer
            anchors.fill: parent
            anchors.topMargin: control.contentPadding
            anchors.bottomMargin: control.contentPadding
            anchors.leftMargin: control.horizontalPadding + (control.arrow ? arrowIcon.size + 6 : 0)
            anchors.rightMargin: control.horizontalPadding
            z: 1
            spacing: control.contentSpacing
            clip: true
        }
    }

    state: control.opened ? "opened" :
                            "closed"
    states: [
        State {
            name: "opened"
            PropertyChanges {
                target: control
                implicitHeight: mouseArea.height + container.height
            }
            PropertyChanges {
                target: container
                height: itemContainer.implicitHeight + control.contentPadding * 2
            }
        },
        State {
            name: "closed"
            PropertyChanges {
                target: control
                implicitHeight: mouseArea.height
            }
            PropertyChanges {
                target: container
                height: 0
            }
        }
    ]
    transitions: [
        Transition {
            from: "*"
            to: "*"
            PropertyAnimation {
                target: control
                property: "implicitHeight"
                duration: 200
                easing.type: Easing.InOutQuad
            }
            PropertyAnimation {
                target: container
                property: "height"
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    ]
}
