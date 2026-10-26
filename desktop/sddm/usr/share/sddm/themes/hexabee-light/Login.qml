import org.kde.breeze.components

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.plasma5support 2.0 as PlasmaCore

SessionManagementScreen {
    id: root
    property Item mainPasswordBox: passwordBox
    property bool showUsernamePrompt: !showUserList
    property bool credentialsVisible: !showUserList
    property bool initialViewChosen: false
    property real formTopMargin: 0
    property int usernameFontSize
    property int fontSize: parseInt(config.fontSize)
    property string usernameFontColor
    property string lastUserName
    property bool loginScreenUiVisible: false
    property bool passwordFieldOutlined: config.PasswordFieldOutlined == "true"
    property bool hidePasswordRevealIcon: config.HidePasswordRevealIcon == "false"
    property int visibleBoundary: mapFromItem(loginButton, 0, 0).y
    onHeightChanged: visibleBoundary = mapFromItem(loginButton, 0, 0).y + loginButton.height + Kirigami.Units.smallSpacing

    signal loginRequest(string username, string password)

    onShowUsernamePromptChanged: {
        if (!showUsernamePrompt) {
            lastUserName = ""
        }
    }

    onUserSelected: {
        // Don't startLogin() here, because the signal is connected to the
        // Escape key as well, for which it wouldn't make sense to trigger
        // login.
        focusFirstVisibleFormControl();
    }

    QQC2.StackView.onActivating: {
        // Controls are not visible yet.
        Qt.callLater(focusFirstVisibleFormControl);
    }

    function focusFirstVisibleFormControl() {
        const nextControl = (userNameInput.visible
            ? userNameInput
            : (passwordBox.visible
                ? passwordBox
                : loginButton));
        // Using TabFocusReason, so that the loginButton gets the visual highlight.
        nextControl.forceActiveFocus(Qt.TabFocusReason);
    }

    /*
    * Login has been requested with the following username and password
    * If username field is visible, it will be taken from that, otherwise from the "name" property of the currentIndex
    */
    function startLogin() {
        const username = showUsernamePrompt ? userNameInput.text : userList.selectedUser
        const password = passwordBox.text

        footer.enabled = false
        mainStack.enabled = false
        userListComponent.userList.opacity = 0.5

        // This is partly because it looks nicer, but more importantly it
        // works round a Qt bug that can trigger if the app is closed with a
        // TextField focused.
        //
        // See https://bugreports.qt.io/browse/QTBUG-55460
        loginButton.forceActiveFocus();
        loginRequest(username, password);
    }

    Input {
        id: userNameInput
        Layout.fillWidth: true
        Layout.preferredHeight: 80
        Layout.topMargin: showUsernamePrompt ? 0 : root.formTopMargin
        font.pointSize: fontSize + 3
        font.family: config.font || "SF UI Text"
        text: lastUserName
        visible: credentialsVisible && showUsernamePrompt
        focus: showUsernamePrompt && !lastUserName //if there's a username prompt it gets focus first, otherwise password does
        placeholderText: qsTr("Имя пользователя")
        placeholderTextColor: "#6c707f"
        color: "#17191c"
        //horizontalAlignment: TextInput.AlignHCenter
        leftPadding: fontSize
        rightPadding: leftPadding
    }

    Input {
        id: passwordBox
        Layout.fillWidth: true
        font.pointSize: fontSize + 3
        Layout.preferredHeight: 80
        Layout.topMargin: showUsernamePrompt ? 0 : root.formTopMargin
        font.family: config.font || "SF UI Text"
        placeholderText: config.PasswordFieldPlaceholderText && config.PasswordFieldPlaceholderText !== "Password"
            ? config.PasswordFieldPlaceholderText
            : qsTr("Введите пароль")
        visible: credentialsVisible
        focus: !showUsernamePrompt || lastUserName
        echoMode: TextInput.Password
        onAccepted: startLogin()
        placeholderTextColor: "#6c707f"
        passwordCharacter: config.PasswordFieldCharacter ? config.PasswordFieldCharacter : "●"
        color: "#17191c"
        //horizontalAlignment: TextInput.AlignHCenter
        leftPadding: fontSize
        rightPadding: leftPadding

        Keys.onEscapePressed: {
            mainStack.currentItem.forceActiveFocus();
        }

        Keys.onPressed: {
            if (event.key == Qt.Key_Left && !text) {
                userList.decrementCurrentIndex();
                event.accepted = true
            }
            if (event.key == Qt.Key_Right && !text) {
                userList.incrementCurrentIndex();
                event.accepted = true
            }
        }

        Connections {
            target: sddm
            onLoginFailed: {
                passwordBox.selectAll()
                passwordBox.forceActiveFocus()
            }
        }
    }

    QQC2.Button {
        id: loginButton
        Layout.preferredWidth: 193
        Layout.preferredHeight: 48
        Layout.alignment: Qt.AlignHCenter
        text: qsTr("Войти")
        visible: credentialsVisible && passwordBox.text.length > 0
        enabled: passwordBox.text.length > 0
        onClicked: startLogin()
        background: Rectangle {
            radius: 12
            color: loginButton.down ? "#0b741d" : "#108e26"
        }
        contentItem: Text {
            text: loginButton.text
            color: "white"
            font.family: config.font || "SF UI Text"
            font.pointSize: 14
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
