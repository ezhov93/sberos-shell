import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Core
import Sber.Theme

T.Button {
    id: control

    property alias loading: loadingIndicator.visible
    property alias loadingPercent: loadingIndicator.loadingPercent

    property alias status: backgroundConfig.status
    property alias type: backgroundConfig.type
    property alias backgroundType: backgroundConfig.backgroundType

    property alias textItem: controlText
    property alias iconItem: controlText.icon

    property int radius: -1
    property int cornersType: Widget.Square
    property int leftCornersType: cornersType
    property int rightCornersType: cornersType
    property int topLeftRadius: -1
    property int topRightRadius: -1
    property int bottomLeftRadius: -1
    property int bottomRightRadius: -1

    property int lineHeight: Core.Settings.LineHeight
    implicitWidth: content.width + leftPadding + rightPadding
    implicitHeight: lineHeight
    horizontalPadding: backgroundConfig.horizontalPadding
    spacing: 8
    focusPolicy: Qt.TabFocus

    property BackgroundConfig backgroundConfig: BackgroundConfig {
        id: backgroundConfig
        lineHeight: control.lineHeight
        type: Widget.Default
    }
    property Colorizer colorizer: Colorizer {
        id: colorizer
        defaultColor: backgroundConfig.defaultColor
        hovered: control.enabled && control.hovered
        hoverColor: backgroundConfig.hoverColor
        activated: control.pressed
        activeColor: backgroundConfig.activeColor
    }

    property string clickTrackerName

    contentItem: Item {
        id: content
        anchors.centerIn: parent
        height: controlText.height
        width: controlText.width
        BusyIndicator {
            id: loadingIndicator
            anchors.centerIn: parent
            color: controlText.color
            visible: false
        }

        IconLabel {
            id: controlText
            anchors.centerIn: parent
            visible: !loadingIndicator.visible
            opacity: (control.backgroundType != Widget.Solid || control.type == Widget.Secondary || control.type == Widget.White) && !control.enabled ? 0.4 : 1
            text: control.text
            status: control.status
            type: control.type
            backgroundType: control.backgroundType
            lineHeight: control.lineHeight
            bold: true
            icon.source: control.icon.source
            icon.name: control.icon.name
            color: textColorizer.currentColor

            Colorizer {
                id: textColorizer
                defaultColor: controlText.textConfig.defaultColor
                hovered: control.enabled && control.hovered
                hoverColor: controlText.textConfig.hoverColor
                activated: control.pressed
                activeColor: controlText.textConfig.activeColor
            }
        }
    }

    background: Rectangle {
        id: bg
        anchors.fill: parent
        color: control.backgroundType == Widget.Outline ? "transparent" : colorizer.currentColor
        border.width: control.backgroundType == Widget.Outline ? colorizer.borderWidth : 0
        border.color: control.backgroundType == Widget.Outline ? textColorizer.currentColor : "transparent"
        opacity: control.enabled ? 1 : 0.4
        visible: control.backgroundType != Widget.Clear
        topLeftRadius: control.topLeftRadius !== -1 ? control.topLeftRadius : control.radius !== -1 ? control.radius : control.leftCornersType == Widget.Flat ? 0 : control.leftCornersType == Widget.Square ? backgroundConfig.radius : height / 2
        bottomLeftRadius: control.bottomLeftRadius !== -1 ? control.bottomLeftRadius : control.radius !== -1 ? control.radius : control.leftCornersType == Widget.Flat ? 0 : control.leftCornersType == Widget.Square ? backgroundConfig.radius : height / 2
        topRightRadius: control.topRightRadius !== -1 ? control.topRightRadius : control.radius !== -1 ? control.radius : control.rightCornersType == Widget.Flat ? 0 : control.rightCornersType == Widget.Square ? backgroundConfig.radius : height / 2
        bottomRightRadius: control.bottomRightRadius !== -1 ? control.bottomRightRadius : control.radius !== -1 ? control.radius : control.rightCornersType == Widget.Flat ? 0 : control.rightCornersType == Widget.Square ? backgroundConfig.radius : height / 2
    }

    FocusItem {}

    onClicked: {
        try {
            Core.ClickTracker.registerClick(control);
        } catch (e) {}
    }
}
