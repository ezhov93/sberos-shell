import QtQuick
import SircaShell

Window {
    id: catcher
    required property var host
    required property var targetScreen
    screen: targetScreen
    x: targetScreen ? targetScreen.virtualX : 0
    y: targetScreen ? targetScreen.virtualY : 0
    property var panel: null
    property bool ready: false
    color: "transparent"
    flags: Qt.FramelessWindowHint
    width: Screen.width; height: Screen.height
    visible: ready && !!host && !!host.activeSberPanel && host.activeSberScreen !== targetScreen
    Component.onCompleted: { Shell.setupCatcher(catcher); ready = true; }
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onPressed: mouse => {
            const p = catcher.panel;
            if (p && !p.userHidden) {
                const r = p.sberRect;
                if (mouse.x >= p.x + r.x && mouse.x < p.x + r.x + r.width && mouse.y >= p.y + r.y && mouse.y < p.y + r.y + r.height) {
                    catcher.host.toggleSber(p, false);
                    return;
                }
            }
            const menu = catcher.host.win("sberMenu");
            if (menu.child !== "") menu.closeChild(); else menu.closeAll();
        }
        onWheel: event => { event.accepted = true; }
    }
}
