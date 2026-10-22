import QtQuick
import QtQuick.Layouts

import Sber.Controls
import Sber.Core
import Sber.Theme


GridLayout {
    property bool reloadVisible: false
    property bool modeVisible: true
    property bool heightVisible: true
    rowSpacing: 20
    columnSpacing: 20
    columns: 2

    Label {
        visible: reloadVisible
        text: qsTr("Theme");
    }
    IconButton {
        visible: reloadVisible
        icon.name: "Refresh"
        onReleased: {
            Theme.reloadTheme();
        }
    }

    Label {
        visible: modeVisible
        text: qsTr("Mode");
    }
    ComboBox {
        visible: modeVisible
        model: ListModel {}
        onCurrentValueChanged: {
            Core.Settings.setThemeMode(currentValue);
        }
        Component.onCompleted: {
            model.append({"text": qsTr("Light"), "value": Settings.Light})
            model.append({"text": qsTr("Dark"), "value": Settings.Dark})
            model.append({"text": qsTr("System"), "value": Settings.System})
            for (let i = 0; i < model.count; i++) {
                if (valueAt(i) === Core.Settings.getThemeMode()) {
                    currentIndex = i;
                    return;
                }
            }
            currentIndex = 2;
        }
    }

    Label {
        visible: heightVisible
        text: qsTr("Size");
    }
    ComboBox {
        visible: heightVisible
        model: ListModel {}
        onCurrentValueChanged: {
            if (currentValue)
                Core.Settings.LineHeight = currentValue;
        }
        Component.onCompleted: {
            model.append({"text": ("Xs"), "value": Theme.Sizes.LineHeight.Xs})
            model.append({"text": ("S"), "value": Theme.Sizes.LineHeight.S})
            model.append({"text": ("M"), "value": Theme.Sizes.LineHeight.M})
            model.append({"text": ("L"), "value": Theme.Sizes.LineHeight.L})

            for (let i = 0; i < model.count; i++) {
                if (valueAt(i) === Core.Settings.LineHeight) {
                    currentIndex = i;
                    return;
                }
            }
            currentIndex = 1;
        }
    }
}
