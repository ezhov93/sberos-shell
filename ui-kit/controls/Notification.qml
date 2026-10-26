import QtQuick
import QtQuick.Layouts

import Sber.Controls
import Sber.Core
import Sber.Theme

Rectangle {
    id: control

    property alias lineHeight: backgroundConfig.lineHeight
    property int margin: 12
    property int spacing: 12

    property alias title: title.text
    property alias text: text.text
    property alias icon: icon
    property alias closable: closeButton.visible
    property alias timeout: timer.interval

    implicitWidth: Math.max(content.implicitWidth, 240) + margin * 2
    width: implicitWidth
    implicitHeight: content.implicitHeight + margin * 2
    height: implicitHeight
    visible: false

    color: Theme.Palette.Background.Inverse.Tertiary
    radius: backgroundConfig.radius

    property BackgroundConfig backgroundConfig: BackgroundConfig {
        id: backgroundConfig
    }

    Timer {
        id: timer
        interval: 10000
        running: !closable
        repeat: false
        onTriggered: destroyAnimation.start()
    }

    RowLayout {
        id: content
        anchors.fill: parent
        anchors.margins: control.margin
        spacing: control.spacing

        Icon {
            id: icon
            lineHeight: control.lineHeight
            color: Theme.Palette.Text.Inverse.Primary
        }

        Column {
            Layout.fillWidth: true
            spacing: 4

            Label {
                id: title
                Layout.fillWidth: true
                lineHeight: control.lineHeight
                visible: text != ""
                bold: true
                color: Theme.Palette.Text.Inverse.Primary
            }
            Label {
                id: text
                Layout.fillWidth: true
                lineHeight: control.lineHeight
                visible: text != ""
                color: Theme.Palette.Text.Inverse.Primary
            }
        }

        IconButton {
            id: closeButton
            type: Widget.Default
            backgroundType: Widget.Clear
            lineHeight: control.lineHeight
            icon.name: "Close"
            iconItem.color: Theme.Palette.Text.Inverse.Primary
            visible: false
            onReleased: destroyAnimation.start()
        }
    }

    Component.onCompleted: {
        control.x = control.width + 100;
        control.visible = true;
        createAnimation.start();
    }

    SequentialAnimation {
        id: createAnimation
        NumberAnimation {
            target: control
            property: "x"
            to: 0
            duration: 500
            easing.type: Easing.InOutQuint
        }
    }
    SequentialAnimation {
        id: destroyAnimation
        NumberAnimation {
            target: control
            property: "x"
            to: width + 100
            duration: 500
            easing.type: Easing.InOutQuint
        }
        ScriptAction {
            script: control.destroy()
        }
    }
}
