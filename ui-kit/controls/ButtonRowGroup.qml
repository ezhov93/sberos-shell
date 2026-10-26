import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Theme

Row {
    id: row
    property int cornersType: Widget.Square
    onPositioningComplete: {
        for (var i = 0; i < row.children.length; ++i) {
            if (row.children[i] instanceof Button) {
                if (i == 0) {
                    row.children[i].leftCornersType = cornersType;
                    row.children[i].rightCornersType = Widget.Flat;
                } else if (i == row.children.length - 1) {
                    row.children[i].leftCornersType = Widget.Flat;
                    row.children[i].rightCornersType = cornersType;
                } else {
                    row.children[i].leftCornersType = Widget.Flat;
                    row.children[i].rightCornersType = Widget.Flat;
                }
            }
        }
    }
}
