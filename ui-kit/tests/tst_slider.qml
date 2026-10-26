import QtQuick
import QtTest
import Sber.Controls as Sber
import Sber.Core
import Sber.Theme

Item {
    width: 480
    height: 120
    Sber.Slider {
        id: slider
        x: 40
        y: 40
        width: 300
        from: 0
        to: 1
        stepSize: 0.1
        showRangeValues: false
    }
    SignalSpy {
        id: edits
        target: slider
        signalName: "valueEdited"
    }
    SignalSpy {
        id: finishes
        target: slider
        signalName: "editingFinished"
    }
    TestCase {
        name: "SliderUserInput"
        when: windowShown
        function init() {
            slider.value = 0;
            edits.clear();
            finishes.clear();
        }
        function test_programmaticChangeIsSilent() {
            slider.value = 0.5;
            compare(edits.count, 0);
            compare(finishes.count, 0);
        }
        function test_pointerClampsSnapsAndFinishes() {
            mousePress(slider, 1, slider.height / 2);
            mouseMove(slider, slider.width * 0.57, slider.height / 2);
            fuzzyCompare(slider.value, 0.6, 0.00001);
            mouseMove(slider, slider.width + 40, slider.height / 2);
            compare(slider.value, 1);
            mouseRelease(slider, slider.width + 40, slider.height / 2);
            verify(edits.count > 0);
            compare(finishes.count, 1);
            compare(finishes.signalArguments[0][0], 1);
            compare(slider.pressed, false);
        }
        function test_keyboardEditsAndFinishes() {
            slider.forceActiveFocus(Qt.TabFocusReason);
            keyClick(Qt.Key_Right);
            fuzzyCompare(slider.value, 0.1, 0.00001);
            compare(edits.count, 1);
            compare(finishes.count, 1);
        }
    }
}
