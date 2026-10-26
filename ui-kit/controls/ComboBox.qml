import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Theme

T.ComboBox {
    id: control

    property alias lineHeight: textField.lineHeight
    property alias label: textField.label
    property alias labelText: textField.labelText
    property alias labelColor: textField.labelColor
    property alias labelFont: textField.labelFont
    property alias caption: textField.caption
    property alias captionText: textField.captionText
    property alias captionColor: textField.captionColor
    property alias captionFont: textField.captionFont
    property alias placeholderText: textField.placeholderText
    property alias placeholderTextColor: textField.placeholderTextColor
    property alias iconLeft: textField.iconLeft
    property alias iconRight: textField.iconRight
    property alias required: textField.required
    property alias requiredPlacement: textField.requiredPlacement
    property bool tight: false
    property bool multiselect: false

    textRole: "text"
    valueRole: "value"
    property string captionRole: "caption"
    property string checkStateRole: "checkState"

    implicitWidth: contentItem.implicitWidth
    implicitHeight: contentItem.implicitHeight
    opacity: enabled ? 1 : 0.4
    currentIndex: -1

    focusPolicy: Qt.TabFocus

    contentItem: TextField {
        id: textField
        anchors.fill: parent
        rightPadding: textField.backgroundConfig.horizontalPadding + indicator.width

        text: control.multiselect ? "" : control.displayText
        enabled: false
        opacity: 1
        inputMethodHints: control.inputMethodHints
        validator: control.validator
        colorizer.hovered: control.enabled && control.hovered
        colorizer.activated: control.activeFocus

        onReleased: popup.opened ? popup.close() : popup.open()
    }
    onFocusChanged: {
        textField.focus = focus;
        textField.focusReason = Qt.TabFocus;
    }

    Flickable {
        id: chipsArea
        x: textField.iconLeft.visible ? textField.leftPadding : (textField.background.height - height) / 2
        y: textField.background.y + (textField.background.height - height) / 2
        width: indicator.x - x
        height: chipsGroup.implicitHeight
        contentHeight: chipsGroup.implicitHeight
        contentWidth: chipsGroup.implicitWidth

        flickableDirection: Flickable.HorizontalFlick
        clip: true
        visible: control.multiselect

        ChipGroup {
            id: chipsGroup
            objectName: "comboBoxChips"
            z: 500
            oneLine: true
            lineHeight: control.lineHeight
            type: Widget.Secondary

            function update() {
                if (!control.multiselect)
                    return;

                var selected = [];
                for (var i = 0; i < modelCount(); i++) {
                    if (roleValue(i, control.checkStateRole) === Qt.Checked)
                        selected.push({
                            index: i,
                            caption: roleValue(i, control.captionRole)
                        });
                }

                for (var i = 0; i < selected.length; i++) {
                    if (i < chips.length) {
                        chips[i].text = selected[i].caption;
                        chips[i].idx = selected[i].index;
                    } else {
                        chipsGroup.add(selected[i].caption, selected[i].index);
                    }
                }
                for (var i = chips.length - 1; i >= selected.length; i--) {
                    chipsGroup.remove(chips[i].idx);
                }
            }

            function modelCount() {
                var sourceModel = control.model;
                if (Array.isArray(sourceModel))
                    return sourceModel.length;
                if (sourceModel && typeof sourceModel.length === "number")
                    return sourceModel.length;
                if (sourceModel && typeof sourceModel.count === "number")
                    return sourceModel.count;
                if (sourceModel && typeof sourceModel.rowCount === "function")
                    return sourceModel.rowCount();
                return 0;
            }

            function roleValue(index, role) {
                var sourceModel = control.model;
                var row = sourceModel && typeof sourceModel.get === "function" ? sourceModel.get(index) : sourceModel ? sourceModel[index] : null;
                return row ? row[role] : undefined;
            }

            function setRoleValue(index, role, value) {
                var sourceModel = control.model;
                if (sourceModel && typeof sourceModel.setProperty === "function") {
                    sourceModel.setProperty(index, role, value);
                } else if (sourceModel) {
                    var row = sourceModel[index];
                    if (row)
                        row[role] = value;
                }
            }

            function isArrayModel() {
                return Array.isArray(control.model) || control.model && typeof control.model.length === "number";
            }
            onClosed: idx => {
                if (idx >= 0 && idx < chipsGroup.modelCount()) {
                    chipsGroup.setRoleValue(idx, control.checkStateRole, Qt.Unchecked);
                }
            }

            Timer {
                id: initialChipSync
                interval: 0
                repeat: false
                onTriggered: chipsGroup.update()
            }

            Component.onCompleted: initialChipSync.start()
        }
    }

    indicator: Icon {
        x: control.width - width - (textField.iconRight.visible ? textField.rightPadding : textField.backgroundConfig.horizontalPadding / 2)
        y: textField.background.y + (textField.background.height - height) / 2
        size: control.lineHeight <= Theme.Sizes.LineHeight.Xs ? 16 : 24
        color: control.hovered ? Theme.Palette.Text.Default.Primary : Theme.Palette.Text.Default.Secondary
        name: control.down ? "ChevronUp" : "ChevronDown"
    }

    popup: Menu {
        id: popup
        y: textField.background.y + textField.background.height
        width: control.width
        radius: textField.background.radius

        contentItem: ListView {
            id: listView
            implicitHeight: contentHeight
            model: control.delegateModel
            currentIndex: control.currentIndex
            clip: true
            focus: true
            keyNavigationEnabled: true
            keyNavigationWraps: true
            ScrollBar.vertical: ScrollBar {
                width: 4
            }
        }
    }

    delegate: MenuItem {
        id: menuItem
        width: ListView.view.width
        tight: control.tight
        lineHeight: control.lineHeight
        checkable: control.multiselect
        indicator.visible: true
        highlighted: index == control.currentIndex

        text: control.textRole ? (chipsGroup.isArrayModel() ? modelData[control.textRole] : model[control.textRole]) : modelData
        property var value: control.valueRole ? (chipsGroup.isArrayModel() ? modelData[control.valueRole] ? modelData[control.valueRole] : "" : model[control.valueRole] ? model[control.valueRole] : "") : ""
        captionText: control.captionRole ? (chipsGroup.isArrayModel() ? modelData[control.captionRole] ? modelData[control.captionRole] : "" : model[control.captionRole] ? model[control.captionRole] : "") : ""
        checkState: control.multiselect ? control.checkStateRole ? (chipsGroup.isArrayModel() ? modelData[control.checkStateRole] ? modelData[control.checkStateRole] : Qt.Unchecked : model[control.checkStateRole] ? model[control.checkStateRole] : Qt.Unchecked) : Qt.Unchecked : Qt.Unchecked
        onCheckStateChanged: {
            if (control.multiselect) {
                if (chipsGroup.isArrayModel()) {
                    if (modelData[control.checkStateRole] != checkState)
                        modelData[control.checkStateRole] = checkState;
                } else if (control.model && typeof control.model.setProperty === "function") {
                    var row = control.model.get(index);
                    if (row[control.checkStateRole] !== checkState)
                        control.model.setProperty(index, control.checkStateRole, checkState);
                } else {
                    if (model[control.checkStateRole] != checkState)
                        model[control.checkStateRole] = checkState;
                }
                chipsGroup.update();
            }
        }
    }
}
