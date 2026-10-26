import QtQuick
import QtQuick.Layouts
import Sber.Controls as Sber

// Compact segmented choice built from the shared UI Kit button component.
Item {
    id: root

    required property var colors
    property var model: []
    property int currentIndex: 0
    property int selectedIndex: currentIndex
    property int itemWidthOverride: 0
    property bool disabled: false

    signal selectionChanged(int index)

    onCurrentIndexChanged: selectedIndex = currentIndex

    Layout.minimumWidth: 0
    Layout.preferredWidth: implicitWidth
    Layout.maximumWidth: parent ? parent.width * 0.65 : implicitWidth

    implicitWidth: choices.implicitWidth
    implicitHeight: choices.implicitHeight

    RowLayout {
        id: choices
        anchors.fill: parent
        spacing: 4

        Repeater {
            id: choicesRepeater
            model: root.model

            delegate: Sber.Button {
                required property var modelData
                required property int index

                Layout.fillWidth: root.itemWidthOverride <= 0
                Layout.preferredWidth: root.itemWidthOverride > 0 ? root.itemWidthOverride : implicitWidth
                objectName: "settings-nav-option-" + index
                text: modelData.label
                checkable: true
                checked: index === root.selectedIndex
                enabled: !root.disabled
                onClicked: {
                    root.selectedIndex = index;
                    root.selectionChanged(index);
                }
            }
        }
    }
}
