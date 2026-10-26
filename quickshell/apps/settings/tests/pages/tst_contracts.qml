import QtQuick
import QtTest

Item {
    id: harness
    width: 1000
    height: 800

    // No application window, context properties or real IPC service: a page
    // must be usable solely through the inputs documented in pages/README.md.
    readonly property var palette: ({
            dark: false,
            background: "#eff0f1",
            sidebar: "#eff0f1",
            contentSurface: "#e3e5e7",
            primaryText: "#1c1c1e",
            secondaryText: "#6d6d72",
            tertiaryText: "#8e8e93",
            card: "#ffffff",
            separator: "#e5e5ea",
            divider: "#d1d1d6",
            searchField: "#e3e3e8",
            selected: "#d9e9ff",
            selectedContainer: "#eeeeee",
            sidebarHover: "#eeeeee",
            chevron: "#c7c7cc",
            iconForeground: "#ffffff",
            iconMuted: "#6d6d72",
            selectedForeground: "#00325b",
            accent: "#0a84ff",
            floatingBorder: "#dddddd",
            floatingShadow: "#aaaaaa",
            previewPane: "#eef2f7",
            previewBar: "#ffffff",
            previewTaskbar: "#eeeeee",
            previewDock: "#ffffff",
            previewIcon: "#7c8290",
            role: function (name, fallback) {
                return fallback;
            }
        })
    SignalSpy {
        id: settingSpy
        signalName: "settingRequested"
    }

    TestCase {
        name: "SettingsPageContracts"
        when: windowShown

        function init() {
            failOnWarning(/ReferenceError|TypeError|Unable to assign|Binding loop|Cannot assign/);
        }
        function cleanup() {
            settingSpy.target = null;
            settingSpy.clear();
        }
        function makePage(name) {
            const component = Qt.createComponent("../../pages/" + name + ".qml");
            compare(component.status, Component.Ready, component.errorString());
            const properties = {
                colors: harness.palette,
                width: 700
            };
            const page = createTemporaryObject(component, harness, properties);
            verify(page !== null, component.errorString());
            return page;
        }
        function test_isolated_load_data() {
            return ["FgSchedSettingsPage", "IntegrationStatusPage", "DockSettingsPage", "IconAppearanceSection", "WindowAnimationSettingsPage", "ThemeSettingsPage", "ShortcutsSettingsPage", "LauncherSettingsPage", "ResourceSchedulingSettings"].map(name => ({
                        tag: name,
                        name: name
                    }));
        }
        function test_isolated_load(data) {
            const page = makePage(data.name);
            if (data.name === "ResourceSchedulingSettings") {
                compare(page.implicitHeight, 0, "unavailable scheduler hides resource controls");
                page.snapshot = {
                    resourceSchedulingAvailable: true
                };
            }
            tryVerify(() => page.implicitHeight > 0);
        }
        function test_theme_keeps_supported_language_choices() {
            const page = makePage("ThemeSettingsPage");
            verify(page.isValidLanguage("auto"));
            verify(page.isValidLanguage("zh-CN"));
            verify(page.isValidLanguage("en"));
            verify(!page.isValidLanguage("legacy"));
        }
        function test_navigation_releases_inactive_pages() {
            const component = Qt.createComponent("../../main.qml");
            compare(component.status, Component.Ready, component.errorString());
            const app = createTemporaryObject(component, harness, {
                currentPage: 1
            });
            verify(app !== null, component.errorString());
            const routes = [[1, "ThemeSettingsPageLoader"], [3, "DockSettingsPageLoader"], [4, "LauncherSettingsPageLoader"], [5, "ShortcutsSettingsPageLoader"], [6, "IntegrationStatusPageLoader"], [9, "FgSchedSettingsPageLoader"], [10, "windowPageLoader"], [1, "ThemeSettingsPageLoader"]];
            let previous = null;
            for (const route of routes) {
                app.currentPage = route[0];
                const loader = findChild(app.contentItem, route[1]);
                verify(loader !== null, route[1]);
                tryVerify(() => loader.item !== null, 3000);
                compare(loader.status, Loader.Ready);
                verify(loader.visible);
                if (previous !== null) {
                    tryVerify(() => previous.item === null);
                    verify(!previous.visible, "inactive page must not leave a layout gap");
                }
                previous = loader;
            }
        }
    }
}
