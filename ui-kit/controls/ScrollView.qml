import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Theme


T.ScrollView {
    id: sv
    leftPadding: 2
    rightPadding: 2
    topPadding: 2
    bottomPadding: 2

    ScrollBar.vertical: ScrollBar {
        x: sv.width - sv.rightPadding - width
        y: sv.topPadding
        height: sv.height - sv.topPadding - sv.bottomPadding - sv.ScrollBar.horizontal.height
    }
    ScrollBar.horizontal: ScrollBar {
        x: sv.leftPadding
        y: sv.height - sv.bottomPadding - height
        width: sv.width - sv.leftPadding - sv.rightPadding - sv.ScrollBar.vertical.width
    }
}
