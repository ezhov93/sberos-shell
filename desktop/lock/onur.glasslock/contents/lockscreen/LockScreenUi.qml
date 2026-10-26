/* SPDX-License-Identifier: GPL-2.0-or-later */

import QtQuick
import QtQuick.Controls.Basic
import org.kde.plasma.private.keyboardindicator as KeyboardIndicator
import "state.js" as State

Item {
    id: ui

    readonly property color ink: "#17191c"
    readonly property color inkDim: "#657078"
    readonly property color accent: "#159447"
    readonly property real u: Math.max(0.78, Math.min(1.6, height / 1080))
    readonly property string family: regularFont.status === FontLoader.Ready ? regularFont.name : "sans-serif"
    readonly property string displayFamily: lightFont.status === FontLoader.Ready ? lightFont.name : family
    readonly property string wallpaper: State.wallpaper !== "" ? State.wallpaper : "assets/mock-lock-background.png"
    property bool busy: false
    property bool locked: false
    property bool noPassword: false
    property bool showPassword: false
    property string message: ""
    property bool authenticationStarted: false

    FontLoader {
        id: regularFont
        source: "fonts/Inter-Regular.ttf"
    }
    FontLoader {
        id: lightFont
        source: "fonts/Inter-Light.ttf"
    }

    function wake() {
        if (!authenticationStarted) {
            authenticationStarted = true;
            authenticator.startAuthenticating();
        }
        password.forceActiveFocus();
    }

    function submit() {
        if (busy || locked)
            return;
        if (noPassword) {
            Qt.quit();
            return;
        }
        busy = true;
        message = "";
        authenticator.respond(password.text);
    }

    Timer {
        id: grace
        interval: 1500
        onTriggered: {
            ui.locked = false;
            authenticator.startAuthenticating();
            password.forceActiveFocus();
        }
    }

    Connections {
        target: authenticator
        function onFailed(kind) {
            if (kind !== 0)
                return;
            ui.busy = false;
            ui.locked = true;
            ui.message = qsTr("Пароль не подошёл");
            password.text = "";
            grace.restart();
        }
        function onSucceeded() {
            if (authenticator.hadPrompt)
                Qt.quit();
            else {
                ui.busy = false;
                ui.noPassword = true;
            }
        }
        function onInfoMessageChanged() {
            if (authenticator.infoMessage)
                ui.message = authenticator.infoMessage;
        }
        function onErrorMessageChanged() {
            if (authenticator.errorMessage)
                ui.message = authenticator.errorMessage;
        }
        function onPromptForSecretChanged() {
            password.forceActiveFocus();
        }
    }

    Connections {
        target: root
        function onClearPassword() {
            password.text = "";
            ui.busy = false;
        }
        function onNotificationRepeated() {
            ui.wake();
        }
    }

    KeyboardIndicator.KeyState {
        id: caps
        key: Qt.Key_CapsLock
    }

    Image {
        id: background
        anchors.fill: parent
        source: ui.wallpaper
        sourceSize: Qt.size(1920, 1080)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
        mipmap: true
        onStatusChanged: if (status === Image.Error && source !== "assets/mock-lock-background.png")
            source = "assets/mock-lock-background.png"
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 154 * ui.u
        spacing: 7 * ui.u

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: ui.ink
            font.family: ui.family
            font.pixelSize: 19 * ui.u
            text: Qt.formatDate(clock.now, "ddd, d MMMM")
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: ui.ink
            font.family: ui.displayFamily
            font.pixelSize: 67 * ui.u
            font.weight: Font.Light
            font.letterSpacing: -1.2 * ui.u
            text: Qt.formatTime(clock.now, "HH:mm")
        }
    }

    Timer {
        id: clockTick
        interval: 1000
        repeat: true
        running: true
        onTriggered: clock.now = new Date()
    }

    QtObject {
        id: clock
        property date now: new Date()
    }

    Column {
        id: unlockPanel
        width: Math.min(378 * ui.u, ui.width - 48 * ui.u)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 198 * ui.u

        Text {
            width: parent.width
            height: 28 * ui.u
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: ui.ink
            font.family: ui.family
            font.pixelSize: 23 * ui.u
            elide: Text.ElideRight
            text: qsTr("Пользователь: %1").arg(kscreenlocker_userName)
        }

        Item {
            width: 1
            height: 25 * ui.u
        }

        Rectangle {
            id: passwordField
            width: parent.width
            height: 80 * ui.u
            radius: 15 * ui.u
            color: "#ffffff"
            border.width: password.activeFocus ? 1.5 * ui.u : 1 * ui.u
            border.color: password.activeFocus ? ui.accent : "#168d45"

            Rectangle {
                x: 80 * ui.u
                width: 1 * ui.u
                height: parent.height
                color: "#e0e5e7"
            }

            Button {
                id: submitButton
                width: 80 * ui.u
                height: parent.height
                anchors.left: parent.left
                Accessible.name: qsTr("Разблокировать")
                onClicked: ui.submit()
                background: Rectangle {
                    color: submitButton.down ? "#edf5ef" : "transparent"
                    radius: passwordField.radius
                }
                contentItem: Text {
                    text: "‹"
                    color: ui.inkDim
                    font.family: ui.family
                    font.pixelSize: 38 * ui.u
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Text {
                x: 101 * ui.u
                anchors.verticalCenter: parent.verticalCenter
                visible: password.text === ""
                color: ui.inkDim
                font.family: ui.family
                font.pixelSize: 17 * ui.u
                text: ui.noPassword ? qsTr("Нажмите Enter для разблокировки")
                                    : ui.busy ? qsTr("Проверка…")
                                              : ui.locked ? qsTr("Подождите…") : qsTr("Введите пароль")
            }

            TextInput {
                id: password
                anchors.left: parent.left
                anchors.leftMargin: 101 * ui.u
                anchors.right: showPasswordButton.left
                anchors.rightMargin: 8 * ui.u
                anchors.verticalCenter: parent.verticalCenter
                echoMode: ui.showPassword ? TextInput.Normal : TextInput.Password
                passwordCharacter: "●"
                passwordMaskDelay: 0
                color: ui.ink
                font.family: ui.family
                font.pixelSize: 17 * ui.u
                clip: true
                focus: true
                readOnly: ui.busy || ui.locked || ui.noPassword
                Accessible.name: qsTr("Пароль")
                cursorDelegate: Rectangle {
                    width: 1.5 * ui.u
                    color: ui.accent
                    visible: password.activeFocus
                }
                onTextChanged: ui.message = ""
                onAccepted: ui.submit()
                Keys.onEscapePressed: password.text = ""
            }

            Button {
                id: showPasswordButton
                width: 52 * ui.u
                height: parent.height
                anchors.right: parent.right
                Accessible.name: ui.showPassword ? qsTr("Скрыть пароль") : qsTr("Показать пароль")
                onClicked: ui.showPassword = !ui.showPassword
                background: Rectangle {
                    color: showPasswordButton.down ? "#edf5ef" : "transparent"
                    radius: passwordField.radius
                }
                contentItem: Text {
                    text: ui.showPassword ? "◉" : "◎"
                    color: ui.inkDim
                    font.family: "Inter"
                    font.pixelSize: 24 * ui.u
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Item {
            width: 1
            height: 26 * ui.u
        }

        Text {
            width: parent.width
            height: 22 * ui.u
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: ui.message !== "" ? "#b3261e" : ui.inkDim
            font.family: ui.family
            font.pixelSize: 14 * ui.u
            text: ui.message !== "" ? ui.message : qsTr("Включён Caps Lock")
        }
    }

    Button {
        id: suspendButton
        visible: root.suspendToRamSupported
        width: 44 * ui.u
        height: width
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 28 * ui.u
        anchors.bottomMargin: 24 * ui.u
        Accessible.name: qsTr("Перевести компьютер в сон")
        onClicked: root.suspendToRam()
        background: Rectangle {
            radius: width / 2
            color: suspendButton.down ? "#d8e2e7" : "#ffffffb8"
            border.color: "#a9b5bb"
            border.width: 1
        }
        contentItem: Text {
            text: "⏻"
            color: ui.inkDim
            font.pixelSize: 22 * ui.u
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Keys.onPressed: ui.wake()
    Component.onCompleted: ui.wake()
}
