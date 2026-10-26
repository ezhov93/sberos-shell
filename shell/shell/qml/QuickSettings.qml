// Quick Settings popup: charge and screenshot controls, conditional volume and brightness rows, and the eight Smart Panel
// tiles. Device details remain in the Network and Sound pages; system state comes from the available KDE/UPower backends.
import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.kcmutils                                  // KCMLauncher
import org.kde.notificationmanager as NotificationManager
import Sber.Controls as Sber
import Sber.Theme
import SircaShell
import "Glass"
import "control" as Control

Item {
    id: qs
    property bool expanded: false
    signal closeRequested
    onExpandedChanged: if (!expanded) {
        page = "main";
        shownPage = "main";
        arranging = false;
    }
    // our own sliders drive the bar's volume display DIRECTLY while they move (the normal route, PulseAudio -> plasmashell ->
    // D-Bus -> the bar, trails the pointer by a round trip per step)
    signal osdRequested(string icon, real fraction)
    property string page: "main"                       // "main" | "sound" | "network": decides the SIZE at once
    // what is VISIBLE follows a beat later: the old page fades out, the popup is already resizing (the bar animates the
    // lobe towards implicitHeight; no second animation here, two chained ones made the resize trail behind the content),
    // and the new page fades in while the glass edge is still moving, so content and panel arrive together.
    property string shownPage: "main"
    onPageChanged: {
        if (shownPage !== page) {
            shownPage = "";
            pageIn.restart();
        }
    }
    Timer {
        id: pageIn
        interval: 110
        onTriggered: qs.shownPage = qs.page
    }
    implicitWidth: 488
    implicitHeight: (page === "sound" ? soundPage.implicitHeight : page === "network" ? netPage.implicitHeight : mainPage.implicitHeight) + topPad + bottomPad
    readonly property int pad: 16
    readonly property int topPad: 15
    readonly property int bottomPad: 21
    readonly property int gap: 8
    readonly property color tileSurface: Config.dark ? Qt.rgba(43 / 255, 50 / 255, 59 / 255, 0.92) : Qt.rgba(1, 1, 1, 0.92)
    readonly property color tileActiveSurface: "#54b7b1"
    readonly property color tileHoverSurface: Config.dark ? "#363e48" : "#ebedf2"
    readonly property color tileInactiveIconSurface: "#e8eaf0"
    readonly property color tileOutline: Qt.rgba(1, 1, 1, 0.06)
    readonly property color primaryText: Config.dark ? "#e5e8ed" : "#484c5b"
    readonly property color secondaryText: Config.dark ? "#959ba8" : "#9296a6"

    // ---------- backends ----------
    // Everything that comes from a PRIVATE Plasma module (network, Bluetooth, brightness, night light, sound) is its own
    // small file loaded by URL: when one of those modules is missing or has changed after a Plasma update, that Loader
    // fails and only its tile / slider degrades ("Unavailable"), instead of this whole popup refusing to load.
    NotificationManager.Settings {
        id: notif
    }
    Loader {
        id: nightL
        source: "control/NightLight.qml"
        onStatusChanged: if (status === Loader.Error)
            console.warn("quick settings: night light unavailable")
    }
    Loader {
        id: netL
        source: "NetworkBackend.qml"
        onStatusChanged: if (status === Loader.Error)
            console.warn("quick settings: network unavailable (org.kde.plasma.networkmanagement)")
    }
    Loader {
        id: btL
        source: "BluetoothBackend.qml"
        onStatusChanged: if (status === Loader.Error)
            console.warn("quick settings: Bluetooth unavailable (org.kde.bluezqt)")
    }
    Loader {
        id: brL
        source: "BrightnessBackend.qml"
        onStatusChanged: if (status === Loader.Error)
            console.warn("quick settings: brightness unavailable (org.kde.plasma.private.brightnesscontrolplugin)")
    }
    Loader {
        id: volL
        source: "VolumeBackend.qml"
        onStatusChanged: if (status === Loader.Error)
            console.warn("quick settings: sound unavailable (org.kde.plasma.private.volume)")
    }
    // the shell's own types (system-bus power, idle inhibit, the sun schedule): always there, they report "absent" themselves
    PowerProfiles {
        id: power
    }
    BatteryInfo {
        id: battery
    }
    property bool busy: false                          // bound by the bar (bar.busy): a full-screen window or a game has focus
    QSCaffeine {
        id: caffeine
        busy: qs.busy
    }
    readonly property var night: nightL.item
    readonly property var net: netL.item
    readonly property var bt: btL.item
    readonly property var bright: brL.item
    readonly property var vol: volL.item
    readonly property bool canDim: bright ? bright.canDim : false
    readonly property bool hasSink: vol ? vol.hasSink : false
    readonly property int volumePct: vol ? vol.pct : 0
    function volIcon() {
        if (!hasSink || vol.muted || volumePct === 0)
            return "audio-volume-muted-symbolic";
        return volumePct < 34 ? "audio-volume-low-symbolic" : volumePct < 67 ? "audio-volume-medium-symbolic" : "audio-volume-high-symbolic";
    }
    readonly property bool hasSource: vol ? vol.hasSource : false
    readonly property bool micMuted: vol ? vol.micMuted : false
    readonly property int micUsers: vol ? vol.recording : 0
    readonly property string micStatus: !hasSource ? "" : micMuted ? "Muted" : micUsers > 0 ? "In use by " + ((vol.recorderNames || []).join(", ") || (micUsers + (micUsers === 1 ? " app" : " apps"))) : "On"
    // power profile: the name, and on battery the time left ("Balanced · 2 h 10 min left")
    function spell(sec) {
        if (sec <= 0)
            return "";
        const h = Math.floor(sec / 3600), m = Math.round((sec % 3600) / 60);
        return h > 0 ? h + " h " + (m > 0 ? m + " min" : "") : m + " min";
    }
    readonly property string powerStatus: {
        if (!power.available)
            return "Unavailable";
        let t = power.label(power.active);
        if (battery.present && !battery.charging && battery.timeToEmpty > 0)
            t += " · " + spell(battery.timeToEmpty) + " left";
        else if (battery.present && battery.charging && !battery.full && battery.timeToFull > 0)
            t += " · " + spell(battery.timeToFull) + " to full";
        if (power.degraded !== "")
            t += " · limited";
        return t;
    }

    readonly property bool wifiThere: net ? net.wifiThere : false
    readonly property bool wifiOn: net ? net.wifiOn : false
    readonly property string netName: net ? net.name : ""
    readonly property bool btOn: bt ? bt.on : false
    readonly property string btName: bt ? bt.name : ""
    // Do Not Disturb, timed. One tile, a tap moves on: off -> for an hour -> until tomorrow morning -> until switched off -> off.
    // The status line says which one it is ("Until 19:40"). `dndTick` makes the tile notice when a timed one runs out.
    property int dndTick: 0
    Timer {
        interval: 20000
        running: true
        repeat: true
        onTriggered: qs.dndTick++
    }
    readonly property var dndUntil: {
        qs.dndTick;
        const u = notif.notificationsInhibitedUntil;
        return (u instanceof Date && !isNaN(u.getTime()) && Date.now() < u.getTime()) ? u : null;
    }
    readonly property bool dndOn: notif.notificationsInhibitedByApplication || dndUntil !== null
    readonly property string dndStatus: {
        if (!dndOn)
            return "Off";
        if (!dndUntil)
            return "On";
        const left = dndUntil.getTime() - Date.now();
        if (left > 300 * 86400000)
            return "On";
        const sameDay = dndUntil.toDateString() === new Date().toDateString();
        return "Until " + (sameDay ? "" : "tomorrow ") + Qt.formatTime(dndUntil, "hh:mm");
    }
    function toggleBt() {
        if (bt)
            bt.toggle();
    }
    function toggleDnd() {
        const now = new Date(), left = dndUntil ? dndUntil.getTime() - now.getTime() : 0;
        let until;
        if (!dndOn) {
            until = new Date(now.getTime() + 3600000);
        }                                                  // for an hour
        else if (dndUntil && left <= 3660000) {
            until = new Date(now);
            until.setHours(8, 0, 0, 0);
            if (until <= now)
                until.setDate(until.getDate() + 1);     // until the morning
            if (until.getTime() - now.getTime() <= 3660000)
                until.setDate(until.getDate() + 1);
        }                   // (it is almost 8 already: the next one)
        else if (dndUntil && left < 300 * 86400000) {
            until = new Date(now);
            until.setFullYear(until.getFullYear() + 1);
        }   // until switched off
        else {
            until = undefined;
            notif.revokeApplicationInhibitions();
        }
        notif.notificationsInhibitedUntil = until;
        notif.save();
        qs.dndTick++;
    }
    function openKcm(name) {
        KCMLauncher.openSystemSettings(name);
        qs.closeRequested();
    }

    // ---- tiles as data; the volume and brightness rows stay above the required eight tiles
    readonly property var allTiles: ["network", "vpn", "bluetooth", "power", "oskaNotifications", "nightlight", "airplane", "theme"]
    readonly property var barTiles: ["volume", "network", "bluetooth", "dnd", "nightlight", "power", "caffeine", "mic"]   // what BarTile can place in the bar
    readonly property var allIds: allTiles.concat(["sliders"])
    // (a list from the config arrives as a sequence wrapper, not a JS Array: Array.isArray is false for it, hence the length test)
    readonly property var tileOrder: {
        const v = Config.get("qsTiles", null);
        const saved = v && v.length !== undefined ? Array.prototype.slice.call(v).filter(x => allIds.indexOf(x) >= 0) : [];
        const savedTiles = saved.filter(x => allTiles.indexOf(x) >= 0);
        const ordered = allTiles.every(x => savedTiles.indexOf(x) >= 0) ? savedTiles : allTiles;
        const rows = saved.filter(x => allTiles.indexOf(x) < 0);
        return ordered.concat(rows.length > 0 ? rows : ["sliders"]);
    }
    readonly property var gridTiles: tileOrder.filter(x => allTiles.indexOf(x) >= 0)
    function rowShown(id) {
        return (arranging ? arrangeOn : tileOrder).indexOf(id) >= 0;
    }
    // every property a tile needs, read from the backends: the binding re-evaluates when any of them changes
    function tileData(id) {
        switch (id) {
        case "network":
            return {
                available: true,
                enabled: !!net && wifiThere,
                icon: net ? net.icon : "network-wired-symbolic",
                title: "Wi-Fi",
                on: wifiOn,
                more: !!net,
                status: !net || !wifiThere ? "Недоступно" : netName !== "" ? netName : (wifiOn ? "Вкл." : "Выкл.")
            };
        case "bluetooth":
            return {
                available: true,
                enabled: !!bt,
                icon: btOn ? "network-bluetooth-activated-symbolic" : "network-bluetooth-inactive-symbolic",
                title: "Bluetooth",
                on: btOn,
                more: true,
                status: !bt ? "Недоступно" : !btOn ? "Выкл." : (btName !== "" ? btName : "Вкл.")
            };
        case "theme":
            return {
                available: true,
                enabled: true,
                icon: "weather-clear-night-symbolic",
                title: "Тёмный стиль",
                status: Config.dark ? "Вкл." : "Выкл.",
                on: Config.dark,
                more: false
            };
        case "oskaNotifications":
            return {
                available: true,
                enabled: false,
                icon: "notifications-symbolic",
                title: "Уведомления",
                status: "Недоступно",
                on: false,
                more: false
            };
        // a tap cycles only profiles reported by power-profiles-daemon.
        case "power":
            return {
                available: true,
                enabled: power.available,
                icon: power.icon(power.active),
                title: "Режим питания",
                status: !power.available ? "Недоступно" : power.active === "power-saver" ? "Энергосберегающий" : power.active === "performance" ? "Производительный" : "Сбалансированный",
                on: power.available && power.active !== "balanced",
                more: true
            };
        case "vpn":
            return {
                available: true,
                enabled: !!net,
                icon: "network-vpn-symbolic",
                title: "VPN",
                status: !net ? "Недоступно" : net.activeVpn !== "" ? net.activeVpn : "Выкл.",
                on: !!net && net.activeVpn !== "",
                more: !!net
            };
        case "nightlight":
            return {
                available: true,
                enabled: !!night,
                icon: "redshift-status-on",
                title: "Ночной свет",
                status: night ? (night.on ? "Вкл." : "Выкл.") : "Недоступно",
                on: night ? night.on : false,
                more: false
            };
        case "airplane":
            return {
                available: true,
                enabled: false,
                icon: "airplane-mode-symbolic",
                title: "Авиарежим",
                status: "Недоступно",
                on: false,
                more: false
            };
        // Keep these existing independent panel widgets available; Do Not Disturb does not back the Oska tile.
        case "dnd":
            return {
                available: true,
                icon: dndOn ? "notifications-disabled-symbolic" : "notifications-symbolic",
                title: qsTr("Do Not Disturb"),
                status: dndStatus,
                on: dndOn,
                more: false
            };
        case "caffeine":
            return {
                available: true,
                icon: caffeine.active ? "system-suspend-inhibited" : "system-suspend-uninhibited",
                title: qsTr("Caffeine"),
                status: caffeine.status,
                on: caffeine.active,
                more: false
            };
        case "mic":
            return {
                available: hasSource,
                icon: micMuted ? "mic-off-symbolic" : "mic-on-symbolic",
                title: qsTr("Microphone"),
                status: micStatus,
                on: hasSource && !micMuted,
                more: true
            };
        case "volume":
            return {
                available: hasSink,
                icon: volIcon(),
                title: "Volume",
                status: hasSink ? (vol.muted ? "Muted" : volumePct + " %") : "",
                on: hasSink && !vol.muted,
                more: true
            };
        }
        return {
            available: false,
            icon: "",
            title: id,
            status: "",
            on: false,
            more: false
        };
    }
    function tileToggle(id) {
        switch (id) {
        case "network":
            if (net && wifiThere)
                net.enableWireless(!wifiOn);
            break;
        case "bluetooth":
            toggleBt();
            break;
        case "theme":
            {
                const want = Config.dark ? "light" : "dark";
                Shell.saveConfigKey("mode", want);
                break;
            }
        case "vpn":
            page = "network";
            break;
        case "dnd":
            toggleDnd();
            break;
        case "nightlight":
            if (night)
                night.toggle();
            break;
        case "power":
            power.cycle();
            break;
        case "caffeine":
            caffeine.toggle();
            break;
        case "mic":
            if (vol)
                vol.toggleMicMute();
            break;
        case "volume":
            if (vol)
                vol.toggleMute();
            break;
        }
    }
    function tileOpen(id) {
        switch (id) {
        case "network":
            if (net)
                page = "network";
            break;
        case "bluetooth":
            openKcm("kcm_bluetooth");
            break;
        case "vpn":
            if (net)
                page = "network";
            break;
        case "nightlight":
            openKcm("kcm_nightlight");
            break;
        case "power":
            openKcm("kcm_powerdevilprofilesconfig");
            break;
        case "mic":
            page = "sound";
            break;
        case "volume":
            page = "sound";
            break;
        }
    }
    // the bar's tile widgets: what a click does is the user's ("barTileClick": { volume: "page" | "toggle", ... }); a page
    // opens the quick settings on it, toggle is the tile's own action. Defaults: volume and network open their page.
    function tileClickMode(id) {
        const m = Config.get("barTileClick", {}) || {};
        if (m[id] === "page" || m[id] === "toggle")
            return m[id];
        return (id === "volume" || id === "network") ? "page" : "toggle";
    }
    function tilePage(id) {
        switch (id) {
        case "volume":
        case "mic":
            return "sound";
        case "network":
            return "network";
        default:
            return "";
        }
    }
    // ---- arranging (right-click a tile): a working copy of the list until Done
    property bool arranging: false
    property var arrangeOn: []                                 // the shown ids, in order, while arranging
    readonly property var arrangeList: arrangeOn.filter(x => allTiles.indexOf(x) >= 0).concat(allTiles.filter(x => arrangeOn.indexOf(x) < 0))   // shown first, hidden after
    onArrangingChanged: if (arranging)
        arrangeOn = tileOrder.slice()
    function arrangeSet(id, on) {
        const l = arrangeOn.filter(x => x !== id);
        if (on) {
            if (allTiles.indexOf(id) >= 0)
                l.splice(l.filter(x => allTiles.indexOf(x) >= 0).length, 0, id);
            else
                l.push(id);
        }
        arrangeOn = l;
    }
    function arrangeMove(id, slot) {
        if (arrangeOn.indexOf(id) < 0)
            return;
        const tiles = arrangeOn.filter(x => allTiles.indexOf(x) >= 0 && x !== id);
        const rows = arrangeOn.filter(x => allTiles.indexOf(x) < 0);
        tiles.splice(Math.max(0, Math.min(tiles.length, slot)), 0, id);
        arrangeOn = tiles.concat(rows);
    }
    function arrangeDone() {
        const l = arrangeOn.slice();
        arranging = false;
        Shell.saveConfigKey("qsTiles", l);
    }

    // ---------- parts ----------
    component RoundBtn: Item {
        id: rb
        property string icon
        property string fallbackIcon: ""
        property int size: 34
        property int radius: size / 2
        signal tapped
        width: size
        height: size
        Rectangle {
            anchors.fill: parent
            radius: rb.radius
            color: rbh.hovered ? qs.tileHoverSurface : qs.tileSurface
            border.width: 1
            border.color: qs.tileOutline
            Behavior on color {
                ColorAnimation {
                    duration: Config.quick
                }
            }
        }
        Kirigami.Icon {
            anchors.centerIn: parent
            width: Math.round(rb.size * 0.47)
            height: width
            source: rb.icon
            fallback: rb.fallbackIcon
            isMask: true
            color: Config.fgSolid
            opacity: 0.9
            roundToIconSize: false
        }
        HoverHandler {
            id: rbh
        }
        TapHandler {
            id: rt
            onTapped: rb.tapped()
        }
    }

    // the arranging badge: minus on a shown item, plus on a hidden one; the ring is the panel's own colour so it reads as cut out
    component ArrBadge: Rectangle {
        id: ab
        property string tid
        readonly property bool shown: qs.arrangeOn.indexOf(tid) >= 0
        visible: qs.arranging
        x: parent.width - 11
        y: -7
        width: 22
        height: 22
        radius: 11
        z: 3
        color: shown ? Config.attention : Config.onFill
        border.width: 2
        border.color: Config.dark ? Qt.rgba(0.1, 0.1, 0.12, 1) : Qt.rgba(0.96, 0.96, 0.97, 1)   // literal-ok: the badge's ring is the panel's colour
        Rectangle {
            anchors.centerIn: parent
            width: 10
            height: 2
            radius: 1
            color: Config.onFg
        }
        Rectangle {
            anchors.centerIn: parent
            width: 2
            height: 10
            radius: 1
            color: Config.onFg
            visible: !ab.shown
        }
        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: qs.arrangeSet(ab.tid, !ab.shown)
        }
    }
    component Tile: Item {
        id: tile
        property string icon
        property string title
        property string status: ""
        property bool on: false
        property bool more: false
        property bool enabled_: true
        signal toggled
        signal opened
        height: 56
        opacity: enabled_ ? 1 : 0.55
        activeFocusOnTab: true
        Accessible.role: Accessible.Button
        Accessible.name: title + (status !== "" ? ", " + status : "")
        Keys.onReturnPressed: if (enabled_)
            toggled()
        Keys.onSpacePressed: if (enabled_)
            toggled()
        Rectangle {
            anchors.fill: parent
            radius: 17
            color: th.hovered && tile.enabled_ ? qs.tileHoverSurface : qs.tileSurface
            border.width: 1
            border.color: qs.tileOutline
            Behavior on color {
                ColorAnimation {
                    duration: Config.quick
                }
            }
        }
        Rectangle {
            id: bubble
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 32
            height: 32
            radius: 16
            color: tile.on ? qs.tileActiveSurface : qs.tileInactiveIconSurface
            scale: tt.pressed ? 0.92 : 1
            Behavior on color {
                ColorAnimation {
                    duration: Config.normal
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: Config.quick
                }
            }
            Kirigami.Icon {
                anchors.centerIn: parent
                width: 16
                height: 16
                source: tile.icon
                isMask: true
                roundToIconSize: false
                color: tile.on ? Theme.Palette.Text.OnDark.Primary : qs.primaryText
            }
        }
        Column {
            anchors.left: bubble.right
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: tile.more ? 30 : 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1
            Text {
                width: parent.width
                text: tile.title
                color: qs.primaryText
                font.pixelSize: 16
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Text {
                width: parent.width
                text: tile.status
                visible: text !== ""
                color: qs.secondaryText
                font.pixelSize: 12
                elide: Text.ElideRight
            }
        }
        HoverHandler {
            id: th
        }
        TapHandler {
            id: tt
            enabled: tile.enabled_
            onTapped: tile.toggled()
        }
        // the chevron is its own target: tile = toggle, chevron = details
        Item {
            visible: tile.more
            anchors.right: parent.right
            width: 32
            height: parent.height
            Rectangle {
                anchors.centerIn: parent
                width: 24
                height: 24
                radius: 12
                color: Config.fg(mh.hovered ? 0.14 : 0)
            }
            Kirigami.Icon {
                anchors.centerIn: parent
                width: 13
                height: 13
                source: "go-next-symbolic"
                isMask: true
                color: Config.fgSolid
                opacity: 0.75
                roundToIconSize: false
            }
            HoverHandler {
                id: mh
            }
            TapHandler {
                onTapped: tile.opened()
            }
        }
    }

    component SliderRow: Item {
        id: sr
        property string icon
        property real value: 0
        property bool more: false
        property bool enabled_: true
        property bool mockStyle: false
        property bool showValue: true
        property string accessibleName: ""
        signal moved(real v)
        signal iconTapped
        signal opened
        height: 46
        opacity: enabled_ ? 1 : 0.4
        RoundBtn {
            id: ib
            x: 8
            anchors.verticalCenter: parent.verticalCenter
            size: 30
            icon: sr.icon
            visible: !sr.mockStyle
            onTapped: sr.iconTapped()
        }
        Kirigami.Icon {
            id: bareIcon
            x: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            height: 24
            source: sr.icon
            isMask: true
            color: sr.mockStyle ? qs.secondaryText : qs.primaryText
            visible: sr.mockStyle
            Accessible.role: Accessible.Button
            Accessible.name: sr.accessibleName
            activeFocusOnTab: true
            TapHandler {
                onTapped: sr.iconTapped()
            }
        }
        Rectangle {
            id: mockTrack
            x: slider.x
            y: slider.y + (slider.height - height) / 2
            width: slider.width
            height: 16
            radius: 8
            color: Qt.rgba(148 / 255, 154 / 255, 170 / 255, 0.5)
            visible: sr.mockStyle
            Rectangle {
                width: mockTrack.width * slider.visualPosition
                height: parent.height
                radius: parent.radius
                color: "white"
            }
            Rectangle {
                width: 16
                height: 16
                radius: 8
                x: Math.max(0, Math.min(mockTrack.width - width, mockTrack.width * slider.visualPosition - width / 2))
                color: "white"
                border.width: 1
                border.color: "#e8eaf0"
            }
        }
        Sber.Slider {
            id: slider
            anchors.left: sr.mockStyle ? bareIcon.right : ib.right
            anchors.leftMargin: sr.mockStyle ? 24 : 10
            anchors.right: sr.showValue ? val.left : (sr.more ? nextBtn.left : parent.right)
            anchors.rightMargin: sr.showValue ? 8 : sr.more ? 4 : 0
            anchors.verticalCenter: parent.verticalCenter
            height: sr.mockStyle ? 40 : implicitHeight
            from: 0
            to: 100
            stepSize: 1
            opacity: sr.mockStyle ? 0 : 1
            enabled: sr.enabled_
            showRangeValues: !sr.mockStyle
            Accessible.name: sr.accessibleName
            Binding {
                target: slider
                property: "value"
                value: sr.value
                when: !slider.pressed
            }
            onValueEdited: v => sr.moved(v)
            onEditingFinished: v => sr.moved(v)
        }
        Text {
            id: val
            visible: sr.showValue
            anchors.right: nextBtn.left
            anchors.rightMargin: sr.more ? 4 : 0
            anchors.verticalCenter: parent.verticalCenter
            width: 38
            horizontalAlignment: Text.AlignRight
            text: Math.round(sr.value) + "%"
            color: Config.inkDim
            font.pixelSize: 12
            font.features: {
                "tnum": 1
            }
        }
        RoundBtn {
            id: nextBtn
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            size: sr.more ? 26 : 0
            width: sr.more ? 26 : 0
            visible: sr.more
            icon: "go-next-symbolic"
            onTapped: sr.opened()
        }
    }

    component PageHead: Item {
        id: ph
        property string title
        property string kcm: ""
        height: 40
        RoundBtn {
            id: back
            size: 32
            anchors.verticalCenter: parent.verticalCenter
            icon: "go-previous-symbolic"
            onTapped: qs.page = "main"
        }
        Text {
            anchors.left: back.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: ph.title
            color: Config.ink
            font.pixelSize: 16
            font.weight: Font.DemiBold
        }
        RoundBtn {
            visible: ph.kcm !== ""
            size: 32
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            icon: "configure"
            onTapped: qs.openKcm(ph.kcm)
        }
    }

    component ListRow: Item {
        id: lr
        property string icon
        property string title
        property string note: ""
        property bool current: false
        signal tapped
        height: 42
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 1
            anchors.bottomMargin: 1
            radius: 12
            color: Config.fg(lr.current ? 0.13 : (lh.hovered ? 0.07 : 0))
            border.width: 1
            border.color: Config.fg(lr.current ? 0.16 : 0)
            Behavior on color {
                ColorAnimation {
                    duration: Config.quick
                }
            }
        }
        Kirigami.Icon {
            id: li
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            source: lr.icon
            isMask: true
            color: Config.fgSolid
            opacity: lr.current ? 1 : 0.7
            roundToIconSize: false
        }
        Text {
            anchors.left: li.right
            anchors.leftMargin: 10
            anchors.right: noteText.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: lr.title
            color: Config.ink
            font.pixelSize: 13
            font.weight: lr.current ? Font.DemiBold : Font.Normal
            elide: Text.ElideRight
        }
        Text {
            id: noteText
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: lr.note
            color: Config.inkDim
            font.pixelSize: 12
        }
        HoverHandler {
            id: lh
        }
        TapHandler {
            onTapped: lr.tapped()
        }
    }

    component Label_: Text {
        color: Config.inkDim
        font.pixelSize: 11
        font.weight: Font.Medium
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 0.6
        leftPadding: 6
    }

    // ---------- main page ----------
    Column {
        id: mainPage
        x: qs.pad
        y: qs.topPad
        width: qs.width - 2 * qs.pad
        spacing: 0
        opacity: qs.shownPage === "main" ? 1 : 0
        visible: opacity > 0.01
        transform: Translate {
            x: qs.shownPage === "main" ? 0 : -22
            Behavior on x {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutCubic
            }
        }

        Item {
            width: parent.width
            height: 56
            Rectangle {
                id: batteryChip
                visible: battery.present
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(100, batteryLabel.implicitWidth + 48)
                height: 56
                radius: 16
                color: qs.tileSurface
                border.width: 1
                border.color: qs.tileOutline
                Kirigami.Icon {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    width: 24
                    height: 24
                    source: battery.iconName
                    isMask: true
                    color: qs.primaryText
                    roundToIconSize: false
                }
                Text {
                    id: batteryLabel
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    text: battery.percent + "%"
                    color: qs.primaryText
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    font.features: {
                        "tnum": 1
                    }
                }
            }
            Row {
                id: headBtns
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
                RoundBtn {
                    size: 56
                    radius: 16
                    icon: "camera-photo-symbolic"
                    onTapped: {
                        qs.closeRequested();
                        Shell.runDetached("spectacle", []);
                    }
                }
            }
        }

        // ---- Keep the reference composition fixed: battery and screenshot, then sound/brightness, then the eight tiles.
        // Right-click a tile to arrange; the badge toggles visibility and dragging changes the saved tile order.
        Item {
            width: parent.width
            height: 24
        }
        Item {
            id: slidersRow
            visible: qs.rowShown("sliders")
            width: parent.width
            height: sliders.implicitHeight
            Column {
                id: sliders
                width: parent.width
                spacing: 16
                Column {
                    width: parent.width
                    height: 68
                    visible: qs.hasSink
                    Text {
                        width: parent.width
                        height: 28
                        text: qsTr("Звук")
                        color: qs.primaryText
                        font.pixelSize: 14
                        font.weight: Font.Medium
                    }
                    SliderRow {
                        width: parent.width
                        height: 40
                        mockStyle: true
                        showValue: false
                        accessibleName: qsTr("Громкость")
                        icon: qs.volIcon()
                        value: qs.volumePct
                        onMoved: v => {
                            if (qs.hasSink) {
                                qs.vol.setPct(v, true);
                                qs.osdRequested(qs.volIcon(), Math.round(v) / 100);
                            }
                        }
                        onIconTapped: if (qs.vol)
                            qs.vol.toggleMute()
                    }
                }
                Column {
                    width: parent.width
                    height: 68
                    visible: qs.canDim
                    Text {
                        width: parent.width
                        height: 28
                        text: qsTr("Дисплей")
                        color: qs.primaryText
                        font.pixelSize: 14
                        font.weight: Font.Medium
                    }
                    SliderRow {
                        width: parent.width
                        height: 40
                        mockStyle: true
                        showValue: false
                        accessibleName: qsTr("Яркость")
                        icon: "brightness-high-symbolic"
                        value: qs.bright ? qs.bright.pct : 0
                        onMoved: v => {
                            if (qs.bright)
                                qs.bright.setPct(v);
                        }
                    }
                }
            }
        }
        Item {
            width: parent.width
            height: 24
        }
        Grid {
            id: grid
            width: parent.width
            columns: 2
            spacing: qs.gap
            readonly property real tw: (width - spacing) / 2
            readonly property real th: 56 + spacing
            // which cell a point (in grid coordinates) falls into, as an index into the shown list
            function slotAt(x, y) {
                const c = Math.max(0, Math.min(1, Math.floor(x / (tw + spacing))));
                const r = Math.max(0, Math.floor(y / th));
                return r * 2 + c;
            }
            Repeater {
                id: tileRep
                model: qs.arranging ? qs.arrangeList : qs.gridTiles
                Tile {
                    id: t
                    required property string modelData
                    readonly property var d: qs.tileData(modelData)
                    width: grid.tw
                    visible: d.available || qs.arranging
                    icon: d.icon
                    title: d.title
                    status: qs.arranging && !d.available ? qsTr("Not available here") : d.status
                    on: d.on && !qs.arranging
                    more: d.more && !qs.arranging
                    enabled_: d.enabled !== false
                    onToggled: if (!qs.arranging)
                        qs.tileToggle(modelData)
                    onOpened: if (!qs.arranging)
                        qs.tileOpen(modelData)
                    // arranging: hidden tiles are dim; a right-click anywhere on a tile enters arranging
                    readonly property bool shown: qs.arrangeOn.indexOf(modelData) >= 0
                    opacity: qs.arranging && !shown ? 0.45 : 1
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Config.quick
                        }
                    }
                    TapHandler {
                        acceptedButtons: Qt.RightButton
                        onTapped: qs.arranging = true
                    }
                    ArrBadge {
                        tid: t.modelData
                    }
                    // drag to reorder while arranging: the tile lifts, the list is rewritten on release from the drop cell
                    z: dh.active ? 2 : 0
                    scale: dh.active ? 1.04 : 1
                    Behavior on scale {
                        NumberAnimation {
                            duration: Config.quick
                        }
                    }
                    DragHandler {
                        id: dh
                        enabled: qs.arranging
                        target: null
                        dragThreshold: 6
                        property real dx: 0
                        property real dy: 0
                        onTranslationChanged: {
                            dx = translation.x;
                            dy = translation.y;
                        }
                        onActiveChanged: if (!active) {
                            const p = t.mapToItem(grid, t.width / 2 + dx, t.height / 2 + dy);
                            qs.arrangeMove(t.modelData, grid.slotAt(p.x, p.y));
                            dx = 0;
                            dy = 0;
                        }
                    }
                    transform: Translate {
                        x: dh.active ? dh.dx : 0
                        y: dh.active ? dh.dy : 0
                    }
                }
            }
        }
        // arranging: a Done chip, and a hint
        Item {
            visible: qs.arranging
            width: parent.width
            height: 34
            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Drag to reorder · badge shows or hides"
                color: Config.inkDim
                font.pixelSize: 12
            }
            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: doneT.implicitWidth + 28
                height: 30
                radius: 15
                color: Config.onFill
                Text {
                    id: doneT
                    anchors.centerIn: parent
                    text: "Done"
                    color: Config.onFg
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: qs.arrangeDone()
                }
            }
        }
    }

    // ---------- sound page ----------
    Column {
        id: soundPage
        x: qs.pad
        y: qs.pad
        width: qs.width - 2 * qs.pad
        spacing: qs.gap
        opacity: qs.shownPage === "sound" ? 1 : 0
        visible: opacity > 0.01
        transform: Translate {
            x: qs.shownPage === "sound" ? 0 : 22
            Behavior on x {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutCubic
            }
        }
        PageHead {
            width: parent.width
            title: "Sound"
            kcm: "kcm_pulseaudio"
        }
        Rectangle {
            width: parent.width
            height: 54
            radius: 18
            color: Config.fg(0.055)
            border.width: 1
            border.color: Config.fg(0.09)
            SliderRow {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                icon: qs.volIcon()
                value: qs.volumePct
                enabled_: qs.hasSink
                onMoved: v => {
                    if (qs.hasSink) {
                        qs.vol.setPct(v, false);
                        qs.osdRequested(qs.volIcon(), Math.round(v) / 100);
                    }
                }
                onIconTapped: if (qs.vol)
                    qs.vol.toggleMute()
            }
        }
        Label_ {
            text: "Output"
        }
        Column {
            width: parent.width
            Repeater {
                model: qs.vol ? qs.vol.sinks : null
                ListRow {
                    required property var model
                    width: parent.width
                    icon: "audio-speakers-symbolic"
                    title: model.PulseObject ? (model.PulseObject.description || model.Description || "") : (model.Description || "")
                    current: model.PulseObject ? (model.PulseObject.default ?? false) : false
                    note: current ? "✓" : ""
                    onTapped: if (model.PulseObject)
                        model.PulseObject.default = true
                }
            }
        }
        Label_ {
            text: "Input"
        }
        Column {
            width: parent.width
            Repeater {
                model: qs.vol ? qs.vol.sources : null
                ListRow {
                    required property var model
                    width: parent.width
                    icon: "audio-input-microphone-symbolic"
                    title: model.PulseObject ? (model.PulseObject.description || model.Description || "") : (model.Description || "")
                    current: model.PulseObject ? (model.PulseObject.default ?? false) : false
                    note: current ? "✓" : ""
                    onTapped: if (model.PulseObject)
                        model.PulseObject.default = true
                }
            }
        }
    }

    // ---------- network page ----------
    Column {
        id: netPage
        x: qs.pad
        y: qs.pad
        width: qs.width - 2 * qs.pad
        spacing: qs.gap
        opacity: qs.shownPage === "network" ? 1 : 0
        visible: opacity > 0.01
        transform: Translate {
            x: qs.shownPage === "network" ? 0 : 22
            Behavior on x {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutCubic
            }
        }
        PageHead {
            width: parent.width
            title: "Network"
            kcm: "kcm_networkmanagement"
        }
        Item {
            width: parent.width
            height: 44
            visible: qs.wifiThere
            Text {
                x: 8
                anchors.verticalCenter: parent.verticalCenter
                text: "Wi-Fi"
                color: Config.ink
                font.pixelSize: 14
            }
            Sber.Switch {
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                checked: qs.wifiOn
                onToggled: if (qs.net)
                    qs.net.enableWireless(checked)
            }
        }
        ListView {
            width: parent.width
            height: Math.min(contentHeight, 6 * 42)
            clip: true
            interactive: contentHeight > height
            boundsBehavior: Flickable.StopAtBounds
            model: qs.net ? qs.net.networks : null
            delegate: ListRow {
                required property var model
                width: ListView.view.width
                readonly property bool active: model.ConnectionState === qs.net.stateActivated
                icon: model.ConnectionIcon || "network-wired-symbolic"
                title: model.ItemUniqueName || model.Name || ""
                current: active
                note: active ? "Connected" : (model.ConnectionState === qs.net.stateActivating ? "Connecting…" : (model.SecurityType > 0 && !model.ConnectionPath ? "Secured" : ""))
                onTapped: {
                    if (active)
                        qs.net.deactivate(model.ConnectionPath, model.DevicePath);
                    else if (model.ConnectionPath)
                        qs.net.activate(model.ConnectionPath, model.DevicePath, model.SpecificPath);
                    else
                        qs.openKcm("kcm_networkmanagement");
                }
            }
        }     // a new secured network needs a password: System Settings asks for it
        // VPNs: NetworkManager's VPN plugin connections and WireGuard tunnels, a tap connects / disconnects
        Label_ {
            text: "VPN"
            visible: qs.net && qs.net.vpnCount > 0
        }
        ListView {
            visible: qs.net && qs.net.vpnCount > 0
            width: parent.width
            height: Math.min(contentHeight, 4 * 42)
            clip: true
            interactive: contentHeight > height
            boundsBehavior: Flickable.StopAtBounds
            model: qs.net ? qs.net.vpns : null
            delegate: ListRow {
                required property var model
                width: ListView.view.width
                readonly property bool active: model.ConnectionState === qs.net.stateActivated
                icon: "network-vpn-symbolic"
                title: model.ItemUniqueName || model.Name || ""
                current: active
                note: active ? "Connected" : (model.ConnectionState === qs.net.stateActivating ? "Connecting…" : (model.VpnType ? String(model.VpnType) : "WireGuard"))
                onTapped: {
                    if (active)
                        qs.net.deactivate(model.ConnectionPath, model.DevicePath);
                    else
                        qs.net.activate(model.ConnectionPath, model.DevicePath, model.SpecificPath);
                }
            }
        }
    }
}
