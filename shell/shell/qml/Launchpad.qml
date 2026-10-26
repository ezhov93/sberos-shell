import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import org.kde.kirigami as Kirigami
import SircaShell
import Sber.Theme

Window {
    id: root
    property var targetScreen: null
    property bool setupDone: false
    property bool focusArmed: false
    property bool selectionMoved: false
    property int currentPage: 0
    property int currentIndex: 0
    property string wallpaperPath: ""
    signal opened

    color: "transparent"
    flags: Qt.FramelessWindowHint
    visible: false
    screen: targetScreen
    width: targetScreen ? targetScreen.width : Screen.width
    height: targetScreen ? targetScreen.height : Screen.height

    AppsModel {
        id: apps
        namesOnly: true
        filter: searchField.text
    }

    readonly property int gridSpacing: 16
    readonly property int columns: Math.max(1, Math.min(8, Math.floor((gridArea.width + gridSpacing) / (168 + gridSpacing))))
    readonly property int rows: Math.max(1, Math.min(4, Math.floor((gridArea.height + 48) / (148 + 48))))
    readonly property int pageCapacity: columns * rows
    readonly property int pageCount: Math.max(1, Math.ceil(apps.count / pageCapacity))

    function openAt(screenForLaunchpad) {
        targetScreen = screenForLaunchpad || Qt.application.screens[0];
        screen = targetScreen;
        currentPage = 0;
        currentIndex = 0;
        selectionMoved = false;
        wallpaperPath = Shell.plasmaWallpaper();
        searchField.text = "";
        if (!setupDone) {
            Shell.setupSearch(root);
            setupDone = true;
        }
        visible = true;
        focusArmed = false;
        Shell.setKeyboardMode(root, "exclusive");
        searchField.forceActiveFocus();
        relaxFocus.restart();
        opened();
    }

    function close_() {
        if (!visible)
            return;
        visible = false;
        focusArmed = false;
        relaxFocus.stop();
        armFocus.stop();
        Shell.setKeyboardMode(root, "none");
        searchField.text = "";
    }

    function launchCurrent() {
        const id = apps.storageIdAt(currentPage * pageCapacity + currentIndex);
        if (id !== "")
            apps.launch(id);
        close_();
    }

    function moveSelection(delta) {
        const absolute = currentPage * pageCapacity + currentIndex + delta;
        if (absolute < 0 || absolute >= apps.count)
            return;
        currentPage = Math.floor(absolute / pageCapacity);
        currentIndex = absolute % pageCapacity;
        selectionMoved = true;
    }

    onActiveChanged: {
        if (visible && focusArmed && !active)
            lostFocus.restart();
        else
            lostFocus.stop();
    }
    onPageCapacityChanged: currentPage = Math.min(currentPage, pageCount - 1)
    onPageCountChanged: currentPage = Math.min(currentPage, pageCount - 1)
    Connections {
        target: apps
        function onCountChanged() {
            root.currentPage = 0;
            root.currentIndex = 0;
            root.selectionMoved = false;
        }
    }

    Timer {
        id: relaxFocus
        interval: 160
        onTriggered: {
            Shell.setKeyboardMode(root, "ondemand");
            armFocus.start();
        }
    }
    Timer {
        id: armFocus
        interval: 220
        onTriggered: root.focusArmed = true
    }
    Timer {
        id: lostFocus
        interval: 80
        onTriggered: if (root.visible && !root.active)
            root.close_()
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        source: root.wallpaperPath === "" ? "" : "file://" + root.wallpaperPath
        sourceSize: Qt.size(root.width, root.height)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
        visible: status === Image.Ready
    }

    MultiEffect {
        anchors.fill: parent
        source: wallpaper
        blurEnabled: true
        blur: 1.0
        blurMax: 26
        autoPaddingEnabled: false
        visible: wallpaper.status === Image.Ready
    }

    Rectangle {
        anchors.fill: parent
        color: "#32353e"
        opacity: 0.58
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: root.close_()
        }
    }

    Item {
        id: gridArea
        x: 0
        y: 124
        width: root.width
        height: Math.max(148, root.height - y - 220)
        Repeater {
            model: apps
            delegate: Item {
                id: appCell
                required property int index
                required property string name
                required property string icon
                required property string storageId
                readonly property int pageOffset: root.currentPage * root.pageCapacity
                visible: index >= pageOffset && index < pageOffset + root.pageCapacity
                width: 168
                height: 148
                x: Math.round((gridArea.width - (root.columns * width + (root.columns - 1) * root.gridSpacing)) / 2)
                    + ((index - pageOffset) % root.columns) * (width + root.gridSpacing)
                y: Math.floor((index - pageOffset) / root.columns) * 196
                readonly property bool selected: index - pageOffset === root.currentIndex

                Item {
                    id: tile
                    anchors.centerIn: parent
                    width: appCell.width
                    height: appCell.height
                    Rectangle {
                        anchors.fill: parent
                        radius: 16
                        color: appCell.selected && root.selectionMoved ? "#18ffffff" : "transparent"
                        border.width: appCell.selected && root.selectionMoved ? 1 : 0
                        border.color: "#35ffffff"
                    }
                }
                Kirigami.Icon {
                    id: appIcon
                    anchors.horizontalCenter: tile.horizontalCenter
                    anchors.top: tile.top
                    width: 120
                    height: width
                    source: appCell.icon
                    roundToIconSize: false
                }
                Text {
                    anchors.top: appIcon.bottom
                    anchors.topMargin: 10
                    anchors.horizontalCenter: tile.horizontalCenter
                    width: 144
                    text: appCell.name
                    color: "white"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    wrapMode: Text.NoWrap
                }
                HoverHandler {
                    onHoveredChanged: if (hovered) {
                        root.currentIndex = appCell.index - appCell.pageOffset
                        root.selectionMoved = true
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onPressed: mouse => {
                        if (mouse.button === Qt.RightButton)
                            appMenu.popup(mouse.x, mouse.y);
                    }
                    onClicked: mouse => {
                        if (mouse.button !== Qt.LeftButton)
                            return;
                        root.currentIndex = appCell.index - appCell.pageOffset;
                        root.launchCurrent();
                    }
                }
                Menu {
                    id: appMenu
                    MenuItem {
                        text: qsTr("Add to Desktop")
                        onTriggered: DesktopFiles.createApplicationShortcut(appCell.storageId)
                    }
                }
                Accessible.role: Accessible.Button
                Accessible.name: appCell.name
            }
        }
    }

    Text {
        anchors.centerIn: gridArea
        visible: apps.count === 0
        text: qsTr("Ничего не найдено")
        color: Theme.Palette.Text.Default.Secondary
        font.pixelSize: 14
    }

    Row {
        height: 12
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 160
        spacing: 12
        Repeater {
            model: root.pageCount > 1 ? root.pageCount : 0
            delegate: Rectangle {
                required property int index
                width: 12
                height: 12
                radius: 6
                color: index === root.currentPage ? "white" : "#939bab"
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    acceptedButtons: Qt.LeftButton
                    onClicked: {
                        root.currentPage = index;
                        root.currentIndex = 0;
                        searchField.forceActiveFocus();
                    }
                }
                Accessible.role: Accessible.Button
                Accessible.name: qsTr("Страница %1 из %2").arg(index + 1).arg(root.pageCount)
            }
        }
    }

    Rectangle {
        id: searchBox
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        width: 456
        height: 72
        radius: 24
        color: "#14ffffff"
        border.width: 1
        border.color: "#60ffffff"

        Rectangle {
            anchors.fill: parent
            anchors.margins: 7
            radius: 17
            color: "#d92b323b"
        }

        OskaAvatar {
            id: oskaAvatar
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            height: 40
            visible: searchField.text === ""
        }

        Kirigami.Icon {
            visible: searchField.text !== ""
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            width: 22
            height: 22
            source: "search-symbolic"
            isMask: true
            color: "#a5aebb"
        }
        TextInput {
            id: searchField
            anchors.left: parent.left
            anchors.leftMargin: searchField.text === "" ? 68 : 50
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
            selectionColor: "#60ffffff"
            selectedTextColor: "white"
            font.pixelSize: 16
            clip: true
            selectByMouse: true
            Accessible.name: qsTr("Поиск приложений")
            onTextChanged: {
                root.currentPage = 0;
                root.currentIndex = 0;
                root.selectionMoved = false;
            }
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    root.close_();
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    root.launchCurrent();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Down) {
                    root.moveSelection(root.columns);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Up) {
                    root.moveSelection(-root.columns);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Right && cursorPosition === text.length) {
                    root.moveSelection(1);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Left && cursorPosition === 0) {
                    root.moveSelection(-1);
                    event.accepted = true;
                } else if (event.key === Qt.Key_PageDown) {
                    root.currentPage = Math.min(root.pageCount - 1, root.currentPage + 1);
                    root.currentIndex = 0;
                    event.accepted = true;
                } else if (event.key === Qt.Key_PageUp) {
                    root.currentPage = Math.max(0, root.currentPage - 1);
                    root.currentIndex = 0;
                    event.accepted = true;
                }
            }
        }
        Text {
            anchors.left: searchField.left
            anchors.verticalCenter: parent.verticalCenter
            visible: searchField.text === ""
            text: qsTr("Какое приложение найти?")
            color: "#a5aebb"
            font.pixelSize: 16
        }
    }
}
