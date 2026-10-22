import QtQuick
import org.kde.kirigami as Kirigami
import Sber.Controls as Sber
import Sber.Theme
import SircaShell

Window {
    id: menu
    title: qsTr("Sber menu")
    color: "transparent"
    flags: Qt.FramelessWindowHint
    visible: false
    onClosing: event => { event.accepted = false; closeAll(); }
    x: Screen.virtualX
    y: Screen.virtualY
    width: Screen.width
    height: Screen.height
    property bool setupDone: false
    property bool dryRun: false
    property rect anchor: Qt.rect(8, height - 68, 60, 60)
    property string child: ""
    property int currentIndex: -1
    property int childOrigin: -1
    property bool childFromKeyboard: false
    property string terminalId: ""
    readonly property real cellSize: anchor.height
    readonly property rect menuRect: Qt.rect(Math.max(8, Math.min(width - cellSize - 8, anchor.x)),
        Math.max(8, anchor.y + anchor.height - 4 * cellSize), cellSize, 4 * cellSize)
    readonly property var entries: [
        { icon: "preferences-system-symbolic", text: qsTr("Shell settings") },
        { icon: "utilities-terminal-symbolic", text: qsTr("Terminal") },
        { icon: "system-shutdown-symbolic", text: qsTr("Power and session") },
        { icon: "arrow-down-symbolic", text: qsTr("Collapse") }
    ]
    readonly property int pinnedIndex: {
        const list = Config.launchers;
        for (let i = 0; i < list.length; ++i)
            if (String(list[i]).replace(/^applications:\/*/, "") === terminalId) return i;
        return -1;
    }
    readonly property var contextItems: apps.applicationActions(terminalId).concat(terminalId !== "" ? [
        { name: "pin", text: pinnedIndex >= 0 ? qsTr("Unpin") : qsTr("Pin to applications panel"), icon: "window-pin-symbolic" }
    ] : [])
    readonly property rect childRect: Qt.rect(menuRect.x + menuRect.width + 8,
        Math.max(8, menuRect.y + menuRect.height - cellSize - childHeight),
        Math.min(300, width - menuRect.x - menuRect.width - 16), childHeight)
    readonly property real childHeight: child === "power" ? power.actions.length * 44 + 16 : Math.max(1, contextItems.length) * 44 + 16
    signal closed()
    signal settingsRequested()
    signal actionInvoked(string actionId)
    AppsModel { id: apps }
    PowerMenu {
        id: power
        dryRun: menu.dryRun
        onActionInvoked: actionId => { menu.closeAll(); menu.actionInvoked(actionId); }
    }
    readonly property var powerActions: power

    function openAt(targetScreen, rect) {
        if (visible) closeAll();
        if (!screen || screen.name !== targetScreen.name) { screen = targetScreen; setupDone = false; }
        anchor = rect;
        terminalId = Shell.terminalDesktopId();
        child = ""; currentIndex = -1;
        if (!setupDone) { Shell.setupSearch(menu); setupDone = true; }
        visible = true;
        Shell.setKeyboardMode(menu, "exclusive");
        keys.forceActiveFocus();
    }
    function closeAll() {
        const wasVisible = visible;
        child = ""; currentIndex = -1;
        power.cancelPending();
        visible = false;
        Shell.setKeyboardMode(menu, "none");
        if (wasVisible) closed();
    }
    function closeChild() {
        if (child === "") return;
        child = ""; power.cancelPending();
        if (childFromKeyboard && childOrigin >= 0) {
            currentIndex = childOrigin;
            buttons.itemAt(currentIndex).forceActiveFocus(Qt.TabFocusReason);
        } else {
            currentIndex = -1;
            keys.forceActiveFocus();
        }
    }
    function openChild(name, index, keyboard) {
        if (child !== "") { closeChild(); return; }
        childOrigin = index; childFromKeyboard = keyboard;
        child = name;
        if (keyboard) Qt.callLater(() => childButtons.itemAt(0).forceActiveFocus(Qt.TabFocusReason));
    }
    function activate(index, keyboard) {
        if (child !== "") { closeChild(); return; }
        if (index === 2) { openChild("power", index, keyboard); return; }
        closeAll();
        if (index === 0) {
            actionInvoked("settings");
            settingsRequested();
        } else if (index === 1) {
            actionInvoked("terminal");
            if (!dryRun) Shell.runDetached(Shell.defaultTerminal(), []);
        }
    }
    function contextAction(name) {
        if (name === "pin") {
            const list = Config.launchers.slice();
            if (pinnedIndex >= 0) list.splice(pinnedIndex, 1);
            else list.push("applications:" + terminalId);
            Shell.saveConfigKey("launchers", list);
            closeChild();
        } else {
            closeAll();
            if (!dryRun) apps.launchAction(terminalId, name);
            actionInvoked("terminal-action:" + name);
        }
    }
    function handleKey(event) {
        if (event.key === Qt.Key_Escape) {
            if (child !== "") closeChild(); else closeAll();
        } else if (child !== "") {
            return;
        } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
            currentIndex = (currentIndex + 1) % 4;
            buttons.itemAt(currentIndex).forceActiveFocus(Qt.TabFocusReason);
        } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab) {
            currentIndex = currentIndex < 0 ? 3 : (currentIndex + 3) % 4;
            buttons.itemAt(currentIndex).forceActiveFocus(Qt.TabFocusReason);
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            if (currentIndex >= 0) activate(currentIndex, true);
        } else if (event.key === Qt.Key_Menu && currentIndex === 1 && terminalId !== "") {
            openChild("terminal", 1, true);
        } else return;
        event.accepted = true;
    }
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onPressed: {
            if (menu.child !== "") menu.closeChild();
            else menu.closeAll();
        }
        onWheel: event => { event.accepted = true; }
    }
    FocusScope {
        id: keys
        anchors.fill: parent
        Keys.onPressed: event => menu.handleKey(event)
        Rectangle {
            x: menu.menuRect.x; y: menu.menuRect.y
            width: menu.menuRect.width; height: menu.menuRect.height
            radius: 20
            color: Theme.Palette.Background.Default.Primary
            Column {
                anchors.fill: parent
                Repeater {
                    id: buttons
                    model: menu.entries
                    Sber.Button {
                        id: entry
                        required property int index
                        required property var modelData
                        width: menu.cellSize; height: menu.cellSize
                        focusPolicy: Qt.NoFocus
                        Accessible.name: modelData.text
                        backgroundType: Sber.Widget.Clear
                        background: Rectangle {
                            anchors.fill: parent; anchors.margins: 4
                            radius: Theme.Sizes.BorderRadius.S
                            color: entry.hovered || (menu.child !== "" && menu.childOrigin === entry.index) ? Theme.Palette.Background.Default.Secondary : Theme.Palette.Background.Default.Primary
                            border.width: entry.activeFocus ? 2 : 0
                            border.color: Theme.Palette.Surface.Default.Accent
                        }
                        contentItem: Item {
                            Kirigami.Icon {
                                anchors.centerIn: parent
                                width: 24; height: 24
                                source: entry.modelData.icon
                                isMask: true
                                color: Theme.Palette.Text.Default.Primary
                            }
                        }
                        Keys.onPressed: event => menu.handleKey(event)
                        onClicked: menu.activate(index, false)
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton
                            onClicked: {
                                if (menu.child !== "") menu.closeChild();
                                else if (entry.index === 1 && menu.terminalId !== "") menu.openChild("terminal", 1, false);
                            }
                        }
                        Sber.ToolTip.visible: hovered
                        Sber.ToolTip.text: modelData.text
                    }
                }
            }
        }
        Rectangle {
            visible: menu.child !== ""
            x: menu.childRect.x; y: menu.childRect.y
            width: menu.childRect.width; height: menu.childRect.height
            radius: 20
            color: Theme.Palette.Background.Default.Primary
            // Clicks in child padding belong to the child, not to the outside catcher.
            MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }
            Column {
                x: 8; y: 8; width: parent.width - 16
                Repeater {
                    id: childButtons
                    model: menu.child === "power" ? power.actions : menu.child === "terminal" ? menu.contextItems : []
                    Sber.Button {
                        required property int index
                        required property var modelData
                        width: parent.width; height: 44
                        backgroundType: Sber.Widget.Clear
                        text: menu.child === "power" ? (power.armed === modelData.id ? qsTr("Press again") : qsTranslate("PowerMenu", modelData.label)) : modelData.text
                        onClicked: {
                            if (menu.child === "power") power.activate(index);
                            else menu.contextAction(modelData.name);
                        }
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) { menu.closeChild(); event.accepted = true; }
                        }
                    }
                }
            }
        }
    }
}
