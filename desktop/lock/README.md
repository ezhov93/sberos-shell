# Glass Lock installer

`install.sh` installs the `onur.glasslock` Plasma/Shell package for the current
user and configures KScreenLocker to use it through the active KWin user unit.
It does not change `plasmashellrc` / `ShellPackage`, install globally, or restart
KWin. The greeter uses the selection when KWin next starts, normally after the
next login.

Run as the logged-in desktop user (never via `sudo`) from the repository root or
any directory:

```sh
desktop/lock/install.sh install
desktop/lock/install.sh status
desktop/lock/install.sh uninstall
```

`uninstall` (also `--undo`) removes the user-level package and only the exact
KWin drop-in written by this installer. If that drop-in was edited or replaced
with a symlink, the script stops and preserves it. System-wide packages and
other KWin unit configuration are left alone.

The installer requires `kpackagetool6`, `systemctl` with a working user manager,
and basic Debian utilities (`grep`, `coreutils`). It checks these before making
changes, prints the Debian package to install when a command is missing, and
does not install dependencies automatically. The current Plasma Wayland and
X11 KWin units are supported.

After installation, verify the live lock screen with `Win+L` after the next
login. The QML preview harness uses a mock authenticator; it does not validate
the real lock protocol or PAM authentication. Relevant scenarios: `10-01` and
`10-03`.
