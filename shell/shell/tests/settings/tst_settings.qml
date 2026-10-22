import QtQuick
import QtTest
import Sber.Core as SberCore
import Sber.Theme
import SircaShell

TestCase {
    name: "ShellSettings"
    when: windowShown
    function initTestCase() { failOnWarning(/.*(ReferenceError|TypeError|Binding loop|Cannot assign).*/) }
    property var settings
    function allItems(root, predicate) {
        let result = []
        if (predicate(root)) result.push(root)
        const children = root.contentItem ? [root.contentItem] : (root.children || [])
        for (const child of children) result = result.concat(allItems(child, predicate))
        return result
    }
    function find(predicate) { return allItems(settings, predicate)[0] }
    function init() {
        Shell.wallpapers = []
        Shell.config = ({mode: "light", panelLayout: "split"}); Shell.configRevision++
        const component = Qt.createComponent("Settings.qml")
        compare(component.status, Component.Ready, component.errorString())
        settings = component.createObject(null)
        verify(settings !== null)
        settings.openIt(0)
        wait(100)
    }
    function cleanup() { settings.close(); settings.destroy(); wait(20) }
    function test_sectionsAndTheme() {
        for (let page = 0; page < 6; page++) { settings.openIt(page); compare(settings.page, page); wait(30) }
        settings.openIt(99); compare(settings.page, 5)
        compare(SberCore.Core.Settings.IsDarkTheme, false)
        const light = Theme.Palette.Background.Default.Primary
        Shell.saveConfigKey("mode", "dark")
        tryCompare(SberCore.Core.Settings, "IsDarkTheme", true)
        verify(Theme.Palette.Background.Default.Primary !== light)
    }
    function test_pendingWritesAndReset() {
        settings.setKey("barHeight", 42, false)
        settings.setKey("dockIcon", 48, false)
        settings.page = 2
        compare(Shell.config.barHeight, 42)
        compare(Shell.config.dockIcon, 48)
        settings.setKey("dockHeight", 64, false)
        settings.close()
        compare(Shell.config.dockHeight, 64)
        settings.resetKey("dockIcon")
        verify(Shell.config.dockIcon === undefined)
        compare(Shell.config.dockHeight, 64)
    }
    function test_sliderPointerKeyboardAndExternalUpdate() {
        const slider = find(o => o.objectName === "setting-tintAlpha")
        verify(slider)
        const y = slider.height / 2
        mousePress(slider, 100, y)
        mouseMove(slider, 155, y, 20)
        mouseRelease(slider, 155, y)
        verify(Shell.config.tintAlpha >= 0 && Shell.config.tintAlpha <= 0.6)
        const rounded = Math.round(Shell.config.tintAlpha * 100) / 100
        fuzzyCompare(Shell.config.tintAlpha, rounded, 0.00001)
        Shell.saveConfigKey("tintAlpha", 0.2)
        tryCompare(slider, "value", 0.2)
        slider.forceActiveFocus()
        keyClick(Qt.Key_Right)
        tryVerify(() => Shell.config.tintAlpha > 0.2)
        Shell.saveConfigKey("tintAlpha", 0.1)
        tryCompare(slider, "value", 0.1)
    }
    function test_switchAndFocus() {
        settings.openIt(1)
        const toggle = find(o => o.checked !== undefined && o.indicatorWidth !== undefined)
        verify(toggle)
        toggle.forceActiveFocus()
        const previous = toggle.checked
        keyClick(Qt.Key_Space)
        compare(Shell.config.nativeTray, !previous)
        toggle.forceActiveFocus(Qt.TabFocusReason)
        keyClick(Qt.Key_Tab)
        verify(settings.activeFocusItem !== toggle)
        keyClick(Qt.Key_Backtab)
        compare(settings.activeFocusItem, toggle)
        wait(50) // Let the focus-driven scroll and layout reach the rendered frame.
        mouseClick(toggle, toggle.width - 8, toggle.height / 2)
        compare(Shell.config.nativeTray, previous)
    }
    function test_weatherAndWallpaper() {
        settings.openIt(1)
        const field = find(o => o.placeholderText === "Town or city")
        verify(field)
        field.text = "Moscow"
        field.accepted()
        const result = find(o => o.text === "Moscow, Test · RU")
        verify(result)
        result.clicked()
        compare(Shell.config.weatherLocation.name, "Moscow")
        compare(Shell.config.weatherLocation.lat, 55.75)
        compare(Shell.config.weather, true)
        compare(field.text, "")
        const wallpaper = Qt.resolvedUrl("wallpaper.svg").toString().replace("file://", "")
        Shell.wallpapers = [wallpaper]
        settings.openIt(4)
        wait(30)
        const preview = find(o => o.modelData === wallpaper)
        verify(preview)
        preview.clicked()
        compare(Shell.config.wallpaper, wallpaper)
        find(o => o.text === "Follow Plasma" && o.tapped !== undefined).clicked()
        verify(Shell.config.wallpaper === undefined)
    }
    function test_minimumSize() {
        settings.width = settings.minimumWidth
        settings.height = settings.minimumHeight
        for (let page = 0; page < 6; page++) {
            settings.openIt(page)
            wait(30)
            const controls = allItems(settings, o => o.visible && o.clicked !== undefined)
            for (const control of controls) {
                const pos = control.mapToItem(settings.contentItem, 0, 0)
                verify(pos.x >= 0 && pos.x + control.width <= settings.width + 1,
                    "Control overflows at minimum width: " + control.text)
            }
        }
    }
    function test_screenshots() {
        for (const mode of ["light", "dark"]) {
            Shell.saveConfigKey("mode", mode)
            for (const page of [0, 1, 2, 3, 4, 5]) {
                settings.openIt(page)
                wait(150)
                const image = grabImage(settings.contentItem)
                image.save("CAPTURE_DIR/settings-" + mode + "-" + page + ".png")
            }
        }
    }
}
