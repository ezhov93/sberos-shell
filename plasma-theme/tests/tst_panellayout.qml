/* SPDX-License-Identifier: GPL-2.0-or-later */
import QtQuick
import QtTest
import "../plasmoids/sberos.panel/contents/ui" as Panel

TestCase {
    name: "PanelContentSizing"

    Panel.PanelLayoutMetrics {
        id: metrics
        items: []
        horizontal: true
        availableLength: 1920
        edgeMargin: 16
        gap: 12
        spacing: 4
    }

    function applet(index, minimum, preferred, center = false) {
        return {appletIndex: index, isOskaIsland: center,
            sizeHints: {minimum: minimum, preferred: preferred}}
    }

    function init() {
        metrics.horizontal = true
        metrics.availableLength = 1920
        metrics.items = [applet(0, 72, 72), applet(1, 48, 48), applet(2, 64, 360),
                         applet(3, 216, 456, true), applet(4, 48, 48), applet(5, 144, 168)]
    }

    // One target only: mock 1920px scene. No scale/height/grid sweep.
    function test_targetMockLayout() {
        const items = metrics.items;
        const lengths = items.map(item => metrics.allocatedLength(item));
        const leading = lengths.slice(0, 3).reduce((a, b) => a + b, 0) + 3 * metrics.spacing;
        const trailing = lengths.slice(4).reduce((a, b) => a + b, 0) + 2 * metrics.spacing;
        const centerX = metrics.edgeMargin + leading + metrics.leadingGap + lengths[3] / 2;
        fuzzyCompare(centerX, 960, .001);
        const end = centerX + lengths[3] / 2 + metrics.trailingGap + trailing + metrics.edgeMargin;
        fuzzyCompare(end, 1920, .001);
        verify(metrics.leadingGap >= metrics.gap);
        verify(metrics.trailingGap >= metrics.gap);
    }

    function test_growAndShrink() {
        const original = metrics.items
        const originalLength = metrics.contentLength
        metrics.items = [original[0], original[1], applet(2, 64, 1800), ...original.slice(3)]
        verify(metrics.contentLength > originalLength)
        metrics.availableLength = 1920
        verify(metrics.allocatedLength(metrics.items[2]) < 1800)
        metrics.items = original
        compare(metrics.contentLength, originalLength)
    }

    function test_withoutSearchUsesSum() {
        metrics.items = [applet(0, 72, 72), applet(1, 48, 120)]
        compare(metrics.contentLength, 228)
    }

    function test_verticalUsesSum() {
        metrics.horizontal = false
        compare(metrics.contentLength, 1204)
    }
}
