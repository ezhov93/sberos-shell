import QtQuick
import "pages" as Pages
import "components" as SettingsControls
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Sber.Core
import Sber.Controls as Sber
import Sber.Theme
import "../../shared/qml/foundation" as Foundation
import "../../shared/qml/i18n"

ApplicationWindow {
    id: window

    width: 1100
    height: 720
    // 最小宽 = 侧栏 260 + 滚动区边距 30×2 + 内容列 700:
    // 内容列已锁死 700 固定宽,窗口再窄只会截切,这里保证永远放得下。
    minimumWidth: 1020
    minimumHeight: 560
    visible: true
    title: I18n.tr("KOS settings")
    color: theme.background
    Component.onCompleted: Core.Settings.setThemeMode(Settings.System)
    // 永远无边框(CSD):顶部 30px 保留带承载拖拽/双击最大化/窗口按钮。
    // 按钮有两层:右上的自绘简单按钮(常驻、永远可点),以及 kos-bridge
    // 在 KOS 装饰器选中时盖印在完全相同位置上的不透明面板(其 KWin 输入
    // 过滤器先行拦截,点的是面板)。装饰器切走 → 面板消失 → 自绘按钮
    // 露出来接着用。窗口在任何装饰器下都保持同一形态,无切换逻辑。
    readonly property int chromeStrip: 30
    flags: Qt.Window | Qt.FramelessWindowHint

    property int currentPage: 1
    readonly property int displayedPage: pageMotion.displayedPage === "" ? currentPage : pageMotion.displayedPage
    property string searchText: ""

    Foundation.KosPageMotion {
        id: pageMotion
        page: window.currentPage
        onDisplayedPageChanged: {
            if (pageScroll)
                pageScroll.contentY = 0;
        }
    }

    // Qt updates SystemPalette when the desktop colour scheme changes. We use
    // it only to select the system appearance, then apply the matching iPadOS
    // palette so both modes keep a coherent Settings visual language.
    SystemPalette {
        id: systemPalette
        colorGroup: SystemPalette.Active
    }

    readonly property var notificationTheme: theme

    QtObject {
        id: theme

        readonly property bool dark: Core.Settings.IsDarkTheme
        // 窗口底色 + 左侧栏 = 同一块平面，右侧内容区是它上面一块圆角面板。
        // 底色沿用 #eff0f1（BreezeLight 的 Window/BackgroundNormal），历史原因:
        // 旧 SSD 形态下 kos-decoration 标题栏直接读 client palette 的这个颜色
        // （kwin/kos-decoration/kosdecoration.cpp:157）。窗口现已永远无边框
        // （见根窗口 flags 注释），没有标题栏衔接问题，但底色保持不变——
        // kos-bridge 的红绿灯面板从顶带像素取色着色，同色才融合。
        // **仍然不要随手改这个值**（2026-09-28 改过一次，裂出色差）。
        //   右侧面板 = #e3e5e7，即 Breeze 同组的 Window/BackgroundAlternate(227,229,231)
        // 圆角要看得见只能靠面板比底色深：ΔRGB (12,11,10)、对比度约 1.11:1。
        // （试过 #f2f2f7：ΔRGB 只有 (3,2,6)/1.023:1，肉眼分不出边界。加阴影已被否，
        //  因为读起来是"浮起"不是"分栏"。）
        // 深色沿用同一套结构：底色 #202326，右侧面板 #2a2d31（比底色浅一档，
        // 圆角才看得见），分组卡片 #1c1c1e 沉在面板里（面板 < 卡片的亮度，
        // 卡片才是"深黑"的那一层）。
        readonly property color background: Theme.Palette.Background.Default.Primary
        readonly property color sidebar: Theme.Palette.Background.Default.Primary
        readonly property color contentSurface: Theme.Palette.Background.Default.Secondary
        readonly property color primaryText: Theme.Palette.Text.Default.Primary
        readonly property color secondaryText: Theme.Palette.Text.Default.Secondary
        readonly property color tertiaryText: Theme.Palette.Text.Default.Secondary
        readonly property color card: Theme.Palette.Background.Default.Basic
        readonly property color separator: Theme.Palette.Outline.Default.SolidSecondary
        readonly property color divider: Theme.Palette.Outline.Default.SolidSecondary
        readonly property color searchField: Theme.Palette.Background.Default.Secondary
        readonly property color selected: Theme.Palette.Background.Default.Secondary
        // The container a selected item sits in. M3 carries selection with
        // secondaryContainer; the iPadOS form keeps the translucent wash.
        readonly property color selectedContainer: Theme.Palette.Background.Default.Secondary
        readonly property color sidebarHover: Theme.Palette.Background.Default.Secondary
        readonly property color chevron: Theme.Palette.Text.Default.Secondary
        readonly property color iconForeground: Theme.Palette.Text.Default.Primary
        // M3's navigation drawer carries a selected item as a secondaryContainer
        // pill with onSecondaryContainer ink, and leaves unselected icons
        // monochrome -- the coloured chip under each icon is the iPadOS form's
        // own furniture, so it only exists there.
        readonly property color iconMuted: Theme.Palette.Text.Default.Secondary
        readonly property color selectedForeground: Theme.Palette.Text.Default.Primary
        // Controls that take a single accent (sliders, switches) read this.
        readonly property color accent: Theme.Palette.Surface.Default.Accent
        readonly property color floatingBorder: Theme.Palette.Outline.Default.SolidSecondary
        readonly property color floatingShadow: dark ? Qt.rgba(0, 0, 0, 0.42) : Qt.rgba(0.17, 0.21, 0.30, 0.16)
        readonly property color previewPane: dark ? "#14151a" : "#eef2f7"
        readonly property color previewBar: dark ? "#2c2d35" : "#ffffff"
        readonly property color previewTaskbar: dark ? "#1e2028" : "#ffffff"
        readonly property color previewDock: dark ? "#323540" : "#ffffff"
        readonly property color previewIcon: dark ? "#a0a4b0" : "#7c8290"
    }

    // Whether the pages on screen came from a checkout -- which is also what
    // makes them hot-reloadable. Reported by the standalone bridge from the
    // entry point it loaded, not from the session it ends up talking to: a
    // .desktop launch (app grid, KRunner) shows the installed copy even when a
    // checkout Shell is the one answering IPC, and the banner must not claim
    // otherwise. A missing bridge (older binary, plain QML preview) reads as
    // false, which keeps the banner out of the way.
    readonly property bool sourceTreeEntry: (typeof settingsBridge !== "undefined") ? settingsBridge.sourceTreeEntry === true : false
    readonly property string sessionShellDir: (typeof settingsBridge !== "undefined") ? settingsBridge.sessionShellDir : ""

    // The banner states how this window was loaded, which closing it cannot
    // change -- so the close control hides the notice for this run only. The
    // flag lives on the bridge rather than here on purpose: every QML edit
    // rebuilds this window, and a banner that returns after each save would
    // defeat the control. Reopening Settings shows it again.
    readonly property bool developmentBannerVisible: window.sourceTreeEntry && !((typeof settingsBridge !== "undefined") ? settingsBridge.developmentBannerDismissed === true : false)

    function dismissDevelopmentBanner() {
        if (typeof settingsBridge !== "undefined")
            settingsBridge.developmentBannerDismissed = true;
    }

    readonly property var contentByPage: [
        {
            subtitle: I18n.tr("Show")
        },
        {
            subtitle: I18n.tr("Theme")
        },
        {
            subtitle: I18n.tr("Top bar")
        },
        {
            subtitle: "Dock"
        },
        {
            subtitle: I18n.tr("Launcher")
        },
        {
            subtitle: I18n.tr("Shortcuts")
        },
        {
            subtitle: I18n.tr("Integration status")
        },
        {
            subtitle: I18n.tr("Wallpaper")
        },
        {
            subtitle: I18n.tr("Services and components")
        },
        {
            subtitle: I18n.tr("Stage scheduling")
        },
        {
            subtitle: I18n.tr("Windows and animations")
        },
        {
            subtitle: I18n.tr("Notifications")
        },
        {
            subtitle: I18n.tr("Power")
        }
    ]

    // Shown only while a development session drives this window. Every value on
    // these pages then belongs to that session's own state directory: the
    // settings are live in the checkout Shell the user is looking at and are not
    // the ones the installed desktop reads at login. Conflating the two is the
    // mistake this banner exists to prevent.
    // Deliberately loud. A development window and the installed desktop render
    // identically, so this band is the only thing between "I just tuned my dock"
    // and "I just tuned a copy nobody logs into". A quiet note would be read as
    // decoration and skipped, which is exactly the outcome it exists to prevent.
    // Solid fill in fixed colours rather than theme tints: the contrast then
    // holds in either theme, and it cannot be mistaken for one more card.
    // Two short lines, not a paragraph: the warning has to land while the user
    // is looking past it at whatever they came here to change.
    component DevelopmentBanner: Rectangle {
        Layout.fillWidth: true
        Layout.bottomMargin: 22
        implicitHeight: bannerText.implicitHeight + 34
        radius: 16
        color: "#ff9f0a"

        Rectangle {
            id: bannerBadge
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 18
            width: 28
            height: 28
            radius: 14
            color: "#241700"

            Text {
                anchors.centerIn: parent
                text: "!"
                color: "#ff9f0a"
                font.pixelSize: 17
                font.weight: Font.Bold
            }
        }

        // Closing is not "never warn me again": a fresh window is a fresh load
        // and shows the banner again. This only clears the band out of the way
        // of someone who already knows, for as long as that window is open.
        Rectangle {
            id: bannerClose
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 14
            width: 28
            height: 28
            radius: 14
            color: bannerCloseHit.containsMouse ? Qt.rgba(0.14, 0.09, 0, 0.18) : "transparent"

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: "#241700"
                font.pixelSize: 15
                font.weight: Font.Bold
            }

            MouseArea {
                id: bannerCloseHit
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: window.dismissDevelopmentBanner()
            }
        }

        Column {
            id: bannerText
            anchors.left: bannerBadge.right
            anchors.right: bannerClose.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 14
            anchors.rightMargin: 12
            spacing: 3

            Text {
                text: I18n.tr("kos-settings developer hot-reload mode")
                color: "#241700"
                font.pixelSize: 17
                font.weight: Font.Bold
            }

            Text {
                width: parent.width
                text: I18n.tr("differs from the install mode loaded by the launcher")
                color: Qt.rgba(0.14, 0.09, 0, 0.78)
                font.pixelSize: 13
            }
        }
    }

    component SidebarEntry: Sber.Button {
        required property int pageIndex
        required property string label
        required property string navSymbol
        // Launch-only rows are plain links: no hover wash, no selection
        // state, the click runs the action instead of switching pages.
        property bool launchOnly: false
        signal launch
        Layout.preferredHeight: 36
        lineHeight: Theme.Sizes.LineHeight.Xs
        type: Sber.Widget.Default
        backgroundType: Sber.Widget.Clear
        property bool selected: !launchOnly && window.currentPage === pageIndex
        highlighted: selected
        hoverEnabled: !launchOnly
        visible: window.searchText.length === 0 || label.toLowerCase().indexOf(window.searchText.toLowerCase()) >= 0
        background: Rectangle {
            radius: Theme.Sizes.BorderRadius.Xs
            color: parent.selected ? Theme.Palette.Background.Default.Basic : (parent.hovered && !parent.launchOnly ? Theme.Palette.Background.Default.Secondary : "transparent")
        }
        contentItem: Item {
            implicitHeight: 36
            Rectangle {
                id: sidebarIconSurface
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: 28
                radius: Theme.Sizes.BorderRadius.Xs
                color: selected ? Theme.Palette.Background.Default.Secondary : "transparent"
            }
            SettingsControls.SettingIcon {
                id: sidebarIcon
                colors: window.notificationTheme
                anchors.centerIn: sidebarIconSurface
                size: 20
                symbol: navSymbol
                tint: Theme.Palette.Surface.Default.Accent
                highlighted: selected
            }
            Sber.Label {
                anchors.left: sidebarIconSurface.right
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: label
                color: Theme.Palette.Text.Default.Primary
                bold: selected
                elide: Text.ElideRight
            }
        }
        onClicked: {
            if (launchOnly) {
                launch();
                return;
            }
            window.currentPage = pageIndex;
        }
    }

    // ── 台前调度（fg-sched）页 ──────────────────────────────────────
    // 冻结默认全面停用：后台只做资源限制（nice/效率核/IO，异构才限核）。本页管理：
    // ① 冻结开关（重开时最小化窗口 180s 后 SIGSTOP）
    // ② "后台全资源运行"名单（never_demote_apps——名单内应用切后台后
    //    保持前台档参数，不降级不限核）
    // ③ 台前侧栏与切换动画的全部可调参数（stage-config IPC 实时生效）
    // 资源配置写 ~/.config/fg-sched/config.json，root 守护 mtime 轮询 ≤5s
    // 生效；动画/侧栏参数走 shell 的 stage-config IPC，即时生效。

    Item {
        anchors.fill: parent

        Rectangle {
            id: sidebar
            x: 0
            y: 0
            // The sidebar follows the settings mockup: a compact title/search area,
            // one continuous navigation list, and thin separators between groups.
            width: 260
            height: parent.height
            radius: 0
            color: theme.sidebar

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                anchors.topMargin: 34
                anchors.bottomMargin: 16
                spacing: 0

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    Layout.bottomMargin: 12
                    spacing: 10

                    Sber.Label {
                        text: "☰"
                        lineHeight: Theme.Sizes.LineHeight.M
                        Accessible.ignored: true
                    }

                    Sber.Label {
                        text: I18n.tr("Settings")
                        bold: true
                        lineHeight: Theme.Sizes.LineHeight.M
                        Layout.fillWidth: true
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    Layout.bottomMargin: 12

                    Sber.TextField {
                        anchors.fill: parent
                        placeholderText: I18n.tr("Search")
                        lineHeight: Theme.Sizes.LineHeight.Xs
                        text: window.searchText
                        iconLeft.name: "Search"
                        onTextEdited: window.searchText = text
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    SidebarEntry {
                        Layout.fillWidth: true
                        pageIndex: 1
                        label: I18n.tr("Theme")
                        navSymbol: "⚙"
                    }

                    SidebarEntry {
                        Layout.fillWidth: true
                        pageIndex: 10
                        label: I18n.tr("Windows and animations")
                        navSymbol: "⚙"
                    }

                    SidebarEntry {
                        Layout.fillWidth: true
                        pageIndex: 7
                        label: I18n.tr("Wallpaper")
                        navSymbol: "⚙"
                    }

                    SidebarEntry {
                        Layout.fillWidth: true
                        pageIndex: 3
                        label: I18n.tr("Dock")
                        navSymbol: "⚙"
                    }

                    SidebarEntry {
                        Layout.fillWidth: true
                        pageIndex: 12
                        label: I18n.tr("Power")
                        navSymbol: "⚙"
                    }

                    SidebarEntry {
                        Layout.fillWidth: true
                        pageIndex: 11
                        label: I18n.tr("Notifications")
                        navSymbol: "⚙"
                    }

                    SidebarEntry {
                        Layout.fillWidth: true
                        pageIndex: 4
                        label: I18n.tr("Launcher")
                        navSymbol: "⚙"
                    }

                    Rectangle {
                        visible: window.searchText.length === 0
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        Layout.topMargin: 8
                        Layout.bottomMargin: 8
                        color: theme.separator
                    }

                    SidebarEntry {
                        Layout.fillWidth: true
                        pageIndex: 5
                        label: I18n.tr("Shortcuts")
                        navSymbol: "⚙"
                    }

                    SidebarEntry {
                        Layout.fillWidth: true
                        pageIndex: 6
                        label: I18n.tr("Integration status")
                        navSymbol: "⚙"
                    }

                    SidebarEntry {
                        Layout.fillWidth: true
                        pageIndex: 8
                        label: I18n.tr("Services and components")
                        navSymbol: "⚙"
                    }

                    SidebarEntry {
                        Layout.fillWidth: true
                        pageIndex: 9
                        label: I18n.tr("Stage scheduling")
                        navSymbol: "⚙"
                    }

                    Rectangle {
                        visible: window.searchText.length === 0
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        Layout.topMargin: 8
                        Layout.bottomMargin: 8
                        color: theme.separator
                    }

                    SidebarEntry {
                        Layout.fillWidth: true
                        launchOnly: true
                        pageIndex: -1
                        label: I18n.tr("KDE System Settings")
                        navSymbol: "⚙"
                        onLaunch: settingsBridge.launchSystemSettings()
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }

        Rectangle {
            id: contentSurface
            // 右侧内容面顶天立地:从侧栏右缘一直铺到窗口上/右/下边缘,不留
            // inset、不做圆角——与侧栏形成两栏平面分割(窗口永远无边框,顶部
            // chromeStrip 保留带落在内容面色上,拖拽/红绿灯都在这一带)。
            x: sidebar.width
            y: 0
            width: parent.width - x
            height: parent.height
            color: theme.contentSurface

            Flickable {
                id: pageScroll
                opacity: pageMotion.progress
                enabled: pageMotion.interactive
                transform: Translate {
                    x: Foundation.AppTheme.reduceMotion ? 0 : 12 * (1 - pageMotion.progress)
                }
                objectName: "settings-page-scroll"
                anchors.fill: parent
                anchors.leftMargin: 30
                anchors.rightMargin: 30
                // 顶部让出 chromeStrip(拖拽带 + 红绿灯),页面标题落在带下缘。
                anchors.topMargin: 24 + window.chromeStrip
                anchors.bottomMargin: 24
                contentWidth: Math.max(width, pageContent.width)
                contentHeight: pageContent.implicitHeight
                clip: true
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                ColumnLayout {
                    id: pageContent
                    // 固定宽度:窗口缩放只改变两侧留白,内容列(含图片网格)
                    // 尺寸恒定,不触发网格重排/缩略图重生成。窗口窄于 700 时
                    // 由外层 Flickable 的横向滚动兜底(contentWidth 已取 max)。
                    width: 700
                    x: Math.max(0, Math.round((pageScroll.width - width) / 2))
                    spacing: 0

                    // Invisible rows are left out of a Layout, so an installed
                    // session shows no gap where this sits, and neither does a
                    // development one once the banner has been closed.
                    DevelopmentBanner {
                        visible: window.developmentBannerVisible
                    }

                    Sber.Label {
                        text: window.contentByPage[window.displayedPage].subtitle
                        bold: true
                        lineHeight: Theme.Sizes.LineHeight.L
                        Layout.bottomMargin: 18
                    }

                    // Every page used to be instantiated at startup, so its
                    // Component.onCompleted refresh spawned a `quickshell ipc
                    // call` on the UI thread; with the shell down that froze
                    // the window for tens of seconds. Each Loader now creates
                    // its page only when the page is first opened, and the
                    // refreshes themselves are asynchronous.
                    //
                    // `visible: active` is part of that contract, not
                    // decoration: deactivating a Loader destroys its item but
                    // leaves the Loader's own implicit size at whatever the
                    // page last measured, and a Layout skips only *invisible*
                    // items -- so without it a page the user has left keeps its
                    // whole height as a blank slab between the title and the
                    // page actually being shown.
                    Loader {
                        Layout.fillWidth: true
                        active: window.displayedPage === 12
                        visible: active
                        sourceComponent: Pages.PowerSettingsPage {
                            colors: window.notificationTheme
                            backend: typeof powerSettings !== "undefined" ? powerSettings : null
                        }
                    }

                    Loader {
                        Layout.fillWidth: true
                        active: window.displayedPage === 11
                        visible: active
                        sourceComponent: NotificationsSettingsPage {
                            theme: window.notificationTheme
                            bridge: typeof settingsBridge !== "undefined" ? settingsBridge : null
                        }
                    }

                    Loader {
                        Layout.fillWidth: true
                        objectName: "windowPageLoader"
                        active: window.displayedPage === 10
                        visible: active
                        sourceComponent: Pages.WindowAnimationSettingsPage {
                            colors: window.notificationTheme
                            backend: typeof windowSettings !== "undefined" ? windowSettings : null
                        }
                    }

                    Loader {
                        objectName: "LauncherSettingsPageLoader"
                        Layout.fillWidth: true
                        active: window.displayedPage === 4
                        visible: active
                        sourceComponent: Pages.LauncherSettingsPage {
                            colors: window.notificationTheme
                            bridge: typeof settingsBridge !== "undefined" ? settingsBridge : null
                        }
                    }

                    Loader {
                        objectName: "ShortcutsSettingsPageLoader"
                        Layout.fillWidth: true
                        active: window.displayedPage === 5
                        visible: active
                        sourceComponent: Pages.ShortcutsSettingsPage {
                            colors: window.notificationTheme
                            bridge: typeof settingsBridge !== "undefined" ? settingsBridge : null
                        }
                    }

                    Loader {
                        objectName: "IntegrationStatusPageLoader"
                        Layout.fillWidth: true
                        active: window.displayedPage === 6
                        visible: active
                        sourceComponent: Pages.IntegrationStatusPage {
                            colors: window.notificationTheme
                            bridge: typeof settingsBridge !== "undefined" ? settingsBridge : null
                        }
                    }

                    Loader {
                        objectName: "ServicesSettingsPageLoader"
                        Layout.fillWidth: true
                        active: window.displayedPage === 8
                        visible: active
                        sourceComponent: ServicesSettingsPage {
                            bridge: (typeof settingsBridge !== "undefined") ? settingsBridge : null
                            colors: theme
                        }
                    }

                    Loader {
                        Layout.fillWidth: true
                        active: window.displayedPage === 7
                        visible: active
                        sourceComponent: WallpaperSettingsPage {
                            scrollViewport: pageScroll
                            bridge: (typeof settingsBridge !== "undefined") ? settingsBridge : null
                            colors: theme
                            onDesktopPreviewFinished: {
                                window.showNormal();
                                window.requestActivate();
                            }
                        }
                    }

                    Loader {
                        objectName: "FgSchedSettingsPageLoader"
                        Layout.fillWidth: true
                        active: window.displayedPage === 9
                        visible: active
                        sourceComponent: Pages.FgSchedSettingsPage {
                            colors: window.notificationTheme
                            bridge: typeof settingsBridge !== "undefined" ? settingsBridge : null
                        }
                    }

                    Loader {
                        objectName: "DockSettingsPageLoader"
                        Layout.fillWidth: true
                        active: window.displayedPage === 3
                        visible: active
                        sourceComponent: Pages.DockSettingsPage {
                            colors: window.notificationTheme
                            bridge: typeof settingsBridge !== "undefined" ? settingsBridge : null
                        }
                    }

                    Loader {
                        objectName: "ThemeSettingsPageLoader"
                        Layout.fillWidth: true
                        active: window.displayedPage === 1
                        visible: active
                        sourceComponent: Pages.ThemeSettingsPage {
                            colors: window.notificationTheme
                            bridge: typeof settingsBridge !== "undefined" ? settingsBridge : null
                        }
                    }
                }

                // 设置页正文：浏览器式惯性滚动。禁用态（页面切换动画期间
                // enabled: pageMotion.interactive）会连同 wheel 一起失效。
                Foundation.KosKineticScroll {
                    flickable: pageScroll
                }
            }
        }

        // ── 窗口框(常驻,窗口永远无边框)────────────────────────────
        // 顶部保留带:整条可拖拽移动,双击切换最大化。移动手势必须在指针
        // 真正移动超过阈值后才启动:startSystemMove 会在合成器侧抓取指针
        // 手势,若在按下的瞬间就启动,双击的最大化请求会撞进进行中的手势,
        // KWin 的最大化摆放会整体偏移(顶缝/压 dock)。
        MouseArea {
            id: titlebarDrag
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: window.chromeStrip
            onPressed: mouse => {
                pressPos = Qt.point(mouse.x, mouse.y);
                moveArmed = true;
            }
            onPositionChanged: mouse => {
                if (!moveArmed)
                    return;
                if (Math.abs(mouse.x - pressPos.x) > 4 || Math.abs(mouse.y - pressPos.y) > 4) {
                    moveArmed = false;
                    window.startSystemMove();
                }
            }
            onDoubleClicked: {
                moveArmed = false;
                window.visibility === Window.Maximized ? window.showNormal() : window.showMaximized();
            }
            property point pressPos
            property bool moveArmed: false
        }

        // 自绘窗口按钮:几何与 bridge 面板对齐(offset 10,6 + padding 4.5),
        // KOS 装饰器选中时被面板完整盖住(输入走面板),面板不在时它们就是
        // 窗口控件。
        Row {
            anchors {
                right: parent.right
                rightMargin: 14.5   // 面板 offset.x 10 + panelPaddingX 4.5
                top: parent.top
                topMargin: 10.5     // offset.y 6 + panelPadding 4.5
            }
            spacing: 14
            Repeater {
                model: [
                    {
                        color: "#28c840",
                        act: "max"
                    },
                    {
                        color: "#febc2e",
                        act: "min"
                    },
                    {
                        color: "#ff5f57",
                        act: "close"
                    }
                ]
                delegate: Rectangle {
                    required property var modelData
                    width: 14
                    height: 14
                    radius: 7
                    color: modelData.color
                    opacity: 0.85
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: modelData.act === "min" ? window.showMinimized() : modelData.act === "max" ? (window.visibility === Window.Maximized ? window.showNormal() : window.showMaximized()) : window.close()
                    }
                }
            }
        }

        WindowResizeHandles {
            targetWindow: window
        }
    }
}
