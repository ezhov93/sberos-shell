/* SPDX-License-Identifier: GPL-3.0-or-later */
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import ".."

FocusScope {
    id: popup
    required property var notifications
    required property bool serviceAvailable
    signal dismissed()
    signal searchRequested(string query)
    signal closeNotification(int notificationId)
    signal activateNotification(int notificationId)
    signal clearRequested()
    readonly property SmartPanelTheme smartTheme: SmartPanelTheme {}
    implicitWidth: 456
    implicitHeight: 354
    Layout.minimumWidth: 456
    Layout.maximumWidth: 456
    Layout.preferredWidth: 456
    Layout.minimumHeight: 354
    Layout.maximumHeight: 354
    Layout.preferredHeight: 354
    focus: true
    Keys.onEscapePressed: event => { popup.dismissed(); event.accepted = true; }
    Rectangle {
        anchors.fill: parent
        radius: 24
        color: popup.smartTheme.shell
        border.width: 1
        border.color: popup.smartTheme.edge
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        anchors.topMargin: 12
        spacing: 0
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            Text {
                Layout.fillWidth: true
                text: qsTr("Уведомления · %1").arg(list.count)
                font.pixelSize: 16
                font.weight: Font.DemiBold
                color: popup.smartTheme.foreground
            }
            Button {
                id: clearButton
                text: qsTr("Очистить")
                enabled: list.count > 0
                onClicked: popup.clearRequested()
                contentItem: Text {
                    text: clearButton.text
                    color: clearButton.enabled ? popup.smartTheme.foreground : popup.smartTheme.muted
                    font.pixelSize: 14
                }
                background: Rectangle {
                    radius: 10
                    color: clearButton.hovered ? popup.smartTheme.hover : popup.smartTheme.inner
                    border.width: clearButton.visualFocus ? 2 : 0
                    border.color: popup.smartTheme.focus
                }
            }
        }
        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            clip: true
            model: popup.notifications
            boundsBehavior: Flickable.StopAtBounds
            delegate: Rectangle {
                id: card
                required property var model
                width: list.width
                height: Math.max(112, content.implicitHeight + 32)
                radius: 16
                color: popup.smartTheme.inner
                ColumnLayout {
                    id: content
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Kirigami.Icon {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            source: card.model.applicationIconName || card.model.iconName || "dialog-information"
                        }
                        Text {
                            Layout.fillWidth: true
                            text: card.model.applicationName || qsTr("Приложение")
                            font.pixelSize: 14
                            color: popup.smartTheme.muted
                            elide: Text.ElideRight
                        }
                        Text {
                            text: card.model.created ? Qt.formatTime(card.model.created, Qt.locale().timeFormat(Locale.ShortFormat)) : ""
                            font.pixelSize: 12
                            color: popup.smartTheme.muted
                        }
                        Button {
                            id: closeButton
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28
                            padding: 0
                            text: "×"
                            Accessible.name: qsTr("Закрыть уведомление")
                            onClicked: popup.closeNotification(card.model.id)
                            contentItem: Text {
                                text: closeButton.text
                                font.pixelSize: 22
                                color: popup.smartTheme.muted
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                radius: 8
                                color: closeButton.hovered ? popup.smartTheme.hover : "transparent"
                                border.width: closeButton.visualFocus ? 2 : 0
                                border.color: popup.smartTheme.focus
                            }
                        }
                    }
                    Button {
                        id: notificationButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: message.implicitHeight
                        padding: 0
                        enabled: Boolean(card.model.hasDefaultAction)
                        Accessible.name: card.model.summary || qsTr("Уведомление")
                        onClicked: popup.activateNotification(card.model.id)
                        background: Rectangle {
                            radius: 8
                            color: notificationButton.hovered ? popup.smartTheme.hover : "transparent"
                            border.width: notificationButton.visualFocus ? 2 : 0
                            border.color: popup.smartTheme.focus
                        }
                        contentItem: ColumnLayout {
                            id: message
                            spacing: 8
                            Text {
                                Layout.fillWidth: true
                                text: card.model.summary || ""
                                textFormat: Text.PlainText
                                color: popup.smartTheme.foreground
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                wrapMode: Text.WordWrap
                            }
                            Text {
                                Layout.fillWidth: true
                                text: card.model.body || ""
                                textFormat: Text.StyledText
                                color: popup.smartTheme.foreground
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }
            Text {
                anchors.centerIn: parent
                width: parent.width - 32
                visible: list.count === 0
                text: popup.serviceAvailable ? qsTr("Уведомлений пока нет") : qsTr("Сервис уведомлений недоступен")
                color: popup.smartTheme.muted
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }
        TextField {
            id: searchFooter
            Layout.topMargin: 16
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            leftPadding: 12
            rightPadding: 12
            placeholderText: qsTr("Найду документ или приложение")
            placeholderTextColor: popup.smartTheme.searchText
            color: popup.smartTheme.foreground
            font.pixelSize: 16
            Accessible.name: qsTr("Поиск документов и приложений")
            onTextChanged: if (text.length) popup.searchRequested(text)
            background: Rectangle {
                radius: 17
                color: popup.smartTheme.inner
                border.width: searchFooter.activeFocus ? 2 : 1
                border.color: searchFooter.activeFocus ? popup.smartTheme.focus : popup.smartTheme.edge
            }
        }
    }
}
