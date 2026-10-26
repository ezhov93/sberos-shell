import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import SircaShell

Item {
    id: root
    anchors.fill: parent
    visible: !Shell.plasmaRunning || Config.ownWallpaper === true
    enabled: visible

    property var screen: null
    readonly property string output: screen ? screen.name : ""
    readonly property int iconSize: DesktopFiles.iconSize
    readonly property int spacing: DesktopFiles.iconSpacing
    readonly property int cellWidth: iconSize + spacing + 30
    readonly property int cellHeight: iconSize + spacing + 48
    readonly property int columns: Math.max(1, Math.floor((width - 24) / cellWidth))
    property var entries: []
    property string selectedPath: ""
    property string dialogAction: ""
    property var dialogEntry: null
    property string errorMessage: ""
    signal pressedAnywhere

    function reload() {
        if (output)
            entries = DesktopFiles.entriesForOutput(output);
    }
    function screenAt(x, y) {
        const screens = Qt.application.screens;
        for (let i = 0; i < screens.length; ++i) {
            const candidate = screens[i];
            if (x >= candidate.virtualX && x < candidate.virtualX + candidate.width && y >= candidate.virtualY && y < candidate.virtualY + candidate.height)
                return candidate;
        }
        return screen;
    }
    function slotAt(targetScreen, x, y) {
        const columns = Math.max(1, Math.floor((targetScreen.width - 24) / cellWidth));
        const column = Math.max(0, Math.min(columns - 1, Math.floor((x - targetScreen.virtualX - 12) / cellWidth)));
        const row = Math.max(0, Math.floor((y - targetScreen.virtualY - 12) / cellHeight));
        return row * columns + column;
    }
    function configure() {
        const outputs = Qt.application.screens.map(function (s) {
            return s.name;
        });
        DesktopFiles.configureOutputs(outputs, Shell.primaryScreenName);
        reload();
    }
    function beginDialog(action, entry) {
        dialogAction = action;
        dialogEntry = entry || null;
        nameField.text = entry ? entry.name : "";
        nameDialog.title = action === "folder" ? "New Folder" : "Rename";
        nameDialog.open();
        nameField.forceActiveFocus();
        nameField.selectAll();
    }
    function commitDialog() {
        if (dialogAction === "folder")
            DesktopFiles.createFolder(nameField.text);
        else if (dialogEntry)
            DesktopFiles.renameEntry(dialogEntry.path, nameField.text);
        nameDialog.close();
    }

    Connections {
        target: DesktopFiles
        function onChanged() {
            root.reload();
        }
        function onPresentationChanged() {
            root.reload();
        }
        function onOperationFailed(message) {
            root.errorMessage = message;
            errorTimer.restart();
        }
    }
    Connections {
        target: Qt.application
        function onScreensChanged() {
            root.configure();
        }
    }
    Component.onCompleted: configure()
    Timer {
        id: errorTimer
        interval: 4000
        onTriggered: root.errorMessage = ""
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: mouse => {
            root.pressedAnywhere();
            if (mouse.button === Qt.RightButton)
                backgroundMenu.popup(mouse.x, mouse.y);
            else
                root.selectedPath = "";
        }
    }

    Repeater {
        model: root.entries
        delegate: Item {
            id: tile
            required property var modelData
            readonly property int slot: modelData.slot
            x: 12 + (slot % root.columns) * root.cellWidth
            y: 12 + Math.floor(slot / root.columns) * root.cellHeight
            width: root.cellWidth
            height: root.cellHeight

            Rectangle {
                anchors.fill: parent
                anchors.margins: 2
                radius: 12
                color: root.selectedPath === tile.modelData.path ? Config.fg(0.17) : "transparent"
                border.width: root.selectedPath === tile.modelData.path ? 1 : 0
                border.color: Config.fg(0.32)
            }
            Kirigami.Icon {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 6
                width: root.iconSize
                height: root.iconSize
                source: tile.modelData.icon || (tile.modelData.isDirectory ? "folder" : "text-x-generic")
                smooth: true
            }
            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: root.iconSize + 12
                anchors.leftMargin: 3
                anchors.rightMargin: 3
                height: 38
                text: tile.modelData.name
                color: Config.ink
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignTop
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onPressed: mouse => {
                    root.pressedAnywhere();
                    root.selectedPath = tile.modelData.path;
                    if (mouse.button === Qt.RightButton)
                        itemMenu.popup(mouse.x, mouse.y);
                }
                onDoubleClicked: DesktopFiles.openEntry(tile.modelData.path)
            }
            DragHandler {
                target: tile
                onActiveChanged: {
                    if (!active && root.screen) {
                        const globalX = root.screen.virtualX + tile.x + tile.width / 2;
                        const globalY = root.screen.virtualY + tile.y + tile.height / 2;
                        const targetScreen = root.screenAt(globalX, globalY);
                        DesktopFiles.moveEntry(tile.modelData.path, targetScreen.name, root.slotAt(targetScreen, globalX, globalY));
                    }
                }
            }
            Menu {
                id: itemMenu
                MenuItem {
                    text: "Open"
                    onTriggered: DesktopFiles.openEntry(tile.modelData.path)
                }
                MenuItem {
                    text: "Rename…"
                    onTriggered: root.beginDialog("rename", tile.modelData)
                }
                MenuItem {
                    text: "Move to Trash"
                    onTriggered: DesktopFiles.trashEntry(tile.modelData.path)
                }
            }
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 22
        width: Math.min(root.width - 32, errorLabel.implicitWidth + 32)
        height: errorMessage ? 42 : 0
        radius: 14
        color: Config.popSurface
        visible: errorMessage !== ""
        Text {
            id: errorLabel
            anchors.centerIn: parent
            text: root.errorMessage
            color: Config.ink
            font.pixelSize: 13
        }
    }

    Menu {
        id: backgroundMenu
        MenuItem {
            text: "New Folder…"
            onTriggered: root.beginDialog("folder", null)
        }
        Menu {
            title: "Arrange By"
            MenuItem {
                text: "Manual"
                checkable: true
                checked: DesktopFiles.sortMode === "manual"
                onTriggered: DesktopFiles.setSortMode("manual")
            }
            MenuItem {
                text: "Name"
                checkable: true
                checked: DesktopFiles.sortMode === "name"
                onTriggered: DesktopFiles.setSortMode("name")
            }
            MenuItem {
                text: "Type"
                checkable: true
                checked: DesktopFiles.sortMode === "type"
                onTriggered: DesktopFiles.setSortMode("type")
            }
        }
        Menu {
            title: "Icon Size"
            MenuItem {
                text: "Small"
                checkable: true
                checked: root.iconSize === 48
                onTriggered: DesktopFiles.setIconSize(48)
            }
            MenuItem {
                text: "Medium"
                checkable: true
                checked: root.iconSize === 64
                onTriggered: DesktopFiles.setIconSize(64)
            }
            MenuItem {
                text: "Large"
                checkable: true
                checked: root.iconSize === 80
                onTriggered: DesktopFiles.setIconSize(80)
            }
        }
        Menu {
            title: "Icon Spacing"
            MenuItem {
                text: "Comfortable"
                checkable: true
                checked: root.spacing === 24
                onTriggered: DesktopFiles.setIconSpacing(24)
            }
            MenuItem {
                text: "Compact"
                checkable: true
                checked: root.spacing === 16
                onTriggered: DesktopFiles.setIconSpacing(16)
            }
            MenuItem {
                text: "Dense"
                checkable: true
                checked: root.spacing === 12
                onTriggered: DesktopFiles.setIconSpacing(12)
            }
        }
        MenuItem {
            text: "Open Desktop Folder"
            onTriggered: DesktopFiles.openEntry(DesktopFiles.directory)
        }
    }

    Dialog {
        id: nameDialog
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        x: Math.max(12, (root.width - width) / 2)
        y: Math.max(12, (root.height - height) / 2)
        contentItem: TextField {
            id: nameField
            implicitWidth: 280
            onAccepted: root.commitDialog()
        }
        onAccepted: root.commitDialog()
    }
}
