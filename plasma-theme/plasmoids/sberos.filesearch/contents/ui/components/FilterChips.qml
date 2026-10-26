import QtQuick
import QtQuick.Controls.Basic
import org.kde.kirigami as Kirigami

Item {
    id: filterChipsRoot

    property color textColor
    property color accentColor
    property color bgColor
    property string activeFilter: "All"
    property bool breezeStyle: false
    readonly property bool dark: Kirigami.Theme.textColor.hsvValue > Kirigami.Theme.backgroundColor.hsvValue
    readonly property color selectedFill: dark ? accentColor : "#287d78"
    readonly property color selectedText: dark ? "#202830" : "#ffffff"

    signal filterSelected(string filterName)
    signal nextFocusRequested()
    signal previousFocusRequested()

    implicitHeight: 40

    readonly property var filterModel: [
        { key: "All",     label: i18nd("plasma_applet_com.mcc45tr.filesearch", "All") },
        { key: "Apps",    label: i18nd("plasma_applet_com.mcc45tr.filesearch", "Apps") },
        { key: "Docs",    label: i18nd("plasma_applet_com.mcc45tr.filesearch", "Docs") },
        { key: "Images",  label: i18nd("plasma_applet_com.mcc45tr.filesearch", "Images") },
        { key: "Folders", label: i18nd("plasma_applet_com.mcc45tr.filesearch", "Folders") },
        { key: "Web",     label: i18nd("plasma_applet_com.mcc45tr.filesearch", "Web") },
        { key: "RSS",     label: "RSS" }
    ]

    function focusChip(index) {
        const chip = chipRepeater.itemAt(index);
        if (!chip) return;
        chip.forceActiveFocus();

        const chipX = rowLayout.x + chip.x;
        if (chipX < chipList.contentX) {
            chipList.contentX = chipX;
        } else if (chipX + chip.width > chipList.contentX + chipList.width) {
            chipList.contentX = chipX + chip.width - chipList.width;
        }
    }

    function focusFirstChip() { focusChip(0); }
    function focusLastChip() { focusChip(filterModel.length - 1); }

    Flickable {
        id: chipList
        anchors.fill: parent
        contentWidth: rowLayout.width
        contentHeight: height
        clip: true
        interactive: contentWidth > width
        boundsBehavior: Flickable.StopAtBounds

        Row {
            id: rowLayout
            spacing: 8
            padding: 4
            x: width < parent.width ? (parent.width - width) / 2 : 0

            Repeater {
                id: chipRepeater
                model: filterChipsRoot.filterModel

                delegate: Button {
                    id: chip
                    required property var modelData
                    required property int index

                    height: 32
                    padding: 0
                    leftPadding: 12
                    rightPadding: 12
                    text: modelData.label
                    checkable: true
                    checked: modelData.key === filterChipsRoot.activeFilter
                    activeFocusOnTab: true
                    Accessible.name: modelData.label

                    background: Rectangle {
                        radius: height / 2
                        color: chip.checked ? filterChipsRoot.selectedFill
                              : chip.down ? Qt.rgba(filterChipsRoot.textColor.r, filterChipsRoot.textColor.g, filterChipsRoot.textColor.b, 0.16)
                              : chip.hovered ? Qt.rgba(filterChipsRoot.textColor.r, filterChipsRoot.textColor.g, filterChipsRoot.textColor.b, 0.10)
                              : filterChipsRoot.breezeStyle ? "transparent"
                              : Qt.rgba(filterChipsRoot.textColor.r, filterChipsRoot.textColor.g, filterChipsRoot.textColor.b, 0.06)
                        border.width: chip.visualFocus ? 2 : filterChipsRoot.breezeStyle && !chip.checked ? 1 : 0
                        border.color: chip.visualFocus
                                      ? (chip.checked ? filterChipsRoot.selectedText : filterChipsRoot.textColor)
                                      : Qt.rgba(filterChipsRoot.textColor.r, filterChipsRoot.textColor.g, filterChipsRoot.textColor.b, 0.3)
                    }

                    contentItem: Text {
                        text: chip.text
                        color: chip.checked ? filterChipsRoot.selectedText : filterChipsRoot.textColor
                        font.pixelSize: 16
                        font.weight: chip.checked ? Font.Medium : Font.Normal
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    onClicked: filterChipsRoot.filterSelected(modelData.key)
                    Keys.onTabPressed: event => {
                        event.accepted = true;
                        if (event.modifiers & Qt.ShiftModifier) moveFocus(-1);
                        else moveFocus(1);
                    }
                    Keys.onBacktabPressed: event => {
                        event.accepted = true;
                        moveFocus(-1);
                    }
                    Keys.onLeftPressed: event => { event.accepted = true; moveFocus(-1); }
                    Keys.onRightPressed: event => { event.accepted = true; moveFocus(1); }

                    function moveFocus(direction) {
                        const nextIndex = index + direction;
                        if (nextIndex < 0) filterChipsRoot.previousFocusRequested();
                        else if (nextIndex >= filterChipsRoot.filterModel.length) filterChipsRoot.nextFocusRequested();
                        else filterChipsRoot.focusChip(nextIndex);
                    }
                }
            }
        }
    }
}
