/* SPDX-License-Identifier: GPL-2.0-or-later */
import QtQml

QtObject {
    required property int count
    required property int launcherCount
    required property real availableLength
    property int normalCellSize: 48
    readonly property int compactCellSize: Math.round(normalCellSize * 5 / 6)
    readonly property int separatorSize: 8
    readonly property int padding: 8
    readonly property int preferredLength: Math.max(normalCellSize + 16, lengthFor(count, normalCellSize) + padding)
    readonly property bool compact: lengthFor(count, normalCellSize) + padding > availableLength
    readonly property int cellSize: compact ? compactCellSize : normalCellSize
    readonly property bool overflow: lengthFor(count, cellSize) + padding > availableLength
    readonly property int visibleCount: {
        if (!overflow) return count;
        let capacity = Math.max(0, Math.floor((availableLength - padding) / cellSize) - 1);
        if (lengthFor(capacity, cellSize) + cellSize + padding > availableLength) capacity--;
        return Math.max(0, Math.min(count, capacity));
    }
    readonly property int hiddenCount: count - visibleCount

    function lengthFor(items, size) {
        return items * size + (launcherCount > 0 && items > launcherCount ? separatorSize : 0);
    }
}
