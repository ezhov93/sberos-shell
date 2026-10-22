import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import Sber.Controls as Sber
import Sber.Theme

Item {
    id: page
    property string componentName

    function previewFor(name) {
        switch (name) {
        case "Accordion": return accordionPreview
        case "Avatar": return avatarPreview
        case "Badge": return badgePreview
        case "BusyIndicator": return busyPreview
        case "Button": return buttonPreview
        case "CalendarView": return calendarPreview
        case "CheckBox": return checkBoxPreview
        case "Chip": return chipPreview
        case "ChipGroup": return chipGroupPreview
        case "ComboBox": return comboBoxPreview
        case "Counter": return counterPreview
        case "DateEdit": return dateEditPreview
        case "DateRangeEdit": return dateRangePreview
        case "Divider": return dividerPreview
        case "Icon": return iconPreview
        case "IconButton": return iconButtonPreview
        case "Label": return labelPreview
        case "LinkButton": return linkPreview
        case "NumberInput": return numberPreview
        case "PageIndicator": return pageIndicatorPreview
        case "Pagination": return paginationPreview
        case "ProgressBar": return progressPreview
        case "RadioButton": return radioPreview
        case "Slider": return sliderPreview
        case "SpinBox": return spinBoxPreview
        case "Steps": return stepsPreview
        case "Switch": return switchPreview
        case "TabBar": return tabBarPreview
        case "TextArea": return textAreaPreview
        case "TextField": return textFieldPreview
        case "TimePicker": return timePickerPreview
        default: return catalogPreview
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
                Sber.Button { text: qsTr("Основное действие"); type: Sber.Widget.Accient }
                Sber.Button { text: qsTr("Вторичное действие"); type: Sber.Widget.Secondary }
                Sber.Button { text: qsTr("Недоступно"); enabled: false }
            }
        }
    }
    Component {
        id: labelPreview
        ColumnLayout {
            Sber.Label { text: qsTr("Основной текст"); font: Theme.Fonts.BodyM }
            Sber.Label { text: qsTr("Вторичный текст"); secondary: true }
            Sber.Label { text: qsTr("Заголовок"); bold: true }
        }
    }
    Component {
        id: textFieldPreview
        ColumnLayout {
            Sber.TextField { Layout.fillWidth: true; labelText: qsTr("Имя"); placeholderText: qsTr("Введите имя") }
            Sber.TextField { Layout.fillWidth: true; labelText: qsTr("Электронная почта"); placeholderText: qsTr("name@example.com"); captionText: qsTr("Подпись под полем") }
        }
    }
    Component {
        id: textAreaPreview
        Sber.TextArea { Layout.fillWidth: true; Layout.preferredHeight: 150; placeholderText: qsTr("Введите комментарий") }
    }
    Component {
        id: checkBoxPreview
        ColumnLayout {
            Sber.CheckBox { text: qsTr("Сохранить настройки"); checked: true }
            Sber.CheckBox { text: qsTr("Получать новости") }
        }
    }
    Component {
        id: switchPreview
        ColumnLayout {
            Sber.Switch { text: qsTr("Уведомления"); checked: true }
            Sber.Switch { text: qsTr("Автоматическое обновление") }
        }
    }
    Component {
        id: radioPreview
        ColumnLayout {
            Sber.RadioButton { text: qsTr("Стандартный режим"); checked: true }
            Sber.RadioButton { text: qsTr("Расширенный режим") }
        }
    }
    Component {
        id: comboBoxPreview
        Sber.ComboBox { Layout.fillWidth: true; labelText: qsTr("Раздел"); model: optionsModel }
    }
    Component {
        id: sliderPreview
        Sber.Slider { Layout.fillWidth: true; labelText: qsTr("Уровень"); from: 0; to: 100; value: 64 }
    }
    Component {
        id: progressPreview
        ColumnLayout {
            Sber.ProgressBar { Layout.fillWidth: true; value: 64 }
            Sber.ProgressBar { Layout.fillWidth: true; value: 38; warning: true }
            Sber.ProgressBar { Layout.fillWidth: true; value: 82; error: true }
        }
    }
    Component { id: busyPreview; Sber.BusyIndicator { running: true; implicitWidth: 48; implicitHeight: 48 } }
    Component { id: badgePreview; Sber.Badge { text: qsTr("Новое"); type: Sber.Widget.Accient } }
    Component { id: counterPreview; Sber.Counter { count: 7 } }
    Component {
        id: chipPreview
        RowLayout {
            Sber.Chip { text: qsTr("Дизайн"); closable: true }
            Sber.Chip { text: qsTr("Qt 6") }
        }
    }
    Component {
        id: chipGroupPreview
        Sber.ChipGroup {
            Layout.fillWidth: true
            width: 480
            closable: true
            Component.onCompleted: {
                add(qsTr("Профиль"), "profile")
                add(qsTr("Уведомления"), "notifications")
                add(qsTr("Безопасность"), "security")
            }
        }
    }
    Component { id: iconPreview; RowLayout { Sber.Icon { name: "Search"; size: 28 } Sber.Icon { name: "Plus"; size: 28 } } }
    Component { id: iconButtonPreview; Sber.IconButton { icon.name: "Plus"; Accessible.name: qsTr("Добавить") } }
    Component { id: linkPreview; Sber.LinkButton { text: qsTr("Открыть ссылку") } }
    Component { id: dividerPreview; ColumnLayout { Sber.Label { text: qsTr("Содержимое до разделителя") } Sber.Divider { Layout.fillWidth: true } Sber.Label { text: qsTr("Содержимое после разделителя") } } }
    Component { id: avatarPreview; RowLayout { Sber.Avatar { size: 56; status: Sber.Widget.Online } Sber.Avatar { size: 56; status: Sber.Widget.Afk } Sber.Avatar { size: 56; status: Sber.Widget.Offline } } }
    Component { id: pageIndicatorPreview; Sber.PageIndicator { count: 5; currentIndex: 2 } }
    Component { id: paginationPreview; Sber.Pagination { count: 12; currentIndex: 2 } }
    Component { id: dateEditPreview; Sber.DateEdit { Layout.fillWidth: true; labelText: qsTr("Дата") } }
    Component { id: dateRangePreview; Sber.DateRangeEdit { Layout.fillWidth: true; labelText: qsTr("Период") } }
    Component { id: timePickerPreview; Sber.TimePicker { Layout.fillWidth: true; labelText: qsTr("Время") } }
    Component { id: numberPreview; Sber.NumberInput { Layout.fillWidth: true; labelText: qsTr("Количество"); from: 0; to: 100; Component.onCompleted: setValue(12) } }
    Component { id: spinBoxPreview; Sber.SpinBox { from: 0; to: 10; Component.onCompleted: setValue(3) } }
    Component {
        id: stepsPreview
        Sber.Steps {
            Layout.fillWidth: true
            currentIndex: 1
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
            Sber.Label { text: qsTr("Аккордеон раскрывает и скрывает вложенное содержимое."); wrapMode: Text.WordWrap }
        }
    }
    Component {
        id: tabBarPreview
        Sber.TabBar {
            Layout.fillWidth: true
            Sber.TabButton { text: qsTr("Обзор") }
            Sber.TabButton { text: qsTr("Активность") }
            Sber.TabButton { text: qsTr("Настройки") }
        }
    }
    Component {
        id: calendarPreview
        Sber.CalendarView { Layout.alignment: Qt.AlignLeft | Qt.AlignTop }
    }
    Component {
        id: catalogPreview
        QQC.GroupBox {
            title: qsTr("Компонент UI Kit")
            Layout.fillWidth: true
            ColumnLayout {
                anchors.fill: parent
                Sber.Label {
                    Layout.fillWidth: true
                    text: qsTr("%1 доступен в модуле Sber.Controls или Sber.Widgets. Для компонентов с собственным экранным видом здесь отображается отдельный интерактивный пример.").arg(page.componentName)
                    wrapMode: Text.WordWrap
                }
                Sber.Label {
                    text: qsTr("Объявления и свойства: ui-kit/docs/API-catalog.md")
                    secondary: true
                }
            }
        }
    }
}
