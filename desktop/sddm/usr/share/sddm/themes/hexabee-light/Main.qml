/*
 *   SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2
import Qt5Compat.GraphicalEffects

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.kirigami 2.20 as Kirigami

import org.kde.breeze.components

// TODO: Once SDDM 0.19 is released and we are setting the font size using the
// SDDM KCM's syncing feature, remove the `config.fontSize` overrides here and
// the fontSize properties in various components, because the theme's default
// font size will be correctly propagated to the login screen

Item {
    id: root

    // Load custom font
    FontLoader {
        id: customFont
        source: "fonts/SFUIText-Semibold.otf"
    }

    // Global font property for easy access
    readonly property string globalFontFamily: customFont.status === FontLoader.Ready ? customFont.name : "SF UI Text"

    // If we're using software rendering, draw outlines instead of shadows
    // See https://bugs.kde.org/show_bug.cgi?id=398317
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software
    readonly property real uiScale: Math.max(0.78, Math.min(1.6, height / 1080))

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    Kirigami.Theme.inherit: false

    width: 1600
    height: 900

    property string notificationMessage

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    P5Support.DataSource {
        id: keystateSource
        engine: "keystate"
        connectedSources: "Caps Lock"
    }

    Item {
        id: wallpaper
        anchors.fill: parent
        Repeater {
            model: screenModel

            Background {
                x: geometry.x; y: geometry.y; width: geometry.width; height: geometry.height
                sceneBackgroundType: config.type
                sceneBackgroundColor: config.color
                sceneBackgroundImage: config.background
            }
        }
    }

    // Keep the mock's sharp branded wallpaper; interactive SDDM controls
    // are drawn above the live background.
    Image {
        source: "assets/sberos-entry-mark.png"
        width: 256 * root.uiScale
        height: 128 * root.uiScale
        x: (root.width - width) / 2
        y: 444 * root.uiScale
        sourceSize.width: 256
        sourceSize.height: 128
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    property date currentDateTime: new Date()
    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.currentDateTime = new Date()
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 152 * root.uiScale
        width: parent.width
        height: 24 * root.uiScale
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: {
            const value = root.currentDateTime.toLocaleDateString(Qt.locale("ru_RU"), "ddd, d MMMM");
            return value.charAt(0).toUpperCase() + value.slice(1);
        }
        color: "#17191c"
        font.family: "Noto Sans"
        font.pixelSize: 16 * root.uiScale
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 184 * root.uiScale
        width: parent.width
        height: 80 * root.uiScale
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: Qt.formatTime(root.currentDateTime, "hh:mm")
        color: "#17191c"
        font.family: "Noto Sans"
        font.pixelSize: 64 * root.uiScale
    }

    RejectPasswordAnimation {
        id: rejectPasswordAnimation
        target: mainStack
    }

    MouseArea {
        id: loginScreenRoot
        anchors.fill: parent

        property bool uiVisible: true
        property bool blockUI: mainStack.depth > 1 || userListComponent.mainPasswordBox.text.length > 0 || inputPanel.keyboardActive || config.type !== "image"

        hoverEnabled: true
        drag.filterChildren: true
        onPressed: uiVisible = true;
        onPositionChanged: uiVisible = true;
        onUiVisibleChanged: {
            if (blockUI) {
                fadeoutTimer.running = false;
            } else if (uiVisible) {
                fadeoutTimer.restart();
            }
        }
        onBlockUIChanged: {
            if (blockUI) {
                fadeoutTimer.running = false;
                uiVisible = true;
            } else {
                fadeoutTimer.restart();
            }
        }

        Keys.onPressed: event => {
            uiVisible = true;
            event.accepted = false;
        }

        //takes one full minute for the ui to disappear
        Timer {
            id: fadeoutTimer
            running: false
            interval: 60000
            onTriggered: {
                if (!loginScreenRoot.blockUI) {
                    userListComponent.mainPasswordBox.echoMode = TextInput.Password;
                    loginScreenRoot.uiVisible = false;
                }
            }
        }
        QQC2.StackView {
            id: mainStack
            anchors {
                left: parent.left
                right: parent.right
            }
            y: root.height * 0.28
            height: root.height * 0.72

            // If true (depends on the style and environment variables), hover events are always accepted
            // and propagation stopped. This means the parent MouseArea won't get them and the UI won't be shown.
            // Disable capturing those events while the UI is hidden to avoid that, while still passing events otherwise.
            // One issue is that while the UI is visible, mouse activity won't keep resetting the timer, but when it
            // finally expires, the next event should immediately set uiVisible = true again.
            hoverEnabled: loginScreenRoot.uiVisible ? undefined : false

            focus: true //StackView is an implicit focus scope, so we need to give this focus so the item inside will have it

            Timer {
                //SDDM has a bug in 0.13 where even though we set the focus on the right item within the window, the window doesn't have focus
                //it is fixed in 6d5b36b28907b16280ff78995fef764bb0c573db which will be 0.14
                //we need to call "window->activate()" *After* it's been shown. We can't control that in QML so we use a shoddy timer
                //it's been this way for all Plasma 5.x without a huge problem
                running: true
                repeat: false
                interval: 200
                onTriggered: mainStack.forceActiveFocus()
            }

            initialItem: Login {
                id: userListComponent
                userListModel: userModel
                formTopMargin: root.height * 0.34
                //loginScreenUiVisible: loginScreenRoot.uiVisible
                userListCurrentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
                lastUserName: userModel.lastUser
                Component.onCompleted: {
                    userList.visible = false;
                    initialLoginStateTimer.start();
                }
                showUserList: {
                    return userListModel.hasOwnProperty("count") && userListModel.count > 0;
                }

                notificationMessage: {
                    const parts = [];
                    if (keystateSource.data["Caps Lock"]["Locked"]) {
                        parts.push(i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Caps Lock is on"));
                    }
                    if (root.notificationMessage) {
                        parts.push(root.notificationMessage);
                    }
                    return parts.join(" • ");
                }

                actionItemsVisible: false
                actionItems: [Item { visible: false; implicitWidth: 1; implicitHeight: 1 }]

                    onLoginRequest: {
                        root.notificationMessage = ""
                        sddm.login(username, password, sessionButton.currentIndex)
                    }
            }

            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration
                }
            }

            readonly property real zoomFactor: 1.5

            popEnter: Transition {
                ScaleAnimator {
                    from: mainStack.zoomFactor
                    to: 1
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
                OpacityAnimator {
                    from: 0
                    to: 1
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
            }

            popExit: Transition {
                ScaleAnimator {
                    from: 1
                    to: 1 / mainStack.zoomFactor
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
                OpacityAnimator {
                    from: 1
                    to: 0
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
            }

            pushEnter: Transition {
                ScaleAnimator {
                    from: 1 / mainStack.zoomFactor
                    to: 1
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
                OpacityAnimator {
                    from: 0
                    to: 1
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
            }

            pushExit: Transition {
                ScaleAnimator {
                    from: 1
                    to: mainStack.zoomFactor
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
                OpacityAnimator {
                    from: 1
                    to: 0
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
            }
        }

        VirtualKeyboardLoader {
            id: inputPanel

            z: 1

            screenRoot: root
            mainStack: mainStack
            mainBlock: userListComponent
            passwordField: userListComponent.mainPasswordBox
        }

        Component {
            id: userPromptComponent
            Login {
                showUsernamePrompt: true
                notificationMessage: root.notificationMessage
                formTopMargin: root.height * 0.34
                //loginScreenUiVisible: loginScreenRoot.uiVisible
                fontSize: parseInt(config.fontSize) + 2

                // using a model rather than a QObject list to avoid QTBUG-75900
                userListModel: ListModel {
                    ListElement {
                        name: ""
                        icon: ""
                    }
                    Component.onCompleted: {
                        // as we can't bind inside ListElement
                        setProperty(0, "name", i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Type in Username and Password"));
                        setProperty(0, "icon", Qt.resolvedUrl("faces/.face.icon"))
                    }
                }

                onLoginRequest: {
                    root.notificationMessage = ""
                    sddm.login(username, password, sessionButton.currentIndex)
                }

                actionItemsVisible: false
                actionItems: [Item { visible: false; implicitWidth: 1; implicitHeight: 1 }]
            }
        }

        DropShadow {
            id: logoShadow
            anchors.fill: logo
            source: logo
            visible: !softwareRendering && config.showlogo === "shown"
            horizontalOffset: 1
            verticalOffset: 1
            radius: 6
            samples: 14
            spread: 0.3
            color : "black" // shadows should always be black
            opacity: loginScreenRoot.uiVisible ? 0 : 1
            Behavior on opacity {
                //OpacityAnimator when starting from 0 is buggy (it shows one frame with opacity 1)"
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Image {
            id: logo
            visible: config.showlogo === "shown"
            source: config.logo
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: footer.top
            anchors.bottomMargin: Kirigami.Units.largeSpacing
            asynchronous: true
            sourceSize.height: height
            opacity: loginScreenRoot.uiVisible ? 0 : 1
            fillMode: Image.PreserveAspectFit
            height: Math.round(Kirigami.Units.gridUnit * 3.5)
            Behavior on opacity {
                // OpacityAnimator when starting from 0 is buggy (it shows one frame with opacity 1)"
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }

        // Note: Containment masks stretch clickable area of their buttons to
        // the screen edges, essentially making them adhere to Fitts's law.
        // Due to virtual keyboard button having an icon, buttons may have
        // different heights, so fillHeight is required.
        //
        // Note for contributors: Keep this in sync with LockScreenUi.qml footer.
        RowLayout {
            id: footer
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: Kirigami.Units.smallSpacing
            }
            spacing: Kirigami.Units.smallSpacing

            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration
                }
            }

            Item {
                Layout.fillWidth: true
            }

            PlasmaComponents3.ToolButton {
                id: virtualKeyboardButton

                text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Button to show/hide virtual keyboard", "Virtual Keyboard")
                font.pointSize: config.fontSize
                font.family: root.globalFontFamily
                icon.name: inputPanel.keyboardActive ? "input-keyboard-virtual-on" : "input-keyboard-virtual-off"
                onClicked: {
                    // Otherwise the password field loses focus and virtual keyboard
                    // keystrokes get eaten
                    userListComponent.mainPasswordBox.forceActiveFocus();
                    inputPanel.showHide()
                }
                visible: false

                Layout.fillHeight: true
                containmentMask: Item {
                    parent: virtualKeyboardButton
                    anchors.fill: parent
                    anchors.leftMargin: -footer.anchors.margins
                    anchors.bottomMargin: -footer.anchors.margins
                }
            }

            KeyboardButton {
                id: keyboardButton

                font.pointSize: config.fontSize
                font.family: root.globalFontFamily
                text: ""
                icon.name: "input-keyboard"
                Accessible.name: qsTr("Раскладка клавиатуры")

                onKeyboardLayoutChanged: {
                    // Otherwise the password field loses focus and virtual keyboard
                    // keystrokes get eaten
                    userListComponent.mainPasswordBox.forceActiveFocus();
                }

                Layout.fillHeight: true
                containmentMask: Item {
                    parent: keyboardButton
                    anchors.fill: parent
                    anchors.leftMargin: virtualKeyboardButton.visible ? 0 : -footer.anchors.margins
                    anchors.bottomMargin: -footer.anchors.margins
                }
            }

            SessionButton {
                id: sessionButton

                font.pointSize: config.fontSize
                font.family: customFont.status === FontLoader.Ready ? customFont.name : font.family
                text: ""
                icon.name: "system-run"
                Accessible.name: qsTr("Сеанс рабочего стола")

                onSessionChanged: {
                    // Otherwise the password field loses focus and virtual keyboard
                    // keystrokes get eaten
                    userListComponent.mainPasswordBox.forceActiveFocus();
                }

                Layout.fillHeight: true
                containmentMask: Item {
                    parent: sessionButton
                    anchors.fill: parent
                    anchors.leftMargin: virtualKeyboardButton.visible || keyboardButton.visible
                    ? 0 : -footer.anchors.margins
                    anchors.bottomMargin: -footer.anchors.margins
                }
            }

            Battery {
                fontSize: config.fontSize
                // Note: Battery component may need to be modified separately to accept font.family
            }

        }
    }

    Timer {
        id: initialLoginStateTimer
        interval: 500
        onTriggered: {
            if (!userListComponent.initialViewChosen) {
                userListComponent.credentialsVisible = !userListComponent.showUserList;
            }
        }
    }

    Column {
        id: accountChooser
        width: Math.min(378 * root.uiScale, root.width - 40 * root.uiScale)
        height: 216 * root.uiScale
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 110 * root.uiScale
        spacing: 4 * root.uiScale
        visible: userListComponent.showUserList && !userListComponent.credentialsVisible

        ListView {
            id: accountListView
            width: accountChooser.width
            height: 164 * root.uiScale
            model: userModel
            clip: true
            spacing: 4 * root.uiScale
            interactive: contentHeight > height

            delegate: QQC2.Button {
                id: accountButton
                required property int index
                required property var model

                width: accountListView.width
                height: 80 * root.uiScale
                Accessible.name: model.realName || model.name || qsTr("Пользователь")
                onClicked: {
                    userListComponent.initialViewChosen = true;
                    userListComponent.userListCurrentIndex = index;
                    userListComponent.showUsernamePrompt = false;
                    userListComponent.credentialsVisible = true;
                    Qt.callLater(function() { userListComponent.mainPasswordBox.forceActiveFocus(); });
                }
                background: Rectangle {
                    radius: 16 * root.uiScale
                    color: "#ffffff"
                    border.width: accountButton.activeFocus || accountButton.down ? 2 * root.uiScale : 1 * root.uiScale
                    border.color: accountButton.activeFocus || accountButton.down ? "#108e26" : "#c4c7d4"
                }

                contentItem: Row {
                    anchors.fill: parent
                    anchors.leftMargin: 16 * root.uiScale
                    anchors.rightMargin: 16 * root.uiScale
                    spacing: 12 * root.uiScale

                    Item {
                        width: 64 * root.uiScale
                        height: 64 * root.uiScale
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: "#d9dbe6"
                        }

                        Image {
                            anchors.centerIn: parent
                            width: 32 * root.uiScale
                            height: 32 * root.uiScale
                            source: "assets/user-avatar.svg"
                            sourceSize.width: 32
                            sourceSize.height: 32
                            smooth: true
                        }

                    }

                    Text {
                        width: parent.width - 92 * root.uiScale
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        text: model.realName || model.name || qsTr("Пользователь")
                        color: "#17191c"
                        font.family: "Noto Sans"
                        font.pixelSize: 16 * root.uiScale
                        font.weight: Font.Normal
                    }
                }
            }
        }

        QQC2.Button {
            id: otherUserButton
            width: accountChooser.width
            height: 48 * root.uiScale
            text: qsTr("Другой пользователь")
            onClicked: {
                userListComponent.initialViewChosen = true;
                userListComponent.showUsernamePrompt = true;
                userListComponent.lastUserName = "";
                userListComponent.credentialsVisible = true;
            }
            background: Rectangle {
                color: "transparent"
            }
            contentItem: Row {
                spacing: 8 * root.uiScale
                anchors.centerIn: parent
                Image {
                    source: "assets/user-add.svg"
                    width: 20 * root.uiScale
                    height: 20 * root.uiScale
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: otherUserButton.text
                    color: "#17191c"
                    font.family: "Noto Sans"
                    font.pixelSize: 16 * root.uiScale
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    QQC2.ToolButton {
        id: powerButton
        width: 40 * root.uiScale
        height: width
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 28 * root.uiScale
        anchors.rightMargin: 28 * root.uiScale
        icon.name: "settings-configure"
        Accessible.name: qsTr("Питание и настройки")
        onClicked: powerMenu.open()
        background: Rectangle {
            color: "transparent"
        }

        QQC2.Menu {
            id: powerMenu
            QQC2.MenuItem {
                text: qsTr("Спящий режим")
                enabled: sddm.canSuspend
                onTriggered: sddm.suspend()
            }
            QQC2.MenuItem {
                text: qsTr("Перезагрузить")
                enabled: sddm.canReboot
                onTriggered: sddm.reboot()
            }
            QQC2.MenuItem {
                text: qsTr("Выключить")
                enabled: sddm.canPowerOff
                onTriggered: sddm.powerOff()
            }
        }
    }

    QQC2.ToolButton {
        visible: userListComponent.showUserList && userListComponent.credentialsVisible
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.58
        text: qsTr("← Пользователи")
        onClicked: {
            userListComponent.credentialsVisible = false;
            userListComponent.showUsernamePrompt = false;
            userListComponent.mainPasswordBox.text = "";
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            notificationMessage = i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Login Failed")
            footer.enabled = true
            mainStack.enabled = true
            userListComponent.userList.opacity = 1
            rejectPasswordAnimation.start()
        }
        function onLoginSucceeded() {
            //note SDDM will kill the greeter at some random point after this
            //there is no certainty any transition will finish, it depends on the time it
            //takes to complete the init
            mainStack.opacity = 0
            footer.opacity = 0
        }
    }

    onNotificationMessageChanged: {
        if (notificationMessage) {
            notificationResetTimer.start();
        }
    }

    Timer {
        id: notificationResetTimer
        interval: 3000
        onTriggered: notificationMessage = ""
    }
}
