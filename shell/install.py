#!/usr/bin/env python3
"""Guided per-user installer for Sirca Shell and its optional desktop components."""

from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import pathlib
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request


ROOT = pathlib.Path(__file__).resolve().parent
HOME = pathlib.Path.home()
STATE = HOME / ".local/state/sirca-shell"
LOG: pathlib.Path | None = None
DRY = False
YES = False


def command(args: list[str], *, capture: bool = False, check: bool = False, env=None):
    try:
        return subprocess.run(args, text=True, stdout=subprocess.PIPE if capture else None,
                              stderr=subprocess.PIPE if capture else None, check=check, env=env)
    except FileNotFoundError:
        return subprocess.CompletedProcess(args, 127, "" if capture else None, "command not found" if capture else None)


def have(name: str) -> bool:
    return shutil.which(name) is not None


def ask(question: str, default: bool = False) -> bool:
    if YES:
        return default
    try:
        answer = input(f"{question} [{'Y/n' if default else 'y/N'}] ").strip().lower()
    except EOFError:
        return default
    return (answer or ("y" if default else "n")) in {"y", "yes"}


def run(what: str, args: list[str], *, env=None) -> bool:
    if DRY:
        print(f"  [dry run] {what}:  {' '.join(map(str, args))}")
        return True
    print(f"  … {what}")
    assert LOG is not None
    with LOG.open("a", encoding="utf-8") as log:
        log.write(f"### {what}\n$ {' '.join(map(str, args))}\n")
        result = subprocess.run(args, stdout=log, stderr=subprocess.STDOUT, env=env)
    if result.returncode:
        bad(f"{what}  (details: {LOG})")
        return False
    ok(what)
    return True


def colors():
    enabled = sys.stdout.isatty()
    return {key: (value if enabled else "") for key, value in {
        "B": "\033[1m", "D": "\033[2m", "R": "\033[31m", "G": "\033[32m",
        "Y": "\033[33m", "C": "\033[36m", "N": "\033[0m",
    }.items()}


COL = colors()


def say(message=""):
    print(message)


def head(message):
    say(f"\n{COL['B']}{message}{COL['N']}")


def ok(message):
    say(f"  {COL['G']}✓{COL['N']} {message}")


def warn(message):
    say(f"  {COL['Y']}!{COL['N']} {message}")


def bad(message):
    say(f"  {COL['R']}✗{COL['N']} {message}")


def output(args: list[str]) -> str:
    result = command(args, capture=True)
    return result.stdout.strip() if result.returncode == 0 and result.stdout else ""


def qml_dir_candidates() -> list[pathlib.Path]:
    candidates = []
    for args in (["qtpaths6", "--qml-dir"], ["qmake6", "-query", "QT_INSTALL_QML"]):
        value = output(list(args))
        if value:
            candidates.append(pathlib.Path(value))
    candidates += [pathlib.Path(p) for p in (
        "/usr/lib64/qt6/qml", "/usr/lib/qt6/qml", "/usr/lib/x86_64-linux-gnu/qt6/qml")]
    return candidates


def preflight() -> tuple[bool, int, bool]:
    head("1. Your system")
    fatal = False
    if os.environ.get("XDG_SESSION_TYPE") == "wayland":
        ok("Wayland session")
    else:
        bad(f"this is not a Wayland session (XDG_SESSION_TYPE={os.environ.get('XDG_SESSION_TYPE', 'unset')}). The shell is made of Wayland layer-shell windows: it cannot run on X11.")
        fatal = True

    pv = ""
    version = output(["plasmashell", "--version"])
    import re
    match = re.search(r"\d+\.\d+(?:\.\d+)?", version)
    if match:
        pv = match.group()
    if pv.startswith("6.6"):
        ok(f"KDE Plasma {pv}")
    elif pv.startswith("6.7"):
        warn(f"KDE Plasma {pv}: built and run against 6.7.5 in a headless test session (bar, dock, launcher, quick settings, calendar, power menu and edit mode came up). Not used day to day on 6.7 yet: please report what you see.")
    elif pv.startswith("6."):
        warn(f"KDE Plasma {pv}: built and used on 6.6. Older 6.x may miss things the shell uses.")
    elif not pv:
        bad("KDE Plasma was not found. The shell needs KWin and Plasma's libraries (it replaces only Plasma's panels).")
        fatal = True
    else:
        bad(f"KDE Plasma {pv}: Plasma 6 is required.")
        fatal = True

    if command(["pgrep", "-x", "kwin_wayland"]).returncode == 0:
        ok("KWin is the compositor")
    else:
        bad("kwin_wayland is not running. Other compositors (Hyprland, Sway, GNOME) are not supported.")
        fatal = True
    for tool in ("cmake", "g++", "git", "python3"):
        if not have(tool):
            bad(f"missing: {tool}")
            fatal = True
    if not fatal:
        ok("build tools: cmake, g++, python3")

    local_bin = str(HOME / ".local/bin")
    if local_bin in os.environ.get("PATH", "").split(os.pathsep):
        ok("~/.local/bin is on your PATH")
    else:
        warn("~/.local/bin is not on your PATH: the shell's commands (sirca-shell-switch, glass-mode) are installed there. Add it to your shell profile and log in again, or call them with the full path.")

    ecm_candidates = [os.environ.get("ECM_DIR", ""), "/usr/share/ECM/cmake", "/usr/share/cmake/ECM",
                      "/usr/lib64/cmake/ECM", "/usr/lib/cmake/ECM", "/usr/lib/x86_64-linux-gnu/cmake/ECM",
                      "/usr/local/share/ECM/cmake"]
    if any(pathlib.Path(p, "ECMConfig.cmake").is_file() for p in ecm_candidates if p):
        ok("extra-cmake-modules (KDE's CMake modules)")
    else:
        bad("extra-cmake-modules is not installed (that is the package name on Ubuntu, Fedora and Arch alike): the shell and the Qt style both begin with find_package(ECM) and neither can configure without it.")
        fatal = True

    gpu = output(["lspci"])
    gpu = next((line.split(": ", 1)[-1] for line in gpu.splitlines()
                if any(k in line.lower() for k in ("vga", "3d", "display"))), "")
    if "nvidia" in gpu.lower():
        ok(f"GPU: {gpu[:60]}  (what this was developed on)")
    elif not gpu:
        warn("GPU not detected")
    else:
        warn(f"GPU: {gpu[:60]}  - AMD and Intel are untested by the author. It should work; please report what you see.")

    screens = output(["kscreen-doctor", "-j"])
    try:
        count = sum(bool(item.get("enabled")) for item in json.loads(screens).get("outputs", []))
    except (ValueError, AttributeError):
        count = 1
    if count > 1:
        warn(f"{count} screens: the wallpaper goes on every screen; the bar and dock start on the primary one (edit mode > Screens puts them where you want). Tested with virtual screens only: please report.")
    else:
        ok("one screen")

    try:
        import PIL  # noqa: F401
        import numpy  # noqa: F401
        ok("python: Pillow + numpy (wallpaper tools)")
    except ImportError:
        warn("python Pillow / numpy missing: the bundled wallpapers still work, only re-colouring your own wallpaper will not.")
    have_papirus = any((p / "Papirus").is_dir() for p in
                       (pathlib.Path("/usr/share/icons"), HOME / ".local/share/icons"))
    if have_papirus:
        ok("Papirus icons (the look uses them; folder colours follow the colour theme)")
    else:
        warn("Papirus icon theme not installed: the look step installs it into ~/.local/share/icons (about 200 MB, from github.com/PapirusDevelopmentTeam).")
    if any((directory / "org/kde/milou/qmldir").is_file() for directory in qml_dir_candidates()):
        ok("Milou QML module")
    else:
        bad("the Milou QML module is missing (package: plasma-milou on Fedora, milou on Arch and Ubuntu): the shell's search uses it and the shell exits at start without it.")
        fatal = True
    if have("gpu-screen-recorder"):
        ok("gpu-screen-recorder (screen recording)")
    else:
        warn("gpu-screen-recorder not installed: screenshots work, recording will say it is missing.")
    return fatal, count, have_papirus


def choose(preset: str) -> dict[str, bool] | None:
    head("3. What do you want?")
    say(f"  {COL['B']}1) Shell only{COL['N']}            the bar, dock, launcher, search, notifications, clipboard, screenshots. No root.\n                            Surfaces use the shell's solid colours.\n  {COL['B']}2) Shell + the look{COL['N']}      1 + KDE colour scheme and GTK look + light/dark switch\n                            with colour themes and the bundled wallpapers + lock screen.\n  {COL['B']}3) The author's full setup{COL['N']}  2 + the author's bar and dock layout. Applies the sample layout.\n  {COL['B']}4) Let me pick{COL['N']}           choose each part yourself.")
    selected = dict(shell=True, look=False, mode=False, lock=False, setup=False)
    if preset:
        choices = {"shell": "1", "1": "1", "look": "2", "2": "2", "full": "3", "3": "3"}
        choice = choices.get(preset)
        if choice is None:
            print(f"unknown preset: {preset}", file=sys.stderr)
            return None
    elif YES:
        choice = "1"
    else:
        choice = input("Your choice [1-4, default 1]: ").strip() or "1"
    if choice in {"2", "3"}:
        selected.update(look=True, mode=True, lock=True)
    if choice == "3":
        selected.update(setup=True)
    elif choice == "4":
        for key, prompt, default in (
            ("look", "  KDE colour scheme + GTK 3/4 look (no root, revertible)?", True),
            ("mode", "  Light/dark switch, colour themes and the bundled wallpapers (no root)?", True),
            ("lock", "  Lock screen in the same look (no root; active from the next login)?", True),
            ("setup", "  The author's bar and dock layout (only look and layout keys; your pinned apps stay)?", False),
        ):
            selected[key] = ask(prompt, default)
    elif choice != "1":
        choice = "1"
    return selected


def install_papirus() -> bool:
    version = "20260801"
    url = f"https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/archive/refs/tags/{version}.tar.gz"
    try:
        with tempfile.TemporaryDirectory(prefix="sirca-papirus-") as tmp:
            archive = pathlib.Path(tmp, "papirus.tar.gz")
            urllib.request.urlretrieve(url, archive)
            with tarfile.open(archive, "r:gz") as tar:
                tar.extractall(tmp, filter="data")
            extracted = pathlib.Path(tmp, f"papirus-icon-theme-{version}")
            target = HOME / ".local/share/icons"
            target.mkdir(parents=True, exist_ok=True)
            added = []
            for theme in ("Papirus", "Papirus-Dark", "Papirus-Light"):
                if not (target / theme).exists():
                    shutil.copytree(extracted / theme, target / theme)
                    added.append(theme)
            if added:
                with (STATE / "papirus-added.txt").open("a", encoding="utf-8") as file:
                    file.write("".join(name + "\n" for name in added))
        command(["gtk-update-icon-cache", "-q", str(HOME / ".local/share/icons/Papirus")])
        return True
    except (OSError, tarfile.TarError, urllib.error.URLError) as exc:
        print(f"Papirus download failed: {exc}", file=sys.stderr)
        return False


def icon_theme(theme: str) -> bool:
    helpers = ("/usr/lib/x86_64-linux-gnu/libexec/plasma-changeicons", "/usr/lib/libexec/plasma-changeicons",
               "/usr/libexec/plasma-changeicons", "/usr/lib64/libexec/plasma-changeicons")
    for helper in helpers:
        if pathlib.Path(helper).is_file() and os.access(helper, os.X_OK):
            if command([helper, theme]).returncode == 0:
                return True
    return command(["kwriteconfig6", "--file", "kdeglobals", "--group", "Icons", "--key", "Theme", theme]).returncode == 0


def apply_mode(have_papirus: bool) -> bool:
    if not have_papirus and not DRY and not install_papirus():
        return False
    wallpaper_dir = HOME / ".local/share/wallpapers/sirca"
    if not DRY:
        wallpaper_dir.mkdir(parents=True, exist_ok=True)
    for wallpaper in (ROOT / "wallpapers").glob("*.jpg"):
        destination = wallpaper_dir / wallpaper.name
        if not destination.exists() and not DRY:
            shutil.copy2(wallpaper, destination)
    if DRY:
        say(f"  {COL['C']}[dry run]{COL['N']} bundled wallpapers to {wallpaper_dir}")
    else:
        ok(f"bundled wallpapers to {wallpaper_dir}")

    links = {
        HOME / ".local/bin/glass-mode": ROOT / "desktop/tools/mode.sh",
        HOME / ".local/bin/glass-lock-sync": ROOT / "desktop/tools/lock_state.sh",
        HOME / ".local/bin/glass-folder-color": ROOT / "desktop/tools/folder_color.sh",
    }
    for link, source in links.items():
        if DRY:
            say(f"  {COL['C']}[dry run]{COL['N']} symlink {link} -> {source}")
        else:
            link.parent.mkdir(parents=True, exist_ok=True)
            link.unlink(missing_ok=True)
            link.symlink_to(source)
    if not run("seven colour themes in the shell's config (kept if you already have themes)",
               ["python3", str(ROOT / "setups/write_themes.py"), str(wallpaper_dir)]):
        return False

    current = output(["kreadconfig6", "--file", "kdeglobals", "--group", "Icons", "--key", "Theme"])
    previous = STATE / "icon-theme.txt"
    if not DRY and not previous.exists():
        previous.write_text((current or "breeze") + "\n", encoding="utf-8")
    if current.startswith(("Papirus", "Glass-Papirus")):
        ok("icon theme already uses Papirus")
    else:
        config = HOME / ".config/sirca-shell/config.json"
        try:
            mode = json.loads(config.read_text()).get("mode", "dark")
        except (OSError, ValueError):
            mode = "dark"
        if DRY:
            say(f"  {COL['C']}[dry run]{COL['N']} icon theme: {'Papirus' if mode == 'light' else 'Papirus-Dark'}")
        elif not icon_theme("Papirus" if mode == "light" else "Papirus-Dark"):
            return False
        else:
            ok("icon theme: Papirus-Dark (your previous choice is kept)")

    config = HOME / ".config/sirca-shell/config.json"
    try:
        accent = json.loads(config.read_text()).get("theme", "blue")
    except (OSError, ValueError):
        accent = "blue"
    env = os.environ.copy()
    run("apply the colour theme once (folder icons in the theme colour)",
        [str(HOME / ".local/bin/glass-mode"), "theme", accent], env=env)
    return True


def main() -> int:
    global DRY, YES, LOG
    parser = argparse.ArgumentParser(description="Guided per-user installer for Sirca Shell")
    parser.add_argument("--dry-run", action="store_true", help="show actions without changing anything")
    parser.add_argument("--yes", "-y", action="store_true", help="accept default prompts")
    parser.add_argument("--preset", choices=("shell", "look", "full"), help="choose components without the menu")
    args = parser.parse_args()
    DRY, YES = args.dry_run, args.yes
    if os.geteuid() == 0 and os.environ.get("SIRCA_ALLOW_ROOT") != "1":
        print("Run this as your own user, not root: sudo is asked for where it is needed.", file=sys.stderr)
        return 1
    if not DRY:
        STATE.mkdir(parents=True, exist_ok=True)
    LOG = STATE / ("install-" + dt.datetime.now().strftime("%Y%m%d-%H%M%S") + ".log")

    intro = (f"{COL['B']}Sirca Shell{COL['N']}  -  a top bar and dock for KDE Plasma, with the themes that go with it.\n\n"
             "This installer is a conversation, not a one-liner. It checks your system, explains what each part changes, "
             "lets you pick components, then installs the selection.\nNothing is changed before installation.")
    if DRY:
        intro += f" {COL['C']}(dry run: nothing will be changed at all){COL['N']}"
    say(intro)
    fatal, _screens, have_papirus = preflight()
    if fatal:
        say()
        bad("This system cannot run the shell (see the red lines). Nothing was changed.")
        if not DRY:
            return 1
    say('  Build dependencies are listed in shell/README.md ("Build dependencies": Ubuntu, Fedora and Arch names); a failed build names what is missing.')

    head("2. What you should know before you say yes")
    say("  • It replaces Plasma's panels while it is switched on. Your panel layout is saved first and restored exactly by sirca-shell-switch off.\n  • It is young software by one person, used daily on one Ubuntu 26.04 / Plasma 6.6 / NVIDIA machine. There is no warranty (GPL-3.0-or-later).\n  • It takes over global shortcuts while running and hands them back when switched off.\n  • The app themes change KDE and GTK settings. Each applier backs up what it touches and has a revert.\n  • Nothing is sent anywhere. No telemetry.")
    if not ask("Understood. Continue?", True):
        say("Nothing was changed.")
        return 0

    selected = choose(args.preset or "")
    if selected is None:
        return 2
    head("4. With this choice")
    say("  Works: bar, dock, launcher, search, quick settings, notifications, clipboard, screenshots, tile picker, window switcher, power menu, edit mode, light and dark inside the shell.")
    say("  Works: KDE and GTK apps in matching colours." if selected["look"] else "  Not: apps keep your current colours.")
    say("  Works: desktop-wide light/dark and seven colour themes." if selected["mode"] else "  Not: desktop-wide light/dark switch and colour themes.")
    say("  Not yet for anyone: X11, other compositors, vertical dock.")
    if not DRY:
        STATE.mkdir(parents=True, exist_ok=True)
        (STATE / "root.txt").write_text(str(ROOT) + "\n", encoding="utf-8")
    if not ask("Install now?", True):
        say("Nothing was changed.")
        return 0

    head(f"5. Installing   (log: {LOG})")
    failures = []
    steps = []
    if selected["shell"]:
        steps.append(("shell", "build and install the shell to ~/.local (a few minutes)", [str(ROOT / "shell/install.sh")]))
    if selected["look"]:
        steps.append(("look", "KDE colour scheme and GTK look (backups in ~/.local/state/glass-desktop)", [str(ROOT / "desktop/tools/apply_all.sh"), "apply"]))
    for key, description, argv in steps:
        if not run(description, argv):
            failures.append(key)
    if selected["mode"]:
        papirus_ready = have_papirus
        if not have_papirus:
            if not DRY:
                say("  … Papirus icon theme into ~/.local/share/icons (no root, about 200 MB, release 20260801)")
                if install_papirus():
                    ok("Papirus icon theme installed")
                    papirus_ready = True
                else:
                    bad("Papirus icon download failed")
                    failures.append("Papirus icons")
                    selected["mode"] = False
            else:
                say("  [dry run] download Papirus icon theme into ~/.local/share/icons")
        if selected["mode"] and not apply_mode(papirus_ready):
            failures.append("mode")
    if selected["lock"] and not run("lock screen (active from the next login)",
                                      [str(ROOT / "desktop/tools/install_lock.sh")]):
        failures.append("lock")
    if selected["setup"] and not run("the author's bar and dock layout (your config is backed up first)",
                                     [str(HOME / ".local/bin/sirca-shell-setup"), "import", str(ROOT / "setups/author.json")]):
        failures.append("setup")
    if not DRY:
        (STATE / "installed-components").write_text("".join(f"{k}={int(v)}\n" for k, v in selected.items()), encoding="utf-8")

    head("6. Done")
    if failures:
        bad(f"These parts did not finish: {' '.join(failures)}   (log: {LOG}). The rest is installed; fix the cause and run this again.")
    say(f"  Switch it on:      {COL['C']}sirca-shell-switch on{COL['N']}        (saves your Plasma panels and hands over)\n  Switch it off:     {COL['C']}sirca-shell-switch off{COL['N']}       (your panels come back exactly as they were)\n  First start:       a welcome card names the things worth knowing. Right-click the bar or dock to edit them.\n  Remove everything: {COL['C']}{ROOT / 'uninstall.py'}{COL['N']}\n  Problems:          the log above, and {COL['C']}journalctl --user -u sirca-shell -b{COL['N']}")
    if selected["mode"]:
        say(f"  {COL['Y']}Keep this folder{COL['N']} ({ROOT}): glass-mode and the theme generators run from it.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
