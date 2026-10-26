import QtQuick

// Quick Settings range input styled directly from the Smart Panel mock.
Item {
    id: root

    implicitWidth: 240
    implicitHeight: 40
    property real value: 0
    property string accessibleName: ""
    property color accentColor: "#ffffff"
    property color trackColor: "#949aaa80"
    property real wheelStep: 0.01
    property bool _pressed: false
    property bool _hovered: false
    readonly property real visualValue: Math.max(0, Math.min(1, value))
    readonly property real edgeInset: 8
    readonly property real travel: Math.max(1, width - edgeInset * 2)
    readonly property real thumbCenterX: edgeInset + visualValue * travel

    signal previewChanged(real value)
    signal commitRequested(real value)
    signal canceled

    activeFocusOnTab: true
    Accessible.role: Accessible.Slider
    Accessible.name: root.accessibleName

    function positionForPointer(pointerX) {
        return Math.max(0, Math.min(1, (pointerX - edgeInset) / travel));
    }

    function cancelInteraction() {
        if (!_pressed)
            return;
        _pressed = false;
        canceled();
    }
    onEnabledChanged: {
        if (!enabled)
            cancelInteraction();
    }
    onVisibleChanged: {
        if (!visible)
            cancelInteraction();
    }

    Keys.onPressed: event => {
        let next = visualValue;
        if (event.key === Qt.Key_Left || event.key === Qt.Key_Down)
            next = Math.max(0, visualValue - wheelStep);
        else if (event.key === Qt.Key_Right || event.key === Qt.Key_Up)
            next = Math.min(1, visualValue + wheelStep);
        else if (event.key === Qt.Key_Home)
            next = 0;
        else if (event.key === Qt.Key_End)
            next = 1;
        else
            return;
        previewChanged(next);
        commitRequested(next);
        event.accepted = true;
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -3
        radius: 6
        color: "#14a996"
        opacity: root.activeFocus ? 0.75 : 0
    }

    Rectangle {
        id: rail
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 16
        radius: 8
        color: root.trackColor

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: root.visualValue * parent.width
            radius: parent.radius
            color: root.accentColor
        }
    }

    Rectangle {
        x: root.thumbCenterX - width / 2
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16
        radius: 8
        color: root.accentColor
        border.width: 1
        border.color: "#1e384d18"
        scale: root._pressed ? 1.08 : 1
        Behavior on scale {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutCubic
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root._hovered = true
        onExited: root._hovered = false
        onPressed: mouse => {
            root.forceActiveFocus();
            root._pressed = true;
            root.previewChanged(root.positionForPointer(mouse.x));
        }
        onPositionChanged: mouse => {
            if (pressed)
                root.previewChanged(root.positionForPointer(mouse.x));
        }
        onReleased: {
            if (!root._pressed)
                return;
            root._pressed = false;
            root.commitRequested(root.value);
        }
        onCanceled: root.cancelInteraction()
    }
}
