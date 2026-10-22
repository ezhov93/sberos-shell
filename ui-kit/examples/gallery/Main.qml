import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import Sber.Controls as Sber
import Sber.Core
import Sber.Theme

QQC.ApplicationWindow {
    id: window
    property bool darkTheme: false
    width: 880
    height: 660
    minimumWidth: 760
    minimumHeight: 620
    visible: true
    title: "Sber Components — галерея"
    color: Theme.Palette.Background.Default.Primary

    Component.onCompleted: {
        Core.Settings.LineHeight = 40
        Core.Settings.setThemeMode(darkTheme ? Settings.Dark : Settings.Light)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 36
        spacing: 22

        Sber.Label {
            text: "Sber Components"
            font.pixelSize: 30
            font.bold: true
        }
        Sber.Label {
            text: "Интерактивный пример · Sber.Controls + Sber.Theme"
            secondary: true
        }
        RowLayout {
            spacing: 12
            Sber.Button {
                text: "Светлая тема"
                type: Sber.Widget.Secondary
                onClicked: Core.Settings.setThemeMode(Settings.Light)
            }
            Sber.Button {
                text: "Тёмная тема"
                type: Sber.Widget.Secondary
                onClicked: Core.Settings.setThemeMode(Settings.Dark)
            }
        }
        Sber.Divider { Layout.fillWidth: true }
        Sber.TextField {
            id: nameField
            Layout.fillWidth: true
            labelText: "Ваше имя"
            placeholderText: "Введите имя"
        }
        RowLayout {
            spacing: 12
            Sber.Button {
                text: "Поприветствовать"
                type: Sber.Widget.Accient
                onClicked: message.text = "Привет, " + (nameField.text.trim() || "SberOS") + "!"
            }
            Sber.Button {
                text: "Сбросить"
                type: Sber.Widget.Secondary
                onClicked: {
                    nameField.clear()
                    level.value = 65
                    message.text = "Нажмите кнопку, чтобы проверить обработчик события."
                }
            }
            Sber.Button { text: "Недоступно"; enabled: false }
        }
        Sber.Label {
            id: message
            Layout.fillWidth: true
            text: "Нажмите кнопку, чтобы проверить обработчик события."
            wrapMode: Text.WordWrap
        }
        Sber.Slider {
            id: level
            Layout.fillWidth: true
            labelText: "Уровень"
            from: 0
            to: 100
            stepSize: 1
            value: 65
        }
        Sber.ProgressBar {
            Layout.fillWidth: true
            value: level.value
        }
        Item { Layout.fillHeight: true }
        Sber.Label {
            text: "Кнопки, поле ввода, слайдер, прогресс и переключение темы"
            secondary: true
        }
    }
}
