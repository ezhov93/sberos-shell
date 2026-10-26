import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Core
import Sber.Theme

T.TabButton {
    id: control

    property alias rightText: rightTextLabel.text
    property alias rightIcon: rightTextLabel.icon

    property TabBar parentBar

    property int lineHeight: parentBar ? parentBar.lineHeight : Core.Settings.LineHeight

    implicitWidth: contentItem.implicitWidth
    implicitHeight: contentItem.implicitHeight

    Colorizer {
        id: colorizer
        defaultColor: Theme.Palette.Text.Default.Secondary
        hovered: control.enabled && control.hovered && !control.pressed
        hoverColor: Theme.Palette.Text.Default.SecondaryHover
        activated: control.ListView.isCurrentItem
        activeColor: Theme.Palette.Text.Default.Primary
    }
    Colorizer {
        id: colorizerSecondary
        defaultColor: Theme.Palette.Text.Default.Tertiary
        hovered: control.enabled && control.hovered && !control.pressed
        hoverColor: Theme.Palette.Text.Default.TertiaryHover
        activated: control.ListView.isCurrentItem
        activeColor: Theme.Palette.Text.Default.Secondary
    }

    background: Rectangle {
        color: "transparent"
    }

    contentItem: Item {
        implicitWidth: content.implicitWidth
        implicitHeight: content.implicitHeight
        Item {
            id: content
            anchors.centerIn: parent
            implicitWidth: textLabel.width + (rightTextLabel.visible ? rightTextLabel.width + rightTextLabel.spacing : 0)
            implicitHeight: Math.max(textLabel.height, rightTextLabel.height)

            IconLabel {
                id: textLabel
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: control.text
                horizontalAlignment: Text.AlignRight
                bold: true
                lineHeight: control.lineHeight
                color: colorizer.currentColor
                opacity: enabled ? 1 : 0.4
                icon.source: control.icon.source
                icon.name: control.icon.name
            }

            IconLabel {
                id: rightTextLabel
                anchors.left: textLabel.right
                anchors.leftMargin: rightTextLabel.spacing
                anchors.verticalCenter: parent.verticalCenter
                bold: true
                font: textLabel.font
                lineHeight: control.lineHeight
                color: colorizerSecondary.currentColor
                opacity: enabled ? 1 : 0.4
                iconOnRight: true
            }
        }
    }
}
