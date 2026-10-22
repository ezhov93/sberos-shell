import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import Sber.Controls as Sber
import Sber.Theme

Item {
    id: page
    property string componentName
    property string actionMessage: ""

    onComponentNameChanged: actionMessage = ""

    function previewFor(name) {
        switch (name) {
        case "Accordion": return accordionPreview
        case "Button": return buttonPreview
        case "CalendarView": return calendarPreview
        case "CheckBox": return checkBoxPreview
        case "Chip": return chipPreview
        case "ChipGroup": return chipGroupPreview
        case "ComboBox": return comboBoxPreview
        case "DateEdit": return dateEditPreview
        case "DateRangeEdit": return dateRangePreview
        case "IconButton": return iconButtonPreview
        case "LinkButton": return linkPreview
        case "NumberInput": return numberPreview
        case "Pagination": return paginationPreview
        case "RadioButton": return radioPreview
        case "Slider": return sliderPreview
        case "SpinBox": return spinBoxPreview
        case "Steps": return stepsPreview
        case "Switch": return switchPreview
        case "TabBar": return tabBarPreview
        case "TextArea": return textAreaPreview
        case "TextField": return textFieldPreview
        case "TimePicker": return timePickerPreview
        default: return null
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        Sber.Label {
            text: page.componentName
            font: Theme.Fonts.HeaderH4B
        }
        Sber.Label {
            text: qsTr("Отдельная вкладка компонента")
            secondary: true
        }
        Sber.Divider { Layout.fillWidth: true }

        Loader {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            sourceComponent: page.previewFor(page.componentName)
        }
        Sber.Label {
            Layout.fillWidth: true
            text: page.actionMessage
            visible: text !== ""
            secondary: true
        }
    }

    ListModel {
        id: optionsModel
        ListElement { text: "Профиль"; value: "profile" }
        ListElement { text: "Уведомления"; value: "notifications" }
        ListElement { text: "Безопасность"; value: "security" }
    }

    Component {
        id: buttonPreview
        QQC.GroupBox {
            title: qsTr("Состояния кнопки")
            ColumnLayout {
                anchors.fill: parent
                Sber.Button { text: qsTr("Основное действие"); type: Sber.Widget.Accient; onClicked: page.actionMessage = qsTr("Основное действие выполнено") }
                Sber.Button { text: qsTr("Вторичное действие"); type: Sber.Widget.Secondary; onClicked: page.actionMessage = qsTr("Вторичное действие выполнено") }
                Sber.Button { text: qsTr("Недоступно"); enabled: false }
            }
        }
    }
    Component {
        id: textFieldPreview
        ColumnLayout {
            Sber.TextField { Layout.fillWidth: true; labelText: qsTr("Имя"); placeholderText: qsTr("Введите имя"); onTextEdited: page.actionMessage = qsTr("Введено символов: %1").arg(text.length) }
            Sber.TextField { Layout.fillWidth: true; labelText: qsTr("Электронная почта"); placeholderText: qsTr("name@example.com"); captionText: qsTr("Подпись под полем") }
        }
    }
    Component {
        id: textAreaPreview
        Sber.TextArea { Layout.fillWidth: true; Layout.preferredHeight: 150; placeholderText: qsTr("Введите комментарий"); onTextEdited: page.actionMessage = qsTr("Введено символов: %1").arg(text.length) }
    }
    Component {
        id: checkBoxPreview
        ColumnLayout {
            Sber.CheckBox { text: qsTr("Сохранить настройки"); checked: true; onToggled: page.actionMessage = checked ? qsTr("Настройки сохраняются") : qsTr("Настройки не сохраняются") }
            Sber.CheckBox { text: qsTr("Получать новости"); onToggled: page.actionMessage = checked ? qsTr("Новости включены") : qsTr("Новости выключены") }
        }
    }
    Component {
        id: switchPreview
        ColumnLayout {
            Sber.Switch { text: qsTr("Уведомления"); checked: true; onToggled: page.actionMessage = checked ? qsTr("Уведомления включены") : qsTr("Уведомления выключены") }
            Sber.Switch { text: qsTr("Автоматическое обновление"); onToggled: page.actionMessage = checked ? qsTr("Обновление включено") : qsTr("Обновление выключено") }
        }
    }
    Component {
        id: radioPreview
        ColumnLayout {
            Sber.RadioButton { text: qsTr("Стандартный режим"); checked: true; onToggled: if (checked) page.actionMessage = qsTr("Выбран стандартный режим") }
            Sber.RadioButton { text: qsTr("Расширенный режим"); onToggled: if (checked) page.actionMessage = qsTr("Выбран расширенный режим") }
        }
    }
    Component {
        id: comboBoxPreview
        Sber.ComboBox { Layout.fillWidth: true; labelText: qsTr("Раздел"); model: optionsModel; onActivated: page.actionMessage = qsTr("Раздел: %1").arg(currentText) }
    }
    Component {
        id: sliderPreview
        Sber.Slider { Layout.fillWidth: true; labelText: qsTr("Уровень"); from: 0; to: 100; value: 64; onValueEdited: (value) => page.actionMessage = qsTr("Значение: %1").arg(Math.round(value)) }
    }
    Component {
        id: chipPreview
        RowLayout {
            Sber.Chip { text: qsTr("Дизайн"); idx: "design"; closable: true; onClosed: (idx) => page.actionMessage = qsTr("Метка удалена: %1").arg(idx) }
            Sber.Chip { text: qsTr("Qt 6") }
        }
    }
    Component {
        id: chipGroupPreview
        Sber.ChipGroup {
            Layout.fillWidth: true
            width: 480
            closable: true
            onClosed: (idx) => page.actionMessage = qsTr("Метка удалена: %1").arg(idx)
            Component.onCompleted: {
                add(qsTr("Профиль"), "profile")
                add(qsTr("Уведомления"), "notifications")
                add(qsTr("Безопасность"), "security")
            }
        }
    }
    Component { id: iconButtonPreview; Sber.IconButton { icon.name: "Plus"; Accessible.name: qsTr("Добавить"); onClicked: page.actionMessage = qsTr("Кнопка добавления нажата") } }
    Component { id: linkPreview; Sber.LinkButton { text: qsTr("Открыть ссылку"); onClicked: page.actionMessage = qsTr("Ссылка нажата") } }
    Component { id: paginationPreview; Sber.Pagination { count: 12; visibleCount: 5; currentIndex: 2; onCurrentIndexChanged: page.actionMessage = qsTr("Страница %1").arg(currentIndex + 1) } }
    Component { id: dateEditPreview; Sber.DateEdit { Layout.fillWidth: true; labelText: qsTr("Дата"); onAccepted: page.actionMessage = qsTr("Дата подтверждена") } }
    Component { id: dateRangePreview; Sber.DateRangeEdit { Layout.fillWidth: true; labelText: qsTr("Период"); onAccepted: page.actionMessage = qsTr("Период подтверждён") } }
    Component { id: timePickerPreview; Sber.TimePicker { Layout.fillWidth: true; labelText: qsTr("Время"); onAccepted: page.actionMessage = qsTr("Время подтверждено") } }
    Component { id: numberPreview; Sber.NumberInput { Layout.fillWidth: true; labelText: qsTr("Количество"); from: 0; to: 100; Component.onCompleted: setValue(12); onValueChanged: (value) => page.actionMessage = qsTr("Количество: %1").arg(value) } }
    Component { id: spinBoxPreview; Sber.SpinBox { from: 0; to: 10; Component.onCompleted: setValue(3); onValueChanged: (value) => page.actionMessage = qsTr("Значение: %1").arg(value) } }
    Component {
        id: stepsPreview
        Sber.Steps {
            Layout.fillWidth: true
            currentIndex: 1
            onCurrentIndexChanged: page.actionMessage = qsTr("Шаг %1").arg(currentIndex + 1)
            Sber.Step { title: qsTr("Профиль") }
            Sber.Step { title: qsTr("Подтверждение") }
            Sber.Step { title: qsTr("Готово") }
        }
    }
    Component {
        id: accordionPreview
        Sber.Accordion {
            Layout.fillWidth: true
            title: qsTr("Информация о компоненте")
            opened: true
            hasBackground: true
            onOpenedChanged: page.actionMessage = opened ? qsTr("Раздел раскрыт") : qsTr("Раздел свёрнут")
            Sber.Label { text: qsTr("Аккордеон раскрывает и скрывает вложенное содержимое."); wrapMode: Text.WordWrap }
        }
    }
    Component {
        id: tabBarPreview
        Sber.TabBar {
            Layout.fillWidth: true
            onCurrentIndexChanged: page.actionMessage = qsTr("Вкладка %1").arg(currentIndex + 1)
            Sber.TabButton { text: qsTr("Обзор") }
            Sber.TabButton { text: qsTr("Активность") }
            Sber.TabButton { text: qsTr("Настройки") }
        }
    }
    Component {
        id: calendarPreview
        Sber.CalendarView { Layout.alignment: Qt.AlignLeft | Qt.AlignTop; onDateChanged: page.actionMessage = qsTr("Дата изменена") }
    }
}
