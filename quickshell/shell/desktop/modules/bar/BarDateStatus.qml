import Quickshell
import QtQuick
import "../../../shared/qml/i18n"
import qs.desktop.modules.common
import qs.desktop.modules.dock

// Reusable date/time cluster shared by the standalone top Bar and the
// bottom unified Dock host. It owns no layer-shell geometry.
Item {
    id: root

    signal activated(Item sourceItem)
    // The unified SberOS panel follows the compact date-and-time treatment in
    // the Smart Panel mock. The standalone Bar keeps its existing long date.
    property bool smartPanelFormat: false

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: I18n.tr("Open calendar")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Row {
        id: content
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        ThemeText {
            id: timeText
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, "h:mm")
            // With the mac-style ground on, the clock takes the strip's own
            // ink and the readability edge goes away with it.
            color: ThemeService.barInk
            renderType: Text.NativeRendering
            font {
                family: AppearanceTokens.typography.displayFamily
                pixelSize: 14
                weight: Font.Medium
            }
        }

        ThemeText {
            anchors.verticalCenter: parent.verticalCenter
            text: root.smartPanelFormat
                  ? Qt.locale().toString(clock.date, "ddd, d MMM") + " · " + Qt.locale().toString(clock.date, "HH:mm")
                  : I18n.fmt(clock.date, I18n.tr("dddd, MMMM d"))
            color: ThemeService.barInk
            renderType: Text.NativeRendering
            font {
                family: AppearanceTokens.typography.displayFamily
                pixelSize: 14
                weight: Font.Medium
            }
        }
    }

    TapHandler {
        onTapped: root.activated(root)
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            root.activated(root);
            event.accepted = true;
        }
    }
}
