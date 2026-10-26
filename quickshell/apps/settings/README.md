# Settings

Standalone Qt Quick settings application. It is opened from the gear button
in the top bar or Dock-hosted status area and runs as its own process. Build
the small native host once:

```sh
cmake -S apps/settings -B .build/apps/settings
cmake --build .build/apps/settings
```

The host exposes only explicit Settings IPC methods to QML. It does not import
desktop UI. The current pages cover display, theme, bar, Dock, launcher,
shortcuts, notifications, and read-only integration status through narrow Shell IPC targets.
The Power page uses UI Kit radio controls, labels and dividers while keeping its
profile requests in the existing `PowerSettings` backend.
The Launcher page uses UI Kit combo boxes for its existing layout profiles and
keeps the same launcher snapshot and update methods.

During checkout development, `./tools/kosctl build` builds UI Kit into
`.build/kosctl/ui-kit`; `./tools/kosctl settings` adds that build's `qml`
directory to Qt's QML import path. If it is absent, the launcher falls back to
the sibling `ui-kit/_build/qml`. `./tools/kosctl install` deploys the built
modules to `$KOS_PREFIX/share/kos/qml` and theme resources to
`$KOS_PREFIX/share/kos/SberComponents`. `kos-settings` adds those module and
resource directories relative to its installed executable, and the Shell's
user unit exposes the same paths. The resource resolver keeps the source-tree
path as a development fallback; packaged use does not require loading UI Kit
sources.

Notifications uses the `notification-settings` endpoint of the active Shell.
It controls Do Not Disturb, banners, session history, content previews, Dock
badges and permissions for applications that have sent notifications. Policies
persist in the Shell state directory; history keeps the latest 50 messages for
this session. The Control Center and the dedicated notification popup share
one card deck, showing three independent messages until expanded. Card identities
are preserved during expansion; each card has its own compositor glass outline
over one fixed popup capture. Short outputs scroll rather than shrinking controls.

Notification regression checks:

```sh
node tests/notification-history/run.mjs
node tests/notification-history/run-visual.mjs
node tests/notification-history/run-pane.mjs
node tests/notification-history/run-production.mjs
node apps/settings/tests/notifications/bridge.mjs /path/to/kos-settings
/usr/lib/qt6/bin/qmltestrunner -input apps/settings/tests/notifications
```

Run these only in the environment authorized for the current session.

For actual compositor glass (including screenshots), the isolated virtual KWin
fixture uses synthetic messages and a temporary effect configuration:

```sh
python3 tests/notification-history/run-native.py
python3 tests/notification-history/run-native.py --screenshots
python3 tests/notification-history/run-native.py --width 320 --height 540
```

It checks one capture allocation through opening, unfolding, scrolling and
folding; retained visible card instances; clipping; and popup bounds. Screenshot
requests use additional render targets and are measured separately. Frame
intervals in its report describe software OpenGL in the isolated compositor.
Artifacts are saved under `.build/qa/notification-history`.
