import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Core
import Sber.Theme


T.MenuItem {
    id: control

    property alias lineHeight: textLabel.lineHeight
    property alias captionText: captionLabel.text
    property int checkState: Qt.Unchecked
    property bool highlight: true

    implicitWidth: Math.max(contentItem.implicitWidth + leftPadding + rightPadding +
                            (arrow.visible ? arrow.width + spacing : 0),
                            ListView.view.width)
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding

    property bool tight: false
    verticalPadding: tight ?
                         lineHeight <= Theme.Sizes.LineHeight.Xs ? 5 :
                         lineHeight <= Theme.Sizes.LineHeight.S  ? 7 :
                         lineHeight <= Theme.Sizes.LineHeight.M  ? 10 :
                                                                   13 :
                         lineHeight <= Theme.Sizes.LineHeight.Xs ? 9 :
                         lineHeight <= Theme.Sizes.LineHeight.S  ? 11 :
                         lineHeight <= Theme.Sizes.LineHeight.M  ? 14 :
                                                                   17
    horizontalPadding: lineHeight <= Theme.Sizes.LineHeight.Xs ? 8 :
                       lineHeight <= Theme.Sizes.LineHeight.S  ? 12 :
                       lineHeight <= Theme.Sizes.LineHeight.M  ? 14 :
                                                                 16
    leftPadding: horizontalPadding + (indicator.visible ? indicator.width + spacing : 0)
    rightPadding: horizontalPadding
    topPadding: verticalPadding
    bottomPadding: verticalPadding
    spacing: 6
    opacity: enabled ? 1 : 0.4

    arrow: Icon {
        x: control.width - width - control.horizontalPadding
        y: textLabel.y + (textLabel.height - height) / 2
        size: indicator.size
        visible: control.subMenu
        color: Theme.Palette.Text.Default.Tertiary
        name: "ChevronRight"
    }

    indicator: Icon {
        x: control.horizontalPadding
        y: contentItem.y + (textLabel.height - height) / 2
        width: size
        height: size
        opacity: name != "" ? 1 : 0

        name: control.checkable ?
                  control.checkState == Qt.Checked ? "DoneSquareFill" :
                  control.checkState == Qt.PartiallyChecked ? "MinusSquareFill" :
                  "SquareOutline" :
              control.highlight && control.highlighted ?
                  "Done" :
              ""

        lineHeight: control.lineHeight
        size: control.lineHeight <= Theme.Sizes.LineHeight.S ? 22 :
              control.lineHeight == Theme.Sizes.LineHeight.M ? 26 :
                                                               30
        color: control.checkable ? colorizerIcon.currentColor : Theme.Palette.Surface.Default.Accent

        Colorizer {
            id: colorizerIcon
            defaultColor: control.checkState != Qt.Unchecked ? Theme.Palette.Surface.Default.Accent :
                                                               Theme.Palette.Text.Default.Secondary

            hovered: control.enabled && control.hovered
            hoverColor: control.checkState != Qt.Unchecked ? Theme.Palette.Surface.Default.AccentHover :
                                                             Theme.Palette.Text.Default.Secondary
            activated: control.checkState != Qt.Unchecked
            activeColor: Theme.Palette.Surface.Default.Accent
        }
    }

    contentItem: Item {
        implicitWidth: Math.max(textLabel.width, captionLabel.width)
        implicitHeight: textLabel.height +
                        (captionLabel.visible ? captionLabel.height + captionLabel.anchors.topMargin : 0)
        IconLabel {
            id: textLabel
            anchors.top: parent.top
            anchors.left: parent.left
            text: control.text
            lineHeight: Core.Settings.LineHeight
            icon.source: control.icon.source
            icon.name: control.icon.name
        }
        Label {
            id: captionLabel
            anchors.top: textLabel.bottom
            anchors.topMargin: 2
            anchors.left: parent.left
            leftPadding: textLabel.leftPadding
            lineHeight: control.lineHeight
            secondary: true
            visible: captionLabel.text
        }
    }

    background: Rectangle {
        color: control.highlight && control.highlighted ? Theme.Palette.Background.Default.Quaternary : "transparent"
        radius: Theme.Sizes.BorderRadius.Xs
        border.width: control.focus ? 1.5 : 0
        border.color: Theme.Palette.Outline.Default.SolidSecondaryHover
    }
    onHoveredChanged: focus = hovered

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: false
        acceptedButtons: control.checkable ? Qt.LeftButton : Qt.NoButton
        onClicked: control.triggered()
    }
    Keys.onPressed: (event) => {
        if (checkable && event.key == Qt.Key_Space) {
            control.triggered();
            event.accepted = true;
        }
    }
    onTriggered: {
        if (checkable)
            checkState = (checkState == Qt.Checked ? Qt.Unchecked : Qt.Checked);
    }
}
