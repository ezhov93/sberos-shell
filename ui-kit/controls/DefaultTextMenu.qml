import QtQuick
import QtQuick.Controls

import Sber.Controls


Menu {
    id: contextMenu

    Action {
        text: qsTr("Copy")
        enabled: contextMenu.parent.selectionStart >= 0 &&
                 contextMenu.parent.selectionStart != contextMenu.parent.selectionEnd
        onTriggered: contextMenu.parent.copy()
    }
    Action {
        text: qsTr("Cut")
        enabled: contextMenu.parent.selectionStart >= 0 &&
                 contextMenu.parent.selectionStart != contextMenu.parent.selectionEnd
        onTriggered: contextMenu.parent.cut()
    }
    Action {
        text: qsTr("Paste")
        enabled: contextMenu.parent.canPaste
        onTriggered: contextMenu.parent.paste()
    }
    MenuSeparator {}
    Action {
        text: qsTr("Undo")
        enabled: contextMenu.parent.canUndo
        onTriggered: contextMenu.parent.undo()
    }
    Action {
        text: qsTr("Redo")
        enabled: contextMenu.parent.canRedo
        onTriggered: contextMenu.parent.redo()
    }

    function showContextMenu(x, y) {
        if (!contextMenu.opened) {
            var selectStart = parent.selectionStart;
            var selectEnd = parent.selectionEnd;
            var curPos = parent.cursorPosition;
            contextMenu.x = x;
            contextMenu.y = y;
            contextMenu.open();
            parent.cursorPosition = curPos;
            parent.select(selectStart, selectEnd);
        }
    }
}
