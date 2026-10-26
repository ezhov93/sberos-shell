import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Theme

T.SwitchDelegate {
    id: control

    property alias lineHeight: content.lineHeight
    property alias captionText: content.captionText

    property bool highlightCurrent: true
    highlighted: highlightCurrent && ListView ? ListView.isCurrentItem : false

    implicitWidth: Math.max(contentItem.implicitWidth + leftPadding + rightPadding, ListView.view.width)
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding

    property bool tight: false
    verticalPadding: tight ? lineHeight <= Theme.Sizes.LineHeight.Xs ? 5 : lineHeight <= Theme.Sizes.LineHeight.S ? 7 : lineHeight <= Theme.Sizes.LineHeight.M ? 10 : 13 : lineHeight <= Theme.Sizes.LineHeight.Xs ? 9 : lineHeight <= Theme.Sizes.LineHeight.S ? 11 : lineHeight <= Theme.Sizes.LineHeight.M ? 14 : 17
    horizontalPadding: lineHeight <= Theme.Sizes.LineHeight.Xs ? 8 : lineHeight <= Theme.Sizes.LineHeight.S ? 12 : lineHeight <= Theme.Sizes.LineHeight.M ? 14 : 16
    leftPadding: horizontalPadding
    rightPadding: horizontalPadding
    topPadding: verticalPadding
    bottomPadding: verticalPadding

    contentItem: Switch {
        id: content
        text: control.text
        checked: control.checked
    }

    background: Rectangle {
        color: control.highlighted ? Theme.Palette.Background.Default.Quaternary : "transparent"
        radius: Theme.Sizes.BorderRadius.Xs
        border.width: control.focus ? 1.5 : 0
        border.color: Theme.Palette.Outline.Default.SolidSecondaryHover
    }
    onHoveredChanged: focus = hovered

    onClicked: {
        ListView.view.currentIndex = index;
    }
}
