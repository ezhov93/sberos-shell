/*
    SPDX-FileCopyrightText: 2026 SberOS Shell contributors
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQml

QtObject {
    required property var items
    required property bool horizontal
    required property real availableLength
    required property real edgeMargin
    required property real gap
    required property real spacing
    property real toolBoxSize: 0

    readonly property var centerApplet: items.find(item => item.isOskaIsland) ?? null
    readonly property real leadingLength: sideLength(true)
    readonly property real trailingLength: sideLength(false)
    readonly property real leadingMinimum: sideLength(true, true)
    readonly property real trailingMinimum: sideLength(false, true)
    readonly property real centerLength: centerApplet ? Math.min(centerApplet.sizeHints.preferred,
        Math.max(centerApplet.sizeHints.minimum, availableLength - 2 * edgeMargin - 2 * gap
            - 2 * Math.max(leadingMinimum, trailingMinimum))) : 0
    readonly property real sideBudget: Math.max(0, (availableLength - 2 * edgeMargin - 2 * gap - centerLength) / 2)
    readonly property real allocatedLeading: Math.min(leadingLength, sideBudget)
    readonly property real allocatedTrailing: Math.min(trailingLength, sideBudget)
    // Keep the outside zones on the screen edges and put spare width beside
    // search. Each gap includes its mandatory GridLayout spacing separately.
    readonly property real leadingGap: gap + Math.max(0, sideBudget - allocatedLeading)
    readonly property real trailingGap: gap + Math.max(0, sideBudget - allocatedTrailing)
    readonly property real contentLength: {
        if (centerApplet && horizontal) {
            return 2 * edgeMargin + 2 * Math.max(leadingLength, trailingLength)
                + centerApplet.sizeHints.preferred + 2 * gap + toolBoxSize;
        }
        return 2 * edgeMargin + items.reduce((total, item) => total + item.sizeHints.preferred, 0)
            + Math.max(0, items.length - 1) * spacing + toolBoxSize;
    }

    function sideLength(beforeCenter, minimum = false) {
        if (!centerApplet) {
            return 0;
        }
        return items.filter(item => beforeCenter
            ? item.appletIndex < centerApplet.appletIndex : item.appletIndex > centerApplet.appletIndex)
            .reduce((total, item) => total + (minimum ? item.sizeHints.minimum : item.sizeHints.preferred)
                + spacing, 0);
    }
    function allocatedLength(item) {
        if (!centerApplet || !horizontal) return item.sizeHints.preferred;
        if (item === centerApplet) return centerLength;
        const before = item.appletIndex < centerApplet.appletIndex;
        const preferred = before ? leadingLength : trailingLength;
        const minimum = before ? leadingMinimum : trailingMinimum;
        const available = before ? allocatedLeading : allocatedTrailing;
        const fraction = preferred > minimum ? Math.max(0, Math.min(1, (available - minimum) / (preferred - minimum))) : 0;
        return item.sizeHints.minimum + (item.sizeHints.preferred - item.sizeHints.minimum) * fraction;
    }

}
