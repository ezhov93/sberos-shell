import QtQuick
import QtTest

Item {
    property var settingsBridge: bridge
    QtObject {
        id: bridge
        property bool sourceTreeEntry: false
        property string sessionShellDir: ""
        property bool developmentBannerDismissed: false
        property string lastError: ""
        property var snapshot: ({
                iconMode: "color"
            })
        property var calls: []
        signal appearanceSnapshotChanged(var state)
        signal systemAppearanceApplied(bool accepted)
        function appearanceSnapshot() {
            appearanceSnapshotChanged(snapshot);
        }
    }
    TestCase {
        name: "RemovedLegacyWidgetStyles"
        when: windowShown
        function test_confirmed_selection() {
            const component = Qt.createComponent("../../main.qml");
            compare(component.status, Component.Ready, component.errorString());
            const app = component.createObject(null, {
                currentPage: 1
            });
            verify(app !== null);
            tryVerify(() => findChild(app.contentItem, "ThemeSettingsPageLoader") !== null);
            verify(findChild(app.contentItem, "widget-style-picker") === null);
            verify(findChild(app.contentItem, "GlassDebugPageLoader") === null);
            app.destroy();
        }
    }
}
