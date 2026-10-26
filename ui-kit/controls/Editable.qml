import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Core
import Sber.Theme

T.TextField {
    id: control

    property alias lineHeight: textConfig.lineHeight
    opacity: enabled ? 1 : 0.4
    font: textConfig.font
    color: textConfig.defaultColor
    implicitWidth: contentWidth + 6 + icon.width
    width: implicitWidth
    implicitHeight: lineHeight
    height: lineHeight
    topPadding: (lineHeight - contentHeight) / 2

    property QtObject textConfig: TextConfig {
        id: textConfig
    }

    background: Item {
        Icon {
            id: icon
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            lineHeight: control.lineHeight
            name: "EditFill"
            visible: control.enabled
        }
    }
    cursorDelegate: CursorDelegate {}

    DefaultTextMenu {
        id: contextMenu
    }
    function onMenuToggled(event) {
        if (event.button == Qt.RightButton) {
            contextMenu.showContextMenu(event.x, event.y);
        }
    }
    onReleased: event => {
        onMenuToggled(event);
    }
    onPressAndHold: event => {
        onMenuToggled(event);
    }

    function closeEvent(event) {
        if (event)
            event.accept = true;
        control.focus = false;
        control.accepted();
    }

    Keys.onReturnPressed: function (event) {
        closeEvent(event);
    }
    Keys.onEnterPressed: function (event) {
        closeEvent(event);
    }
    Keys.onEscapePressed: function (event) {
        closeEvent(event);
    }
}
