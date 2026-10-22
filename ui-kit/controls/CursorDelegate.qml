import QtQuick
import QtQuick.Controls

import Sber.Controls
import Sber.Theme


Rectangle {
    id: cursor

    color: Theme.Palette.Text.Default.Accent
    width: 1
    visible: parent.activeFocus && !parent.readOnly && parent.selectionStart === parent.selectionEnd

    Connections {
        target: cursor.parent
        function onCursorPositionChanged() {
            cursor.opacity = 1
            timer.restart()
        }
    }

    Timer {
        id: timer
        running: cursor.parent.activeFocus && !cursor.parent.readOnly && interval != 0
        repeat: true
        interval: Qt.styleHints.cursorFlashTime
        onTriggered: cursor.opacity = !cursor.opacity ? 1 : 0
        onRunningChanged: cursor.opacity = 1
    }
}
