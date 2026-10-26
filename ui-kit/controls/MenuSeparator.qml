import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Core
import Sber.Theme

T.MenuSeparator {
    id: control
    property int lineHeight: Core.Settings.LineHeight

    implicitWidth: ListView.view.width
    implicitHeight: implicitContentHeight + topPadding + bottomPadding

    topPadding: 6
    bottomPadding: 6
    horizontalPadding: lineHeight <= Theme.Sizes.LineHeight.Xs ? 8 : lineHeight <= Theme.Sizes.LineHeight.S ? 12 : lineHeight <= Theme.Sizes.LineHeight.M ? 14 : 16
    leftPadding: horizontalPadding
    rightPadding: horizontalPadding

    contentItem: Divider {}
}
