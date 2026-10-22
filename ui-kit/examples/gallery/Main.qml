import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import Sber.Controls as Sber
import Sber.Core
import Sber.Theme

QQC.ApplicationWindow {
    id: window
    property bool darkTheme: false
    width: 1180
    height: 900
    minimumWidth: 760
    minimumHeight: 640
    visible: true
    title: qsTr("Sber Components — витрина UI Kit")
    color: Theme.Palette.Background.Default.Primary

    Component.onCompleted: {
        Core.Settings.LineHeight = 40
        Core.Settings.setThemeMode(darkTheme ? Settings.Dark : Settings.Light)
    }

    ListModel {
        id: optionsModel
        ListElement { text: "Профиль"; value: "profile" }
        ListElement { text: "Уведомления"; value: "notifications" }
        ListElement { text: "Безопасность"; value: "security" }
    }

    ListModel {
        id: componentModel
        ListElement { name: "Accordion" } ListElement { name: "ApplicationHeader" }
        ListElement { name: "ApplicationWindow" } ListElement { name: "ArrowRectangle" }
        ListElement { name: "Attach" } ListElement { name: "AutoComplite" }
        ListElement { name: "Avatar" } ListElement { name: "AvatarGroup" }
        ListElement { name: "BackgroundConfig" } ListElement { name: "Badge" }
        ListElement { name: "BusyIndicator" } ListElement { name: "Button" }
        ListElement { name: "ButtonRowGroup" } ListElement { name: "CalendarFunctions" }
        ListElement { name: "CalendarView" } ListElement { name: "Carousel" }
        ListElement { name: "CheckBox" } ListElement { name: "CheckDelegate" }
        ListElement { name: "Chip" } ListElement { name: "ChipGroup" }
        ListElement { name: "Colorizer" } ListElement { name: "ComboBox" }
        ListElement { name: "Counter" } ListElement { name: "CursorDelegate" }
        ListElement { name: "DashedBorder" } ListElement { name: "DateEdit" }
        ListElement { name: "DateRangeEdit" } ListElement { name: "DateView" }
        ListElement { name: "DefaultOverlay" } ListElement { name: "DefaultTextMenu" }
        ListElement { name: "Dialog" } ListElement { name: "DialogButtonBox" }
        ListElement { name: "Divider" } ListElement { name: "Drawer" }
        ListElement { name: "DropZone" } ListElement { name: "Editable" }
        ListElement { name: "FocusItem" } ListElement { name: "Icon" }
        ListElement { name: "IconButton" } ListElement { name: "IconLabel" }
        ListElement { name: "Indicator" } ListElement { name: "ItemDelegate" }
        ListElement { name: "Label" } ListElement { name: "LinkButton" }
        ListElement { name: "Menu" } ListElement { name: "MenuItem" }
        ListElement { name: "MenuSeparator" } ListElement { name: "MonthView" }
        ListElement { name: "Notification" } ListElement { name: "NumberInput" }
        ListElement { name: "PageIndicator" } ListElement { name: "Pagination" }
        ListElement { name: "Popup" } ListElement { name: "ProgressBar" }
        ListElement { name: "RadioButton" } ListElement { name: "RadioDelegate" }
        ListElement { name: "Range" } ListElement { name: "ScrollBar" }
        ListElement { name: "ScrollView" } ListElement { name: "ShadowBox" }
        ListElement { name: "Slider" } ListElement { name: "SpinBox" }
        ListElement { name: "Step" } ListElement { name: "Steps" }
        ListElement { name: "Switch" } ListElement { name: "SwitchDelegate" }
        ListElement { name: "TabBar" } ListElement { name: "TabButton" }
        ListElement { name: "TextArea" } ListElement { name: "TextAreaScroll" }
        ListElement { name: "TextConfig" } ListElement { name: "TextField" }
        ListElement { name: "ThemeGradient" } ListElement { name: "TimeDelimiter" }
        ListElement { name: "TimePart" } ListElement { name: "TimePicker" }
        ListElement { name: "TimePickerView" } ListElement { name: "ToolTip" }
        ListElement { name: "YearView" } ListElement { name: "ThemeSettings" }
    }

    QQC.ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 28

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 32
                Layout.bottomMargin: 0

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Sber.Label {
                        text: qsTr("Sber Components")
                        font: Theme.Fonts.HeaderH4B
                    }
                    Sber.Label {
                        text: qsTr("Интерактивная витрина компонентов UI Kit")
                        secondary: true
                    }
                }
                Sber.Button {
                    text: window.darkTheme ? qsTr("Светлая тема") : qsTr("Тёмная тема")
                    type: Sber.Widget.Secondary
                    onClicked: {
                        window.darkTheme = !window.darkTheme
                        Core.Settings.setThemeMode(window.darkTheme ? Settings.Dark : Settings.Light)
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 32
                Layout.rightMargin: 32
                spacing: 24

                Sber.Label {
                    text: qsTr("Базовые элементы")
                    font: Theme.Fonts.HeaderH4B
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: width >= 900 ? 3 : 2
                    columnSpacing: 16
                    rowSpacing: 16

                    QQC.GroupBox {
                        title: qsTr("Кнопки и состояния")
                        Layout.fillWidth: true
                        Layout.preferredHeight: 190
                        ColumnLayout {
                            anchors.fill: parent
                            Sber.Button { text: qsTr("Основное действие"); onClicked: actionMessage.text = qsTr("Кнопка нажата") }
                            Sber.Button { text: qsTr("Вторичное действие"); type: Sber.Widget.Secondary }
                            Sber.Button { text: qsTr("Недоступно"); enabled: false }
                            Sber.Label { id: actionMessage; text: qsTr("Нажмите кнопку"); secondary: true }
                        }
                    }

                    QQC.GroupBox {
                        title: qsTr("Ввод текста")
                        Layout.fillWidth: true
                        Layout.preferredHeight: 190
                        ColumnLayout {
                            anchors.fill: parent
                            Sber.TextField {
                                Layout.fillWidth: true
                                labelText: qsTr("Имя")
                                placeholderText: qsTr("Введите имя")
                                captionText: qsTr("Поле с подписью и подсказкой")
                            }
                            Sber.TextArea {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 64
                                placeholderText: qsTr("Комментарий")
                            }
                        }
                    }

                    QQC.GroupBox {
                        title: qsTr("Выбор")
                        Layout.fillWidth: true
                        Layout.preferredHeight: 190
                        ColumnLayout {
                            anchors.fill: parent
                            Sber.ComboBox { Layout.fillWidth: true; labelText: qsTr("Раздел"); model: optionsModel }
                            Sber.CheckBox { text: qsTr("Запомнить выбор"); checked: true }
                            Sber.Switch { text: qsTr("Уведомления"); checked: true }
                            Sber.RadioButton { text: qsTr("Стандартный режим"); checked: true }
                        }
                    }

                    QQC.GroupBox {
                        title: qsTr("Индикаторы")
                        Layout.fillWidth: true
                        Layout.preferredHeight: 190
                        ColumnLayout {
                            anchors.fill: parent
                            Sber.Slider { Layout.fillWidth: true; labelText: qsTr("Громкость"); from: 0; to: 100; value: 64 }
                            Sber.ProgressBar { Layout.fillWidth: true; value: 64 }
                            RowLayout {
                                Sber.BusyIndicator { running: true; implicitWidth: 32; implicitHeight: 32 }
                                Sber.Badge { text: qsTr("Новое"); type: Sber.Widget.Accient }
                                Sber.Counter { count: 7 }
                                Sber.PageIndicator { count: 5; currentIndex: 2 }
                            }
                        }
                    }

                    QQC.GroupBox {
                        title: qsTr("Метки и иконки")
                        Layout.fillWidth: true
                        Layout.preferredHeight: 190
                        ColumnLayout {
                            anchors.fill: parent
                            RowLayout {
                                Sber.Chip { text: qsTr("Дизайн"); closable: true; onClosed: (idx) => chipMessage.text = qsTr("Метка закрыта") }
                                Sber.Chip { text: qsTr("Qt 6") }
                                Sber.Label { id: chipMessage; text: qsTr("Метки"); secondary: true }
                            }
                            RowLayout {
                                Sber.Icon { name: "Search"; size: 24 }
                                Sber.Icon { name: "Settings"; size: 24 }
                                Sber.IconButton { icon.name: "Plus"; Accessible.name: qsTr("Добавить") }
                                Sber.LinkButton { text: qsTr("Открыть ссылку") }
                            }
                        }
                    }

                    QQC.GroupBox {
                        title: qsTr("Пользователи")
                        Layout.fillWidth: true
                        Layout.preferredHeight: 190
                        RowLayout {
                            anchors.fill: parent
                            Sber.Avatar { size: 48; status: Sber.Widget.Online }
                            Sber.Avatar { size: 48; status: Sber.Widget.Afk }
                            Sber.Avatar { size: 48; status: Sber.Widget.Offline }
                            Sber.Indicator { lineHeight: 40 }
                        }
                    }
                }

                Sber.Divider { Layout.fillWidth: true }
                Sber.Label { text: qsTr("Навигация и составные элементы"); font: Theme.Fonts.HeaderH4B }

                QQC.GroupBox {
                    title: qsTr("Вкладки и шаги")
                    Layout.fillWidth: true
                    ColumnLayout {
                        anchors.fill: parent
                        Sber.TabBar {
                            id: tabs
                            Layout.fillWidth: true
                            Sber.TabButton { text: qsTr("Обзор") }
                            Sber.TabButton { text: qsTr("Активность") }
                            Sber.TabButton { text: qsTr("Настройки") }
                        }
                        Sber.Label { text: qsTr("Выбрана вкладка %1").arg(tabs.currentIndex + 1); secondary: true }
                        Sber.Steps {
                            Layout.fillWidth: true
                            currentIndex: 1
                            Sber.Step { title: qsTr("Профиль") }
                            Sber.Step { title: qsTr("Подтверждение") }
                            Sber.Step { title: qsTr("Готово") }
                        }
                    }
                }

                QQC.GroupBox {
                    title: qsTr("Аккордеон и карусель")
                    Layout.fillWidth: true
                    ColumnLayout {
                        anchors.fill: parent
                        Sber.Accordion {
                            Layout.fillWidth: true
                            title: qsTr("Информация о компоненте")
                            opened: true
                            hasBackground: true
                            Sber.Label { text: qsTr("Компоненты UI Kit используют общие токены темы и размеров."); wrapMode: Text.WordWrap }
                        }
                        Sber.Carousel {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 112
                            itemWidth: 300
                            itemHeight: 72
                            buttonsVisible: true
                            Rectangle {
                                width: 300; height: 72; radius: 12
                                color: Theme.Palette.Background.Default.Secondary
                                Sber.Label { anchors.centerIn: parent; text: qsTr("Карточка 1") }
                            }
                            Rectangle {
                                width: 300; height: 72; radius: 12
                                color: Theme.Palette.Background.Default.Secondary
                                Sber.Label { anchors.centerIn: parent; text: qsTr("Карточка 2") }
                            }
                            Rectangle {
                                width: 300; height: 72; radius: 12
                                color: Theme.Palette.Background.Default.Secondary
                                Sber.Label { anchors.centerIn: parent; text: qsTr("Карточка 3") }
                            }
                        }
                    }
                }

                Sber.Divider { Layout.fillWidth: true }
                Sber.Label { text: qsTr("Формы даты и времени"); font: Theme.Fonts.HeaderH4B }

                GridLayout {
                    Layout.fillWidth: true
                    columns: width >= 760 ? 2 : 1
                    columnSpacing: 16
                    rowSpacing: 16
                    Sber.DateEdit { Layout.fillWidth: true; labelText: qsTr("Дата") }
                    Sber.DateRangeEdit { Layout.fillWidth: true; labelText: qsTr("Период") }
                    Sber.TimePicker { Layout.fillWidth: true; labelText: qsTr("Время") }
                    Sber.NumberInput { Layout.fillWidth: true; labelText: qsTr("Количество"); from: 0; to: 100; Component.onCompleted: setValue(12) }
                    Sber.SpinBox { Layout.fillWidth: true; from: 0; to: 10; Component.onCompleted: setValue(3) }
                }

                Sber.Divider { Layout.fillWidth: true }
                RowLayout {
                    Layout.fillWidth: true
                    Sber.Label { text: qsTr("Каталог компонентов"); font: Theme.Fonts.HeaderH4B; Layout.fillWidth: true }
                    Sber.Label { text: qsTr("%1 компонентов").arg(componentModel.count); secondary: true }
                }
                Sber.Label {
                    Layout.fillWidth: true
                    text: qsTr("Полный перечень QML-компонентов Sber.Controls и Sber.Widgets. Служебные типы и делегаты показаны в каталоге, поскольку они используются внутри готовых контролов.")
                    secondary: true
                    wrapMode: Text.WordWrap
                }
                GridLayout {
                    Layout.fillWidth: true
                    columns: width >= 900 ? 5 : width >= 600 ? 3 : 2
                    columnSpacing: 8
                    rowSpacing: 8
                    Repeater {
                        model: componentModel
                        delegate: QQC.Frame {
                            required property string name
                            Layout.fillWidth: true
                            implicitHeight: 42
                            padding: 8
                            Sber.Label { anchors.centerIn: parent; text: name; smaller: true }
                        }
                    }
                }
                Sber.Label {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    Layout.bottomMargin: 24
                    text: qsTr("Тема: Sber.Theme · Размеры и шрифты: Theme.Sizes и Theme.Fonts · Служебные значения перечислены в API-каталоге UI Kit")
                    secondary: true
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
