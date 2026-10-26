import QtQuick
import QtTest
import Sber.Controls as Sber

Item {
    width: 720
    height: 560

    Sber.Menu {
        id: menu
        Sber.MenuItem {
            text: "A deliberately wide menu item that should exceed the menu height by a large margin"
        }
    }

    Sber.Range {
        id: range
        x: 20
        y: 80
        width: 400
        from: 0
        to: 100
    }

    Sber.ChipGroup {
        id: chips
        x: 20
        y: 140
        width: 320
    }

    Sber.Pagination {
        id: pagination
        x: 20
        y: 200
        count: 12
        visibleCount: 5
        currentIndex: 5
    }

    Sber.AutoComplite {
        id: autoComplete
        x: 20
        y: 270
        width: 240
        model: [
            {
                text: "Alpine",
                value: "alpine",
                caption: "Mountain"
            }
        ]
    }

    Sber.AutoComplite {
        id: autoCompleteWithoutPopup
        x: 280
        y: 270
        width: 240
        model: []
    }

    Sber.TextField {
        id: textField
        x: 20
        y: 410
        width: 240
    }

    Sber.Menu {
        id: textFieldMenu
        parent: textField
        Sber.MenuItem {
            text: qsTr("Custom field action")
        }
    }

    Sber.TextArea {
        id: textArea
        x: 280
        y: 410
        width: 240
        height: 80
    }

    Sber.Menu {
        id: textAreaMenu
        parent: textArea
        Sber.MenuItem {
            text: qsTr("Custom area action")
        }
    }

    ListModel {
        id: multiSelectModel
        ListElement {
            text: "Alpha"
            value: "alpha"
            caption: "First"
            checkState: 0
        }
        ListElement {
            text: "Beta"
            value: "beta"
            caption: "Second"
            checkState: 0
        }
    }

    Sber.ComboBox {
        id: multiSelect
        x: 20
        y: 340
        width: 240
        model: multiSelectModel
        multiselect: true
    }

    Sber.ComboBox {
        id: arrayMultiSelect
        x: 300
        y: 340
        width: 240
        model: [
            {
                text: "Gamma",
                value: "gamma",
                caption: "Third",
                checkState: 0
            }
        ]
        multiselect: true
    }

    SignalSpy {
        id: chipClosed
        target: chips
        signalName: "closed"
    }

    TestCase {
        name: "UiKitRegressions"
        when: windowShown

        function test_menuWidthUsesContentWidth() {
            fuzzyCompare(menu.width, menu.implicitWidth, 0.001);
            verify(menu.width !== menu.implicitHeight);
        }

        function test_rangeFieldsAndSettersAreIndependent() {
            range.setValueFrom(15);
            compare(range.valueFrom(), 15);
            compare(range.valueTo(), 0);

            range.setValueTo(85);
            compare(range.valueFrom(), 15);
            compare(range.valueTo(), 85);
        }

        function test_chipGroupResetsSizeAndOnlySignalsRemoval() {
            chips.add("Chip", "one");
            verify(chips.implicitWidth > 0);
            verify(chips.implicitHeight > 0);

            chips.remove("missing");
            compare(chipClosed.count, 0);

            chips.remove("one");
            compare(chipClosed.count, 1);
            compare(chips.implicitWidth, 0);
            compare(chips.implicitHeight, 0);
        }

        function test_paginationMiddlePagesStayWithinRepeater() {
            tryVerify(function () {
                return findChild(pagination, "paginationPage2") !== null;
            });
            var centerPage = findChild(pagination, "paginationPage2");
            tryCompare(centerPage, "text", "6");
            compare(findChild(pagination, "paginationPage0").text, "1");
            compare(findChild(pagination, "paginationPage1").text, "...");
            compare(findChild(pagination, "paginationPage3").text, "...");
            compare(findChild(pagination, "paginationPage4").text, "12");
        }

        function test_autocompleteOpensForArrayModel() {
            autoComplete.forceActiveFocus();
            keyClick(Qt.Key_A);
            var popup = findChild(autoComplete, "autoCompletePopup");
            tryCompare(popup, "opened", true);
        }

        function test_autocompleteAcceptsBeforeLoaderIsReady() {
            autoCompleteWithoutPopup.forceActiveFocus();
            autoCompleteWithoutPopup.accepted();
            compare(autoCompleteWithoutPopup.currentIndex, -1);
        }

        function test_textFieldOpensPlainMenu() {
            textField.contextMenu = textFieldMenu;
            textField.onMenuToggled({
                button: Qt.RightButton,
                x: 10,
                y: 10
            });
            tryCompare(textFieldMenu, "opened", true);
            textFieldMenu.close();
            compare(textFieldMenu.opened, false);
        }

        function test_textAreaOpensPlainMenu() {
            textArea.contextMenu = textAreaMenu;
            textArea.onMenuToggled({
                button: Qt.RightButton,
                x: 10,
                y: 10
            });
            tryCompare(textAreaMenu, "opened", true);
            textAreaMenu.close();
            compare(textAreaMenu.opened, false);
        }

        function test_multiselectReadsNamedListModelRoles() {
            multiSelect.popup.open();
            multiSelectModel.setProperty(0, "checkState", Qt.Checked);
            var chipsView = findChild(multiSelect, "comboBoxChips");
            tryVerify(function () {
                return chipsView.chips.length === 1;
            });
            compare(chipsView.chips[0].text, "First");

            chipsView.remove(0);
            tryVerify(function () {
                return chipsView.chips.length === 0;
            });
            compare(multiSelectModel.get(0).checkState, Qt.Unchecked);
        }

        function test_multiselectReadsNamedArrayRoles() {
            var chipsView = findChild(arrayMultiSelect, "comboBoxChips");
            arrayMultiSelect.model[0].checkState = Qt.Checked;
            chipsView.update();
            compare(chipsView.chips.length, 1);
            compare(chipsView.chips[0].text, "Third");

            chipsView.remove(0);
            compare(arrayMultiSelect.model[0].checkState, Qt.Unchecked);
        }
    }
}
