import QtQuick

// Brief, non-interactive feedback shared by Shell actions.
Rectangle {
    id: root

    property string message: ""
    property string iconName: "check"
    property int timeout: 1600
    property bool shown: false

    function show(text, icon) {
        message = text;
        iconName = icon || "check";
        shown = true;
        hold.restart();
    }
    function dismiss() {
        hold.stop();
        shown = false;
    }

    implicitWidth: content.implicitWidth + 28
    implicitHeight: 36
    width: implicitWidth
    height: implicitHeight
    radius: height / 2
    color: AppearanceTokens.surface.panelFill
    border.width: 1
    border.color: AppearanceTokens.surface.outline
    enabled: false
    visible: opacity > 0
    opacity: shown ? 1 : 0
    scale: shown ? 1 : 0.96
    Accessible.name: message
    Behavior on opacity {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }
    Behavior on scale {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 7
        BundledIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: root.iconName
            size: 15
            color: AppearanceTokens.colors.surfaceForeground
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.message
            color: AppearanceTokens.colors.surfaceForeground
            font.pixelSize: 12
            font.weight: Font.Medium
        }
    }
    Timer {
        id: hold
        interval: root.timeout
        onTriggered: root.shown = false
    }
}
