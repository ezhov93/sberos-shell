import QtQuick
import Sber.Controls as Sber

// Keep array-backed page data separate from Sber.ComboBox's ListModel API.
Sber.ComboBox {
    id: control

    property var options: []
    property string optionLabelRole: ""
    property string optionValueRole: ""

    textRole: "text"
    valueRole: "value"
    model: optionModel

    ListModel {
        id: optionModel
    }

    function rebuildOptions() {
        optionModel.clear();
        const items = control.options || [];
        for (let i = 0; i < items.length; ++i) {
            const item = items[i];
            const label = control.optionLabelRole ? item[control.optionLabelRole] : item;
            const value = control.optionValueRole ? item[control.optionValueRole] : String(i);
            optionModel.append({
                text: String(label),
                value: value
            });
        }
    }

    onOptionsChanged: rebuildOptions()
    onOptionLabelRoleChanged: rebuildOptions()
    onOptionValueRoleChanged: rebuildOptions()
    Component.onCompleted: rebuildOptions()
}
