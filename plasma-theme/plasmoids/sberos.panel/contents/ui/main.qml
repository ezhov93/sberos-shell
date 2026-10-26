/*
    SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2022 Niccolò Venerandi <niccolo@venerandi.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid

import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg as KSvg
import org.kde.plasma.components as PC3
import org.kde.kquickcontrolsaddons
import org.kde.draganddrop as DragDrop
import org.kde.kirigami as Kirigami

import "LayoutManager.js" as LayoutManager

ContainmentItem {
    id: root
    width: 640
    height: 40
    // filled in by the shell (Panel.qml) with the plasma-workspace PanelView
    property var panel: null

    property int panelThickness: root.panel ? root.panel.thickness : Plasmoid.configuration.panelThickness

    // Native mask is retained for KWin; Panel.qml leaves the gaps unpainted.
    Component.onCompleted: Plasmoid.backgroundHints = PlasmaCore.Types.StandardBackground

    onPanelThicknessChanged: {
        if(root.panel) {
            if(root.panel.userConfiguring) {
                Plasmoid.configuration.panelThickness = root.panel.thickness;
                Plasmoid.configuration.writeConfig();
            }
        }
    }
    onPanelChanged: {
        if(root.panel) {
            if (root.panel.thickness <= 0) {
                root.panel.thickness = Plasmoid.configuration.panelThickness;
            }
        }
    }

//BEGIN properties
    Layout.preferredWidth: fixedWidth || (root.isHorizontal ? root.panelLayout.contentLength : root.panelThickness)
    Layout.preferredHeight: fixedHeight || (root.isHorizontal ? root.panelThickness : root.panelLayout.contentLength)

    property Item toolBox
    property var layoutManager: LayoutManager

    property Item configOverlay

    property bool isHorizontal: Plasmoid.formFactor !== PlasmaCore.Types.Vertical
    readonly property SmartPanelTheme smartTheme: SmartPanelTheme {}
    readonly property color islandFill: smartTheme.shell
    readonly property color islandBorder: smartTheme.edge
    readonly property color islandInnerFill: smartTheme.inner
    readonly property real panelInset: panelThickness * 8 / 88
    readonly property real contentThickness: Math.max(1, panelThickness - 2 * panelInset)
    readonly property int islandEdgeMargin: Math.round(contentThickness * 16 / 72)
    readonly property int islandGap: Math.round(contentThickness * 8 / 72)
    readonly property var visibleApplets: currentLayout.visibleChildren.filter(item => item.isAppletContainer)
    readonly property PanelLayoutMetrics panelLayout: PanelLayoutMetrics {
        items: root.visibleApplets
        horizontal: root.isHorizontal
        availableLength: root.width
        edgeMargin: root.islandEdgeMargin
        gap: root.islandGap
        spacing: currentLayout.columnSpacing
        toolBoxSize: currentLayout.toolBoxSize
    }

    property Item desktopWallpaper: null
    readonly property var islandRects: {
        const shapes = [];
        for (const group of [sharedApplicationIsland, sharedSystemIsland]) {
            if (group.visible && group.width > 0) shapes.push({x:group.x, y:group.y, width:group.width, height:group.height, radius:group.radius});
        }
        for (const item of visibleApplets) {
            const name = item.applet?.plasmoid?.pluginName;
            if (dropArea.hasSharedApplicationIsland && dropArea.applicationIslandAppletNames.includes(name)) continue;
            if (dropArea.hasSharedSystemIsland && dropArea.systemIslandAppletNames.includes(name)) continue;
            shapes.push({x:currentLayout.x + item.x, y:currentLayout.y + item.y, width:item.width, height:item.height, radius:Math.min(24,item.height/3)});
        }
        return shapes;
    }

    property int fixedWidth: 0
    property int fixedHeight: 0
    // True when a widget is being drag and dropped within the panel.
    property bool dragAndDropping: false
    // True when e.g. the task manager is drag and dropping tasks.
    property bool appletRequestsInhibitDnD: false

//END properties

//BEGIN functions
    function plasmoidLocationString(): string {
        switch (Plasmoid.location) {
        case PlasmaCore.Types.LeftEdge:
            return "west";
        case PlasmaCore.Types.TopEdge:
            return "north";
        case PlasmaCore.Types.RightEdge:
            return "east";
        case PlasmaCore.Types.BottomEdge:
            return "south";
        }
        return "";
    }
//END functions

//BEGIN connections
    Containment.onAppletAdded: (applet, geometry) => {
        LayoutManager.addApplet(applet, geometry.x, geometry.y);
        // When a new preset panel is added, avoid calling save() multiple times
        Qt.callLater(LayoutManager.save);
    }

    Containment.onAppletRemoved: (applet) => {
        let plasmoidItem = root.itemFor(applet);
        if (plasmoidItem) {
            appletsModel.remove(plasmoidItem.parent.index);
        }
        LayoutManager.save();
    }

    Plasmoid.onUserConfiguringChanged: {
        if (!Plasmoid.userConfiguring) {
            if (root.configOverlay) {
                root.configOverlay.destroy();
                root.configOverlay = null;
            }
            return;
        }

        if (Plasmoid.immutable) {
            return;
        }

        Containment.applets.forEach(applet => applet.expanded = false);
        const component = Qt.createComponent("ConfigOverlay.qml");
        root.configOverlay = component.createObject(root, {
            "anchors.fill": dropArea,
            "anchors.rightMargin": root.isHorizontal ? toolBox.width : 0,
            "anchors.bottomMargin": !root.isHorizontal ? toolBox.height : 0,
        });
        component.destroy();
    }
//END connections

    DragDrop.DropArea {
        id: dropArea
        anchors.fill: parent

        // These are invisible and only used to read panel margins
        // Both will fallback to "standard" panel margins if the theme does not
        // define a normal or a thick margin.
        KSvg.FrameSvgItem {
            id: panelSvg
            visible: false
            imagePath: "widgets/panel-background"
            prefix: [root.plasmoidLocationString(), ""]
        }
        KSvg.FrameSvgItem {
            id: thickPanelSvg
            visible: false
            prefix: ['thick'].concat(panelSvg.prefix)
            imagePath: "widgets/panel-background"
        }

        readonly property var applicationIslandAppletNames: [
            "p-connor.plasma-drawer",
            "io.gitgud.wackyideas.smarttasks"
        ]
        readonly property var applicationIslandMembers: currentLayout.visibleChildren.filter(item =>
            item.isAppletContainer
                && applicationIslandAppletNames.indexOf(item.applet?.plasmoid?.pluginName) !== -1)
        readonly property bool hasSharedApplicationIsland: {
            if (!root.isHorizontal || applicationIslandMembers.length === 0) {
                return false;
            }

            let firstIndex = applicationIslandMembers[0].appletIndex;
            let lastIndex = firstIndex;
            for (const member of applicationIslandMembers) {
                firstIndex = Math.min(firstIndex, member.appletIndex);
                lastIndex = Math.max(lastIndex, member.appletIndex);
            }

            for (const item of currentLayout.visibleChildren) {
                if (item.isAppletContainer
                        && item.appletIndex > firstIndex
                        && item.appletIndex < lastIndex
                        && applicationIslandAppletNames.indexOf(item.applet?.plasmoid?.pluginName) === -1) {
                    return false;
                }
            }
            return true;
        }
        readonly property real applicationIslandLeft: {
            let value = Infinity;
            for (const member of applicationIslandMembers) {
                value = Math.min(value, member.x);
            }
            return value;
        }
        readonly property real applicationIslandRight: {
            let value = -Infinity;
            for (const member of applicationIslandMembers) {
                value = Math.max(value, member.x + member.width);
            }
            return value;
        }
        readonly property real applicationIslandTop: {
            let value = Infinity;
            for (const member of applicationIslandMembers) {
                value = Math.min(value, member.y);
            }
            return value;
        }
        readonly property real applicationIslandBottom: {
            let value = -Infinity;
            for (const member of applicationIslandMembers) {
                value = Math.max(value, member.y + member.height);
            }
            return value;
        }

        // Draw the launcher and task manager inside one applications surface.
        Rectangle {
            id: sharedApplicationIsland
            visible: dropArea.hasSharedApplicationIsland
            x: currentLayout.x + dropArea.applicationIslandLeft
            y: currentLayout.y + dropArea.applicationIslandTop
            width: Math.max(0, dropArea.applicationIslandRight - dropArea.applicationIslandLeft)
            height: Math.max(0, dropArea.applicationIslandBottom - dropArea.applicationIslandTop)
            radius: Math.min(24, height / 3)
            color: root.islandFill
            border.width: 1
            border.color: root.islandBorder

            Rectangle {
                anchors.fill: parent
                anchors.margins: Math.min(7, root.contentThickness * 7 / 72)
                radius: 16
                color: root.islandInnerFill
            }
        }

        readonly property var systemIslandAppletNames: [
            "KdeControlStation",
            "io.gitgud.wackyideas.clockcalendar"
        ]
        readonly property var systemIslandMembers: currentLayout.visibleChildren.filter(item =>
            item.isAppletContainer
                && systemIslandAppletNames.indexOf(item.applet?.plasmoid?.pluginName) !== -1)
        readonly property bool hasSharedSystemIsland: {
            if (!root.isHorizontal || systemIslandMembers.length === 0) {
                return false;
            }

            let firstIndex = systemIslandMembers[0].appletIndex;
            let lastIndex = firstIndex;
            for (const member of systemIslandMembers) {
                firstIndex = Math.min(firstIndex, member.appletIndex);
                lastIndex = Math.max(lastIndex, member.appletIndex);
            }

            for (const item of currentLayout.visibleChildren) {
                if (item.isAppletContainer
                        && item.appletIndex > firstIndex
                        && item.appletIndex < lastIndex
                        && systemIslandAppletNames.indexOf(item.applet?.plasmoid?.pluginName) === -1) {
                    return false;
                }
            }
            return true;
        }
        readonly property real systemIslandLeft: {
            let value = Infinity;
            for (const member of systemIslandMembers) {
                value = Math.min(value, member.x);
            }
            return value;
        }
        readonly property real systemIslandRight: {
            let value = -Infinity;
            for (const member of systemIslandMembers) {
                value = Math.max(value, member.x + member.width);
            }
            return value;
        }
        readonly property real systemIslandTop: {
            let value = Infinity;
            for (const member of systemIslandMembers) {
                value = Math.min(value, member.y);
            }
            return value;
        }
        readonly property real systemIslandBottom: {
            let value = -Infinity;
            for (const member of systemIslandMembers) {
                value = Math.max(value, member.y + member.height);
            }
            return value;
        }

        // Draw the system controls and clock applets inside one panel surface.
        Rectangle {
            id: sharedSystemIsland
            visible: dropArea.hasSharedSystemIsland
            x: currentLayout.x + dropArea.systemIslandLeft
            y: currentLayout.y + dropArea.systemIslandTop
            width: Math.max(0, dropArea.systemIslandRight - dropArea.systemIslandLeft)
            height: Math.max(0, dropArea.systemIslandBottom - dropArea.systemIslandTop)
            radius: Math.min(24, height / 3)
            color: root.islandFill
            border.width: 1
            border.color: root.islandBorder

            Rectangle {
                anchors.fill: parent
                anchors.margins: Math.min(7, root.contentThickness * 7 / 72)
                radius: 16
                color: root.islandInnerFill
            }
        }

        property bool marginAreasEnabled: panelSvg.margins != thickPanelSvg.margins
        property var marginHighlightSvg: KSvg.Svg{imagePath: "widgets/margins-highlight"}
        //Margins are either the size of the margins in the SVG, unless that prevents the panel from being at least half a smallMedium icon) tall at which point we set the margin to whatever allows it to be that...or if it still won't fit, 1.
        //the size a margin should be to force a panel to be the required size above
        readonly property real spacingAtMinSize: Math.floor(Math.max(1, (isHorizontal ? root.height : root.width) - Kirigami.Units.iconSizes.smallMedium)/2)

        Component.onCompleted: {
            LayoutManager.plasmoid = root.Plasmoid;
            LayoutManager.root = root;
            LayoutManager.layout = currentLayout;
            LayoutManager.marginHighlights = [];
            LayoutManager.appletsModel = appletsModel;
            LayoutManager.restore();

            root.Plasmoid.internalAction("configure").visible = Qt.binding(function() {
                return !root.Plasmoid.immutable;
            });
            root.Plasmoid.internalAction("configure").enabled = Qt.binding(function() {
                return !root.Plasmoid.immutable;
            });
        }

        onDragEnter: event => {
            if (Plasmoid.immutable || root.appletRequestsInhibitDnD) {
                event.ignore();
                return;
            }
            //during drag operations we disable panel auto resize
            root.fixedWidth = root.Layout.preferredWidth
            root.fixedHeight = root.Layout.preferredHeight
            appletsModel.insert(LayoutManager.indexAtCoordinates(event.x, event.y), {applet: dndSpacer})
        }

        onDragMove: event => {
            LayoutManager.move(dndSpacer.parent, LayoutManager.indexAtCoordinates(event.x, event.y));
        }

        onDragLeave: event => {
            /*
            * When reordering task items, dragLeave signal will be emitted directly
            * without dragEnter, and in this case parent.index is undefined, so also
            * check if dndSpacer is in appletsModel.
            */
            if (typeof(dndSpacer.parent.index) === "number") {
                if(dndSpacer.parent.index >= 0) appletsModel.remove(dndSpacer.parent.index);
                root.fixedWidth = root.fixedHeight = 0;
            }
        }

        onDrop: event => {
            if (Plasmoid.immutable) {
                event.ignore();
                return;
            }
            if(dndSpacer.parent.index > 0)
            appletsModel.remove(dndSpacer.parent.index);
            root.processMimeData(event.mimeData, event.x, event.y);
            event.accept(event.proposedAction);
            root.fixedWidth = root.fixedHeight = 0;
        }

//BEGIN components
        Component {
            id: appletContainerComponent
            // This loader conditionally manages the BusyIndicator, it's not
            // loading the applet. The applet becomes a regular child item.
            Item {
                id: container
                required property Item applet
                required property int index
                property Item dragging
                property bool isAppletContainer: true
                property bool isApplicationIsland: applet?.plasmoid?.pluginName === "io.gitgud.wackyideas.smarttasks"
                readonly property AppletSizeHints sizeHints: AppletSizeHints {
                    applet: container.applet
                    horizontal: root.isHorizontal
                    thickness: root.contentThickness
                }
                property bool isOskaIsland: applet?.plasmoid?.pluginName === "com.mcc45tr.filesearch"
                property bool isMarginSeparator: ((applet.plasmoid?.constraintHints & Plasmoid.MarginAreasSeparator) == Plasmoid.MarginAreasSeparator)
                property int appletIndex: index // To make sure it's always readable even inside other models
                property bool inThickArea: false
                visible: applet?.plasmoid?.pluginName !== "org.kde.plasma.panelspacer"
                    && (applet.plasmoid?.status !== PlasmaCore.Types.HiddenStatus
                        || (!Plasmoid.immutable && Plasmoid.userConfiguring) || Containment.corona.editMode)
                z: isOskaIsland ? 1 : 0

                Rectangle {
                    id: appletBackground
                    anchors.fill: parent
                    anchors.margins: 0
                    radius: Math.min(24, height / 3)
                    color: root.islandFill
                    border.width: 1
                    border.color: root.islandBorder
                    visible: root.isHorizontal
                        && applet?.plasmoid?.pluginName !== "org.kde.plasma.panelspacer"
                        && !container.isOskaIsland
                        && !(dropArea.hasSharedApplicationIsland
                             && dropArea.applicationIslandAppletNames.indexOf(applet?.plasmoid?.pluginName) !== -1)
                        && !(dropArea.hasSharedSystemIsland
                             && dropArea.systemIslandAppletNames.indexOf(applet?.plasmoid?.pluginName) !== -1)
                }

                //when the applet moves caused by its resize, don't animate.
                //this is completely heuristic, but looks way less "jumpy"
                property bool movingForResize: false

                function getMargins(side, returnAllMargins = false, overrideFillArea = null, overrideThickArea = null): real {
                    if (!applet || !applet.plasmoid) {
                        return 0;
                    }
                    //Margins are either the size of the margins in the SVG, unless that prevents the panel from being at least half a smallMedium icon + smallSpace) tall at which point we set the margin to whatever allows it to be that...or if it still won't fit, 1.
                    let fillArea = overrideFillArea === null ? applet && (applet.plasmoid.constraintHints & Plasmoid.CanFillArea) : overrideFillArea
                    let inThickArea = overrideThickArea === null ? container.inThickArea : overrideThickArea
                    var layout = {
                        top: isHorizontal, bottom: isHorizontal,
                        right: !isHorizontal, left: !isHorizontal
                    };
                    return ((layout[side] || returnAllMargins) && !fillArea) ? Math.round(Math.min(dropArea.spacingAtMinSize, (inThickArea ? thickPanelSvg.fixedMargins[side] : panelSvg.fixedMargins[side]))) : 0;
                }

                Layout.topMargin: !root.isHorizontal && appletIndex === root.visibleApplets[0]?.appletIndex ? root.islandEdgeMargin : 0
                Layout.bottomMargin: !root.isHorizontal && appletIndex === root.visibleApplets[root.visibleApplets.length - 1]?.appletIndex ? root.islandEdgeMargin : 0
                Layout.leftMargin: !root.isHorizontal ? 0
                    : appletIndex === root.visibleApplets[0]?.appletIndex
                        ? root.islandEdgeMargin
                    : isOskaIsland ? root.panelLayout.leadingGap : 0
                Layout.rightMargin: !root.isHorizontal ? 0
                    : appletIndex === root.visibleApplets[root.visibleApplets.length - 1]?.appletIndex
                        ? root.islandEdgeMargin
                    : isOskaIsland ? root.panelLayout.trailingGap : 0

                Layout.fillWidth: true
                Layout.fillHeight: true

                readonly property real allocatedSize: root.panelLayout.allocatedLength(container)
                readonly property real crossSize: root.contentThickness
                Layout.minimumWidth: root.isHorizontal ? sizeHints.minimum : crossSize
                Layout.minimumHeight: root.isHorizontal ? crossSize : sizeHints.minimum
                Layout.preferredWidth: root.isHorizontal ? allocatedSize : crossSize
                Layout.preferredHeight: root.isHorizontal ? crossSize : allocatedSize
                Layout.maximumWidth: root.isHorizontal ? (sizeHints.fill ? sizeHints.maximum : allocatedSize) : crossSize
                Layout.maximumHeight: root.isHorizontal ? crossSize : (sizeHints.fill ? sizeHints.maximum : allocatedSize)

                Item {
                    id: marginHighlightElements
                    anchors.fill: parent
                    // Unpositioned applets do not need a margin highlight.
                    opacity: Plasmoid.containment.corona.editMode && dropArea.marginAreasEnabled && !root.dragAndDropping && index != -1 ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }

                    component SideMargin: KSvg.SvgItem {
                        property string side; property bool fill: true
                        property int inset; property int padding
                        property var west: ({'left': 'top', 'top': 'left', 'right': 'top', 'bottom': 'left'})
                        property var mirror: ({'left': 'right', 'top': 'bottom', 'right': 'left', 'bottom': 'top'})
                        property var onComponentCompleted: {
                            let left = west[side]
                            let right = mirror[left]
                            let up = mirror[side]
                            anchors[up] = undefined
                            if (root.isHorizontal) {
                                height = padding;
                            } else {
                                width = padding;
                            }
                            anchors[left+'Margin'] = - currentLayout.rowSpacing/2 - (appletIndex == 0 ? dropArea.anchors[left + 'Margin'] + currentLayout.x : 0)
                            anchors[right+'Margin'] = - currentLayout.rowSpacing/2 - (appletIndex == appletsModel.count-1 ? dropArea.anchors[right + 'Margin'] + currentLayout.toolBoxSize : 0)
                            anchors[side+'Margin'] = - inset
                        }
                        elementId: fill ? 'fill' : (root.isHorizontal ? side + (inThickArea ? 'left' : 'right') : (inThickArea ? 'top' : 'bottom') + side)
                        svg: dropArea.marginHighlightSvg
                        anchors {top: parent.top; left: parent.left; right: parent.right; bottom: parent.bottom}
                    }
                    Repeater {
                        model: ['top', 'bottom', 'right', 'left']
                        SideMargin {
                            side: modelData
                            inset: container.getMargins(side)
                            visible: (modelData === 'top' || modelData === 'bottom') === root.isHorizontal
                            padding: container.getMargins(side, false, false, isMarginSeparator ? false : inThickArea)
                        }
                    }
                    Repeater {
                        model: ['top', 'bottom', 'right', 'left']
                        SideMargin {
                            side: modelData
                            inset: -container.getMargins(side, false, false, false)
                            padding: container.getMargins(side, false, false, true) + inset
                            visible: isMarginSeparator && (modelData === 'top' || modelData === 'bottom') === root.isHorizontal
                            fill: false
                        }
                    }
                }

                function closeOtherPopups() {
                    for (const other of root.visibleApplets) {
                        if (other === container) continue;
                        other.applet.expanded = false;
                        if (other.applet.applicationMenuOpen !== undefined) other.applet.applicationMenuOpen = false;
                    }
                }
                Connections {
                    target: container.applet
                    ignoreUnknownSignals: true
                    function onExpandedChanged() {
                        if (container.applet.expanded) container.closeOtherPopups();
                    }
                    function onApplicationMenuOpenChanged() {
                        if (container.applet.applicationMenuOpen) container.closeOtherPopups();
                    }
                }

                Binding {
                    target: container.applet
                    property: "workspaceWallpaper"
                    when: container.applet?.plasmoid?.pluginName === "p-connor.plasma-drawer"
                    value: root.desktopWallpaper
                }

                onAppletChanged: {
                    if (applet) {
                        applet.parent = container
                        applet.anchors.fill = container
                        applet.z = 60
                        //applet.Plasmoid.internalAction("configure").text = "Properties"

                    } else {
                        appletsModel.remove(index)
                    }
                }
                Loader {
                    anchors.fill: parent
                    active: container.applet && container.applet.Plasmoid.busy
                    sourceComponent: PC3.BusyIndicator {
                        z: 999
                    }
                }

                property int oldX: 0
                property int oldY: 0
                onXChanged: if (oldX) animateFrom(oldX, y)
                onYChanged: if (oldY) animateFrom(x, oldY)
                transform: Translate { id: translation }
                function animateFrom(xa, ya) {
                    if (isHorizontal) translation.x = xa - x
                    else translation.y = ya - y
                    oldX = oldY = 0
                    translAnim.running = true
                }
                NumberAnimation {
                    id: translAnim
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.OutCubic
                    target: translation
                    properties: "x,y"
                    to: 0
                }
            }
        }
//END components

//BEGIN UI elements

        anchors {
            leftMargin: 0//isHorizontal ? Math.min(dropArea.spacingAtMinSize, panelSvg.fixedMargins.left) : 0
            rightMargin: 0//isHorizontal ? Math.min(dropArea.spacingAtMinSize, panelSvg.fixedMargins.right) : 0
            topMargin: isHorizontal ? 0 : Math.min(dropArea.spacingAtMinSize, panelSvg.fixedMargins.top)
            bottomMargin: isHorizontal ? 0 : Math.min(dropArea.spacingAtMinSize, panelSvg.fixedMargins.bottom)
        }

        Item {
            id: dndSpacer
            property bool busy: false
            Layout.preferredWidth: width
            Layout.preferredHeight: height
            width: isHorizontal ? Kirigami.Units.iconSizes.sizeForLabels * 5 : currentLayout.width
            height: isHorizontal ? currentLayout.height : Kirigami.Units.iconSizes.sizeForLabels * 5
        }


        ListModel {
            id: appletsModel
        }


        GridLayout {
            id: currentLayout

            Repeater {
                model: appletsModel
                delegate: appletContainerComponent
            }

            rowSpacing: root.islandGap
            columnSpacing: root.islandGap

            x: Qt.application.layoutDirection === Qt.RightToLeft && isHorizontal ? toolBoxSize : 0;
            readonly property int toolBoxSize: !toolBox || !Plasmoid.containment.corona.editMode || Qt.application.layoutDirection === Qt.RightToLeft ? 0 : (isHorizontal ? toolBox.width : toolBox.height)

            property int horizontalDisplacement: dropArea.anchors.leftMargin + dropArea.anchors.rightMargin + (isHorizontal ? currentLayout.toolBoxSize : 0)
            property int verticalDisplacement: dropArea.anchors.topMargin + dropArea.anchors.bottomMargin + (isHorizontal ? 0 : currentLayout.toolBoxSize)

    // BEGIN BUG 454095: use lastSpacer to left align applets, as implicitWidth is updated too late
            width: root.width - horizontalDisplacement
            height: root.height - verticalDisplacement - (root.isHorizontal ? 2 * root.panelInset : 0)
            y: root.isHorizontal ? root.panelInset : 0

            Item {
                id: lastSpacer
                visible: false
                Layout.minimumWidth: 0
                Layout.preferredWidth: 0
                Layout.minimumHeight: 0
                Layout.preferredHeight: 0
                Layout.fillWidth: true
                Layout.fillHeight: true

                /**
                * This index will be used when adding a new panel.
                *
                * @see LayoutManager.indexAtCoordinates
                */
                readonly property alias index: appletsModel.count
            }
    // END BUG 454095

            rows: isHorizontal ? 1 : currentLayout.children.length
            columns: isHorizontal ? currentLayout.children.length : 1
            flow: isHorizontal ? GridLayout.LeftToRight : GridLayout.TopToBottom
            layoutDirection: Qt.application.layoutDirection
        }
    }
    MouseArea {
        anchors.fill: parent
        visible: !Plasmoid.immutable && Containment.corona.editMode && !Plasmoid.userConfiguring
        hoverEnabled: true
        onClicked: Plasmoid.internalAction("configure").trigger()
        Rectangle {
            anchors.fill: parent
            color: Kirigami.Theme.highlightColor
            opacity: 0.5
            visible: parent.containsMouse
        }
        PlasmaCore.ToolTipArea {
            id: toolTipArea
            anchors.fill: parent
            mainText: Plasmoid.internalAction("configure").text
            icon: "configure"
        }
        Accessible.name: Plasmoid.internalAction("configure").text
        Accessible.description: i18nd("plasma_shell_org.kde.plasma.desktop", "Open Panel configuration ui")
        Accessible.role: Accessible.Button
    }
//END UI elements
}
