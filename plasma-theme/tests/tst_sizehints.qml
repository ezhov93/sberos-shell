/* SPDX-License-Identifier: GPL-2.0-or-later */
import QtQuick
import QtQuick.Layouts
import QtTest
import "../plasmoids/sberos.panel/contents/ui" as Panel

TestCase {
    id: testCase
    name: "AppletSizeNegotiation"
    when: windowShown
    width: 800
    height: 120

    Item {
        id: applet
        implicitWidth: 240
        implicitHeight: 60
    }

    Panel.AppletSizeHints {
        id: hints
        applet: applet
        horizontal: true
        thickness: 72
    }

    function init() {
        hints.horizontal = true
        hints.thickness = 72
        applet.Layout.minimumWidth = 0
        applet.Layout.preferredWidth = -1
        applet.Layout.maximumWidth = Infinity
        applet.Layout.minimumHeight = 0
        applet.Layout.preferredHeight = -1
        applet.Layout.maximumHeight = Infinity
        applet.implicitWidth = 240
        applet.implicitHeight = 60
    }

    function test_naturalWidthDoesNotDependOnAllocation() {
        compare(hints.preferred, 240)
        applet.width = 20
        compare(hints.preferred, 240)
        applet.Layout.preferredWidth = 456
        compare(hints.preferred, 456)
        applet.Layout.preferredWidth = 720
        compare(hints.preferred, 720)
    }

    function test_explicitBounds() {
        applet.Layout.minimumWidth = 80
        applet.Layout.preferredWidth = 10
        compare(hints.preferred, 80)
        applet.Layout.maximumWidth = 200
        applet.Layout.preferredWidth = 400
        compare(hints.preferred, 200)
        applet.Layout.maximumWidth = 30
        compare(hints.maximum, 80)
        compare(hints.preferred, 80)
    }

    function test_heightDrivesWidth_data() {
        return [32, 48, 64, 72, 96, 120].map(size => ({ tag: String(size), size: size }))
    }

    function test_heightDrivesWidth(data) {
        hints.thickness = data.size
        applet.Layout.preferredWidth = Qt.binding(() => hints.thickness * 2 / 3)
        compare(hints.preferred, data.size * 2 / 3)
        applet.implicitWidth = 0
        applet.Layout.preferredWidth = -1
        compare(hints.preferred, data.size)
    }

    function test_verticalUsesHeightHints() {
        hints.horizontal = false
        applet.Layout.minimumHeight = 32
        applet.Layout.preferredHeight = 180
        applet.Layout.maximumHeight = 300
        compare(hints.minimum, 32)
        compare(hints.preferred, 180)
        compare(hints.maximum, 300)
        applet.Layout.preferredWidth = 900
        compare(hints.preferred, 180)
    }
}
