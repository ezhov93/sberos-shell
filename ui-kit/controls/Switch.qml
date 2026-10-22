import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Core
import Sber.Theme


T.Switch {
    id: control

    property alias captionText: captionLabel.text
    property alias fontColor: textLabel.color
    property int lineHeight: Core.Settings.LineHeight
    property int indicatorHeight: lineHeight <= Theme.Sizes.LineHeight.S ? 20 :
                                  lineHeight == Theme.Sizes.LineHeight.M ? 24 :
                                                                           28
    property int indicatorWidth: lineHeight <= Theme.Sizes.LineHeight.S ? 32 :
                                 lineHeight == Theme.Sizes.LineHeight.M ? 38 :
                                                                          44

    implicitWidth: bg.width + spacing + textLabel.implicitWidth
    width: implicitWidth
    implicitHeight: Math.max(bg.height, textItem.implicitHeight)
    height: implicitHeight

    spacing: 12
    verticalPadding: 2
    focusPolicy: Qt.TabFocus

    Colorizer {
        id: colorizer
        defaultColor: Theme.Palette.Surface.Default.TransparentSecondary
        hovered: control.enabled && control.hovered
        hoverColor: control.checked ? Theme.Palette.Surface.Default.AccentHover :
                                      Theme.Palette.Surface.Default.TransparentSecondaryHover
        activated: control.checked
        activeColor: Theme.Palette.Surface.Default.Accent
    }

    contentItem: Item {
        id: textItem
        anchors.left: parent.left
        anchors.top: parent.top
        implicitWidth: Math.max(textLabel.implicitWidth, captionLabel.implicitWidth)
        implicitHeight: (textLabel.text ? textLabel.implicitHeight : 0) +
                        (captionLabel.text ? captionLabel.implicitHeight + captionLabel.anchors.topMargin : 0)
        opacity: control.enabled ? 1 : 0.4

        Label {
            id: textLabel
            y: bg.height / 2 - textLabel.implicitHeight / 2
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
        id: bg
        anchors.top: control.top
        anchors.right: control.right
        height: control.indicatorHeight
        width: control.indicatorWidth
        radius: control.indicatorHeight / 2
        color: colorizer.currentColor
        opacity: control.enabled ? 1 : 0.4
    }
    FocusItem {}

    Rectangle {
        id: button  
        anchors.verticalCenter: bg.verticalCenter
        width: control.indicatorHeight - control.verticalPadding * 2
        height: button.width
        radius: button.width / 2
        color: Theme.Palette.Background.Light.Secondary

        state: control.checked ? "checked" :
                                 "unchecked"
        states: [
            State {
                name: "checked"
                PropertyChanges {
                    target: button
                    x: bg.x + bg.width - button.width - control.verticalPadding
                }
            },
            State {
                name: "unchecked"
                PropertyChanges {
                    target: button
                    x: bg.x + control.verticalPadding
                }
            }
        ]
        transitions: [
            Transition {
                from: "*"
                to: "*"
                PropertyAnimation {
                    property: "x"
                    duration: 300
                    easing.type: Easing.InOutQuint
                }
            }
        ]
    }
}
