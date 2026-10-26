import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Core
import Sber.Theme

T.RadioButton {
    id: control

    property alias captionText: captionLabel.text
    property int lineHeight: Core.Settings.LineHeight
    property alias fontColor: textLabel.color
    property alias indicatorSize: indicator.width

    implicitWidth: indicator.width + spacing + textItem.implicitWidth
    width: implicitWidth
    implicitHeight: Math.max(indicator.height, textItem.implicitHeight)
    height: implicitHeight

    spacing: lineHeight <= Theme.Sizes.LineHeight.S ? 8 : lineHeight == Theme.Sizes.LineHeight.M ? 14 : 18
    opacity: control.enabled ? 1 : 0.4
    focusPolicy: Qt.TabFocus

    Colorizer {
        id: colorizer
        defaultColor: control.checked ? Theme.Palette.Surface.Default.Accent : Theme.Palette.Text.Default.Secondary
        hovered: control.enabled && control.hovered
        hoverColor: control.checked ? Theme.Palette.Surface.Default.AccentHover : Theme.Palette.Text.Default.SecondaryHover
    }

    contentItem: Item {
        id: textItem
        anchors.left: indicator.right
        anchors.leftMargin: control.spacing
        anchors.top: parent.top
        implicitWidth: Math.max(textLabel.implicitWidth, captionLabel.implicitWidth)
        implicitHeight: (textLabel.text ? textLabel.implicitHeight : 0) + (captionLabel.text ? captionLabel.implicitHeight + captionLabel.anchors.topMargin : 0)

        Label {
            id: textLabel
            y: indicator.height / 2 - textLabel.implicitHeight / 2
            anchors.left: parent.left
            text: control.text
            lineHeight: control.lineHeight
        }
        Label {
            id: captionLabel
            anchors.top: textLabel.bottom
            anchors.topMargin: 2
            anchors.left: parent.left
            text: control.captionText
            lineHeight: control.lineHeight
            secondary: true
        }
    }

    indicator: Rectangle {
        id: indicator
        anchors.top: control.top
        anchors.left: control.left
        width: lineHeight <= Theme.Sizes.LineHeight.S ? 16 : lineHeight == Theme.Sizes.LineHeight.M ? 20 : 24
        height: width
        radius: width / 2
        border.color: colorizer.currentColor
        color: control.checked ? Theme.Palette.Background.Default.Primary : "transparent"
        state: control.checked ? "checked" : "unchecked"
        states: [
            State {
                name: "checked"
                PropertyChanges {
                    target: indicator
                    border.width: lineHeight <= Theme.Sizes.LineHeight.S ? 3 : lineHeight <= Theme.Sizes.LineHeight.M ? 4 : 6
                }
            },
            State {
                name: "unchecked"
                PropertyChanges {
                    target: indicator
                    border.width: 2
                }
            }
        ]
        transitions: [
            Transition {
                from: "unchecked"
                to: "checked"
                PropertyAnimation {
                    property: "border.width"
                    duration: 300
                    easing.type: Easing.OutBack
                    easing.overshoot: 30.0
                }
            }
        ]
    }
    FocusItem {}
}
