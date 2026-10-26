import QtQuick

// Opaque Material 3 slider with Ctrl+wheel stepping.
Item {
    id: root

    implicitWidth: 240
    implicitHeight: 44

    property real value: 0.0
    property color accentColor: "#0a84ff"
    property color trackColor: "#45484e"

    // Internal state
    property bool _pressed: false
    property bool _hovered: false

    // Geometry
    readonly property real visualValue: Math.max(0, Math.min(1, value))
    readonly property real edgeInset: Math.max(2, Math.min(4, height * 0.09))
    readonly property real travel: Math.max(1, width - edgeInset * 2)
    readonly property real thumbCenterX: edgeInset + visualValue * travel

    signal previewChanged(real value)
    signal commitRequested(real value)
    signal canceled

    function cancelInteraction() {
        const active = _pressed || _wheelPending;
        _wheelPending = false;
        wheelCommitTimer.stop();
        _angleAccum = 0;
        _pixelAccum = 0;
        if (!active)
            return;
        _pressed = false;
        canceled();
    }
    onEnabledChanged: {
        if (!enabled)
            cancelInteraction();
    }
    onVisibleChanged: {
        if (!visible)
            cancelInteraction();
    }

    // ── Ctrl+滚轮：精细步进 ────────────────────────────────────────────────
    // 光滚轮不碰滑块：滑块大多住在可滚动的面板里，那一下滚轮属于面板。按住 Ctrl
    // 才是"我要调这个滑块"：鼠标一格（±120）走一档，触控板的小增量先攒够一档再
    // 走，否则触控板会刷出一串碎步。wheelStep 是一档走多少行程，默认 1%；设置页
    // 按真实单位传（每档一格整数 / 1% 之类），窄区间才不至于每档都被舍入掉。
    property real wheelStep: 0.01
    // 一次滚轮事件有两种量级：鼠标是"一格 = angleDelta 的 ±120"；触控板在 Wayland 上
    // pixelDelta 与 angleDelta 一起给，量级小一个数量级（实测 |angle| ≈ 12 × |px|，
    // 所以鼠标那一格的量 ≈ 10px）。各按自己的量级累积，两种设备一档的手感才对得上：
    // 用同一个阈值，触控板要么"转不动"，要么两格才走一档。
    property real wheelPixelStep: 10
    property real _angleAccum: 0
    property real _pixelAccum: 0
    property bool _wheelPending: false

    // 收一档。基准取当前显示值（visualValue），与拖动同一条规矩：宿主把请求夹住
    // 或量化过（如不透明度有 10% 下限）时，下一次步进从夹住后的位置继续，不会在
    // 边界上攒一堆空档。preview 立刻生效，提交去抖合并——每转一格就写一次平台
    // 服务太贵。
    function stepByWheel(delta) {
        if (!enabled || !visible || _pressed || delta === 0)
            return;
        const next = Math.max(0, Math.min(1, visualValue + delta * wheelStep));
        if (Math.abs(next - visualValue) < 1e-9)
            return;
        _wheelPending = true;
        previewChanged(next);
        wheelCommitTimer.restart();
    }

    // 喂进一次滚轮增量。pixelY 非 0 = 触控板（连续滚动），按像素攒；否则按鼠标的
    // 一格（120）攒。攒够一档才走，余量留着给下一次。
    function accumulateWheel(angleY, pixelY) {
        if (!enabled || !visible || _pressed)
            return;
        if (pixelY !== 0) {
            _pixelAccum += pixelY;
            while (Math.abs(_pixelAccum) >= wheelPixelStep) {
                stepByWheel(_pixelAccum > 0 ? 1 : -1);
                _pixelAccum -= (_pixelAccum > 0 ? wheelPixelStep : -wheelPixelStep);
            }
        } else if (angleY !== 0) {
            _angleAccum += angleY;
            while (Math.abs(_angleAccum) >= 120) {
                stepByWheel(_angleAccum > 0 ? 1 : -1);
                _angleAccum -= (_angleAccum > 0 ? 120 : -120);
            }
        }
    }

    Timer {
        id: wheelCommitTimer
        interval: 180
        onTriggered: {
            if (!root._wheelPending)
                return;
            root._wheelPending = false;
            // 与松手提交一致：提交当前显示值
            root.commitRequested(root.value);
        }
    }

    opacity: enabled ? 1.0 : 0.45

    function positionForPointer(pointerX) {
        return Math.max(0, Math.min(1, (pointerX - edgeInset) / travel));
    }

    // ── Material 3 form ───────────────────────────────────────────────────
    // Metrics scale with whatever height a host gives the slider, so a 30px
    // control centre row keeps the desktop's compact rhythm while a 44px row is
    // the Material spec exactly.
    Item {
        id: materialLayer
        anchors.fill: parent
        visible: true

        readonly property real m3Scale: Math.min(1, root.height / 44)
        readonly property real inactiveTrack: Math.max(2, 4 * m3Scale)
        readonly property real activeTrack: Math.max(6, 16 * m3Scale)
        readonly property real handleWidth: Math.max(3, 4 * m3Scale)
        readonly property real handleHeight: Math.min(root.height, 44 * m3Scale)
        readonly property real handleX: root.thumbCenterX - handleWidth / 2

        // Inactive track: one thin capsule across the travel.
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            x: root.edgeInset
            width: Math.max(0, root.width - root.edgeInset * 2)
            height: materialLayer.inactiveTrack
            radius: height / 2
            color: root.trackColor
        }

        // Active track: thicker, and it stops at the handle.
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            x: root.edgeInset
            width: Math.max(0, materialLayer.handleX - root.edgeInset)
            height: materialLayer.activeTrack
            radius: height / 2
            color: root.accentColor
        }

        // State layer: M3 shows a halo at 10% on hover and 16% while pressed.
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            x: materialLayer.handleX + materialLayer.handleWidth / 2 - width / 2
            width: height
            height: Math.min(root.height, 40 * materialLayer.m3Scale)
            radius: height / 2
            color: root.accentColor
            opacity: root._pressed ? 0.16 : (root._hovered ? 0.10 : 0.0)
            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                }
            }
        }

        // Handle: a narrow vertical capsule.
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            x: materialLayer.handleX
            width: materialLayer.handleWidth
            height: materialLayer.handleHeight
            radius: width / 2
            color: root.accentColor
        }
    }

    // Mouse interaction
    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        // 滚轮挂在 MouseArea 自己的 onWheel 上：MouseArea 盖满整个控件，独立的
        // WheelHandler 拿不到滚轮（实测滚轮完全收不到，见其提交说明），在这一层才
        // 收得到。只认 Ctrl（触控板两指滚动 + Ctrl 走的也是这条路）；不按 Ctrl 就
        // 放行，让所在面板照旧滚动。
        onWheel: function (wheel) {
            if (!(wheel.modifiers & Qt.ControlModifier)) {
                wheel.accepted = false;
                return;
            }
            root.accumulateWheel(wheel.angleDelta.y, wheel.pixelDelta.y);
            wheel.accepted = true;
        }

        onEntered: root._hovered = true
        onExited: {
            root._hovered = false;
        }

        onPressed: function (mouse) {
            root._pressed = true;
            // 拖动接管：取消还没落下的那次步进提交
            root._wheelPending = false;
            wheelCommitTimer.stop();
            root._angleAccum = 0;
            root._pixelAccum = 0;
            root.previewChanged(root.positionForPointer(mouse.x));
        }

        onPositionChanged: function (mouse) {
            if (!pressed)
                return;
            root.previewChanged(root.positionForPointer(mouse.x));
        }

        onReleased: function () {
            if (!root._pressed)
                return;
            root._pressed = false;
            // 提交当前显示值，而不是用松开瞬间的鼠标位置重新计算：
            // 松手时鼠标常会无意识前带 1~2px，重算会让 thumb 松开后再滑一小步
            root.commitRequested(root.value);
        }

        onCanceled: root.cancelInteraction()
    }
}
