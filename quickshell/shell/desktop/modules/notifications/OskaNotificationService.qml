pragma Singleton
import QtQuick

// Short-lived Oska banner for the most recently accepted system notification.
QtObject {
    id: service

    property bool active: false
    property string summary: ""
    property string appIcon: ""
    property string desktopEntry: ""
    property string eventIcon: ""

    function present(notification) {
        summary = String(notification?.summary || "").trim();
        appIcon = String(notification?.appIcon || "");
        desktopEntry = String(notification?.desktopEntry || "");
        eventIcon = String(notification?.image || notification?.iconName || "");
        active = summary.length > 0;
        dismissTimer.restart();
    }

    function dismiss() {
        dismissTimer.stop();
        active = false;
    }

    property Timer dismissTimer: Timer {
        id: dismissTimer
        interval: 3500
        onTriggered: service.active = false
    }
}
