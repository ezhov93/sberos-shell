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

    run("remove the shell itself", [str(ROOT / "shell/uninstall.sh")])
    if ask("Also delete your shell config (~/.config/sirca-shell)?"):
        run("delete shell config", ["rm", "-rf", str(HOME / ".config/sirca-shell")])
    print("Done. Log out and in once if you removed the shell.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
