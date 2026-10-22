import QtQuick

import Sber.Controls
import Sber.Theme


Badge {
    id: control

    property int count: 0
    property int maxCount: 100
    circle: true

    text: count > maxCount ? maxCount + "+" : count
}
