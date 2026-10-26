import QtQuick
import QtTest
import "../../components" as SettingsControls
import "../../../../shared/qml/i18n"

Item {
    width: 760
    height: 160

    TestCase {
        name: "SegmentedSettingsNavBar"
        when: windowShown
        visible: true

        Component {
            id: navigation
            SettingsControls.SettingsNavBar {
                colors: ({})
                currentIndex: 1
                model: [
                    {
                        id: "always",
                        label: "Always show"
                    },
                    {
                        id: "smart",
                        label: "Smart hide"
                    },
                    {
                        id: "persistent",
                        label: "Keep hidden"
                    }
                ]
            }
        }

        function test_usesUiKitButtonsAndTracksSelection() {
            const control = createTemporaryObject(navigation, this);
            verify(control !== null);
            const first = findChild(control, "settings-nav-option-0");
            const second = findChild(control, "settings-nav-option-1");
            const third = findChild(control, "settings-nav-option-2");
            verify(first !== null);
            verify(second !== null);
            verify(third !== null);
            compare(second.checked, true);
            compare(second.text, "Smart hide");
            mouseClick(third, third.width / 2, third.height / 2);
            compare(control.selectedIndex, 2);
        }

        function test_languageChangeReflows() {
            const control = createTemporaryObject(navigation, this, {
                model: [
                    {
                        id: "always",
                        label: "始终显示"
                    },
                    {
                        id: "smart",
                        label: "智能隐藏"
                    },
                    {
                        id: "persistent",
                        label: "保持隐藏"
                    }
                ]
            });
            verify(control !== null);
            const before = control.implicitWidth;
            control.model = [
                {
                    id: "always",
                    label: "Always show"
                },
                {
                    id: "smart",
                    label: "Smart hide"
                },
                {
                    id: "persistent",
                    label: "Keep hidden"
                }
            ];
            wait(120);
            verify(control.implicitWidth > before);
        }

        function test_settingsBarPageAtMinimumWidth() {
            const previous = I18n.language;
            let app = null;
            try {
                I18n.language = "en";
                const component = Qt.createComponent("../../main.qml");
                compare(component.status, Component.Ready, component.errorString());
                app = component.createObject(null, {
                    currentPage: 2,
                    width: 1030,
                    height: 720
                });
                verify(app !== null);
                tryVerify(() => findChild(app.contentItem, "bar-visibility-picker") !== null);
                const visibility = findChild(app.contentItem, "bar-visibility-picker");
                verify(visibility !== null);
                verify(findChild(visibility, "settings-nav-option-0") !== null);
            } finally {
                if (app)
                    app.destroy();
                I18n.language = previous;
            }
        }
    }
}
