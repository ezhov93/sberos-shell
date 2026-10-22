import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import Sber.Controls as Sber
import Sber.Core
import Sber.Theme

QQC.ApplicationWindow {
    id: window
    property bool darkTheme: false
    property string activeComponent: "Button"
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

    ListModel {
        id: openedTabs
        ListElement { name: "Button" }
    }

    function openComponent(name) {
        var tabIndex = -1
        for (var i = 0; i < openedTabs.count; ++i) {
            if (openedTabs.get(i).name === name) {
                tabIndex = i
                break
            }
        }
        if (tabIndex < 0) {
            openedTabs.append({name: name})
            tabIndex = openedTabs.count - 1
        }
        tabs.currentIndex = tabIndex
        activeComponent = name
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 28
            spacing: 18
            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Sber.Label {
                        text: qsTr("Sber Components")
                        font: Theme.Fonts.HeaderH4B
                    }
                    Sber.Label {
                        text: qsTr("%1 компонентов · выберите элемент справа").arg(componentModel.count)
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

            Sber.TabBar {
                id: tabs
                Layout.fillWidth: true
                arrowsVisible: true
                Repeater {
                    model: openedTabs
                    delegate: Sber.TabButton {
                        required property string name
                        text: name
                    }
                }
                onCurrentIndexChanged: {
                    if (currentIndex >= 0 && currentIndex < openedTabs.count)
                        window.activeComponent = openedTabs.get(currentIndex).name
                }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: tabs.currentIndex
                Repeater {
                    model: openedTabs
                    delegate: ComponentDetail {
                        required property string name
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        componentName: name
                    }
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: 280
            Layout.fillHeight: true
            color: Theme.Palette.Background.Default.Secondary
            border.width: 1
            border.color: Theme.Palette.Outline.Default.SolidSecondaryHover

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                Sber.Label {
                    Layout.fillWidth: true
                    text: qsTr("Компоненты")
                    font: Theme.Fonts.HeaderH4B
                }
                Sber.TextField {
                    id: filterField
                    Layout.fillWidth: true
                    placeholderText: qsTr("Найти компонент")
                }
                ListView {
                    id: componentList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: componentModel
                    clip: true
                    spacing: 2
                    delegate: Sber.ItemDelegate {
                        required property string name
                        width: ListView.view.width
                        height: name.toLowerCase().includes(filterField.text.toLowerCase()) ? 40 : 0
                        visible: height > 0
                        highlightCurrent: false
                        highlighted: window.activeComponent === name
                        text: name
                        Accessible.name: qsTr("Компонент %1").arg(name)
                        onClicked: window.openComponent(name)
                    }
                }
            }
        }
    }
}
