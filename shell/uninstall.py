#!/usr/bin/env python3
"""Remove Sirca Shell components installed by install.py."""

from __future__ import annotations

import argparse
import os
import pathlib
import shutil
import subprocess
import sys


ROOT = pathlib.Path(__file__).resolve().parent
HOME = pathlib.Path.home()
STATE = HOME / ".local/state/sirca-shell"
DRY = False
YES = False


def command(args: list[str]):
    try:
        return subprocess.run(args)
    except FileNotFoundError:
        return subprocess.CompletedProcess(args, 127)


def ask(question: str) -> bool:
    if YES:
        return True
    try:
        answer = input(f"{question} [y/N] ").strip().lower()
    except EOFError:
        return False
    return answer in {"y", "yes"}


def run(what: str, args: list[str]) -> bool:
    if DRY:
        print(f"  [dry run] {what}:  {' '.join(map(str, args))}")
        return True
    print(f"  … {what}")
    result = command(args)
    if result.returncode:
        print("    (that step reported a problem; continuing)")
        return False
    return True


def qdbus_command():
    return [shutil.which("qdbus6") or shutil.which("qdbus-qt6") or "qdbus6"]


def icon_theme(theme: str) -> bool:
    for helper in ("/usr/lib/x86_64-linux-gnu/libexec/plasma-changeicons", "/usr/lib/libexec/plasma-changeicons",
                   "/usr/libexec/plasma-changeicons", "/usr/lib64/libexec/plasma-changeicons"):
        path = pathlib.Path(helper)
        if path.is_file() and os.access(path, os.X_OK):
            if command([helper, theme]).returncode == 0:
                return True
    return command(["kwriteconfig6", "--file", "kdeglobals", "--group", "Icons", "--key", "Theme", theme]).returncode == 0


def main() -> int:
    global DRY, YES
    parser = argparse.ArgumentParser(description="Remove installed Sirca Shell components")
    parser.add_argument("--dry-run", action="store_true", help="show actions without changing anything")
    parser.add_argument("--yes", "-y", action="store_true", help="accept all removal prompts")
    args = parser.parse_args()
    DRY, YES = args.dry_run, args.yes
    print("This gives Plasma's panels back first, then removes the parts you confirm.")

    switch = HOME / ".local/bin/sirca-shell-switch"
    found_switch = shutil.which("sirca-shell-switch")
    if found_switch:
        switch = pathlib.Path(found_switch)
    if switch.is_file() and os.access(switch, os.X_OK):
        run("switch the shell off (Plasma's panels come back)", [str(switch), "off"])
    elif command(["systemctl", "--user", "is-enabled", "sirca-shell.service"]).returncode == 0:
        print("sirca-shell-switch is missing but the shell is still enabled: refusing to remove it while Plasma's panels are handed over. Reinstall the shell, switch it off, then uninstall.", file=sys.stderr)
        return 1

    manifest = STATE / "effect-manifest.txt"
    if manifest.is_file() and ask("Remove the glass KWin effect (sudo) and switch KWin's own blur back on?"):
        if not DRY:
            for effect in ("glasskey", "glass"):
                qdbus = qdbus_command() + ["org.kde.KWin", "/Effects", "org.kde.kwin.Effects.unloadEffect", effect]
                command(qdbus)
                command(["kwriteconfig6", "--file", "kwinrc", "--group", "Plugins", "--key", f"{effect}Enabled", "false"])
            blur_file = STATE / "blur-was.txt"
            blur = blur_file.read_text(encoding="utf-8").strip() if blur_file.is_file() else "true"
            command(["kwriteconfig6", "--file", "kwinrc", "--group", "Plugins", "--key", "blurEnabled", blur])
            if blur == "true":
                command(qdbus_command() + ["org.kde.KWin", "/Effects", "org.kde.kwin.Effects.loadEffect", "blur"])
        else:
            print("  [dry run] unload glass effects and restore KWin blur")
        files = [line.strip() for line in manifest.read_text(encoding="utf-8").splitlines() if line.strip()]
        if files:
            run("delete the installed plugin files (sudo)", ["sudo", "rm", "-f", *files])

    if ask("Revert the KDE colour scheme and GTK look to what you had before?"):
        run("revert the look", [str(ROOT / "desktop/tools/apply_all.sh"), "revert"])
    if ask("Remove the lock screen (Plasma's own from the next login)?"):
        run("remove the lock screen", [str(ROOT / "desktop/tools/install_lock.sh"), "--undo"])

    previous_icon = STATE / "icon-theme.txt"
    if previous_icon.is_file():
        theme = previous_icon.read_text(encoding="utf-8").strip()
        if ask(f"Icon theme back to what you had ({theme})?"):
            if DRY:
                print(f"  [dry run] restore icon theme: {theme}")
            elif not icon_theme(theme):
                print("    (that step reported a problem; continuing)")

    papirus_added = STATE / "papirus-added.txt"
    if papirus_added.is_file():
        names = " ".join(papirus_added.read_text(encoding="utf-8").split())
        if ask(f"Remove the Papirus icon themes the installer downloaded ({names}) and the generated folder-colour themes?"):
            icons = HOME / ".local/share/icons"
            for theme in papirus_added.read_text(encoding="utf-8").splitlines():
                if theme.strip():
                    path = icons / theme.strip()
                    if DRY:
                        print(f"  [dry run] remove {path}")
                    elif path.is_dir():
                        shutil.rmtree(path)
            for path in icons.glob("Glass-Papirus*"):
                if DRY:
                    print(f"  [dry run] remove {path}")
                elif path.is_dir():
                    shutil.rmtree(path)

    if ask("Remove glass-mode and its helper links from ~/.local/bin?"):
        run("remove the links", ["rm", "-f", *map(str, (HOME / ".local/bin/glass-mode",
            HOME / ".local/bin/glass-lock-sync", HOME / ".local/bin/glass-folder-color"))])
    run("remove the shell itself", [str(ROOT / "shell/uninstall.sh")])
    if ask("Also delete your shell config (~/.config/sirca-shell) and the bundled wallpapers?"):
        run("delete config and wallpapers", ["rm", "-rf", str(HOME / ".config/sirca-shell"),
            str(HOME / ".local/share/wallpapers/sirca")])
    print("Done. Log out and in once so every app forgets the old look.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
