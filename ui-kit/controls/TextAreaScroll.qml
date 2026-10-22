import QtQuick
import QtQuick.Controls

import Sber.Controls
import Sber.Theme


ScrollView {
    id: sv

    width: 350
    height: 250

    ScrollBar.vertical: ScrollBar {
        id: vScroll
        handleSize: 2
        x: sv.width - 2 - handleSize - width
        y: textArea.topPadding
        height: sv.height - textArea.topPadding - textArea.bottomPadding - sv.ScrollBar.horizontal.height
        policy: ScrollBar.AlwaysOn
        visible: sv.contentHeight > sv.height
    }
    ScrollBar.horizontal: ScrollBar {
        id: hScroll
        handleSize: 2
        x: textArea.leftPadding
        y: sv.height - textArea.bottomPadding - height
        width: sv.width - textArea.leftPadding - textArea.rightPadding - handleSize - sv.ScrollBar.vertical.width
        policy: ScrollBar.AlwaysOn
        visible: sv.contentWidth > sv.width
    }

    property alias textArea: ta
    TextArea {
        id: ta
        width: sv.width
        height: sv.height

        function scrollToCursor() {
            var cursor = ta.cursorRectangle;
            var cursor_x_pos = cursor.x + cursor.width;
            var cursor_y_pos = cursor.y + cursor.height;
            if (cursor_x_pos - ta.contentWidth * hScroll.position > sv.width - ta.rightPadding)
                hScroll.position = Math.min(1.0, (cursor_x_pos - ta.leftPadding - sv.width) / (ta.contentWidth + ta.leftPadding));
            if (cursor_y_pos - ta.contentHeight * vScroll.position > sv.height - ta.bottomPadding)
                vScroll.position = Math.min(1.0, (cursor_y_pos - ta.topPadding - sv.height) / (ta.contentHeight + ta.topPadding));
        }
        onCursorRectangleChanged: scrollToCursor()
    }
}
