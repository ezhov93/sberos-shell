import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Core
import Sber.Theme

T.CheckBox {
    id: control

    property string iconChecked: "DoneSquareFill"
    property string iconUnchecked: "SquareOutline"
    property string iconPartiallyChecked: "MinusSquareFill"

    property alias captionText: captionLabel.text
    property int lineHeight: Core.Settings.LineHeight
    property alias fontColor: textLabel.color
    property alias indicatorSize: indicator.size

    implicitWidth: indicator.width + spacing + textItem.implicitWidth
    width: implicitWidth
    implicitHeight: Math.max(indicator.height, textItem.implicitHeight)
    height: implicitHeight

    spacing: lineHeight <= Theme.Sizes.LineHeight.S ? 8 : lineHeight == Theme.Sizes.LineHeight.M ? 14 : 18
    opacity: enabled ? 1 : 0.4
    focusPolicy: Qt.TabFocus

    Colorizer {
        id: colorizer
        defaultColor: control.checkState != Qt.Unchecked ? Theme.Palette.Surface.Default.Accent : Theme.Palette.Text.Default.Secondary
        hovered: control.enabled && control.hovered
        hoverColor: control.checkState != Qt.Unchecked ? Theme.Palette.Surface.Default.AccentHover : Theme.Palette.Text.Default.SecondaryHover
        activated: control.pressed
        activeColor: control.checkState != Qt.Unchecked ? Theme.Palette.Surface.Default.AccentActive : Theme.Palette.Text.Default.SecondaryActive
    }

    contentItem: Item {
        id: textItem
        anchors.left: indicator.right
        anchors.leftMargin: control.spacing - 3
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

    indicator: Icon {
        id: indicator
        anchors.top: control.top
        anchors.left: control.left
        anchors.leftMargin: -3

        name: control.checkState === Qt.Checked ? control.iconChecked : control.checkState === Qt.PartiallyChecked ? control.iconPartiallyChecked : control.iconUnchecked
        size: control.lineHeight <= Theme.Sizes.LineHeight.S ? 22 : control.lineHeight == Theme.Sizes.LineHeight.M ? 26 : 30
        color: colorizer.currentColor
    }
    FocusItem {
        margin: 0
        radius: 4
    }
}
