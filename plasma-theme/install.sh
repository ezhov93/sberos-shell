#!/usr/bin/env bash
set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
dry_run=0
activate_clock=0
config_file="$config_home/plasma-org.kde.plasma.desktop-appletsrc"

usage() {
    cat <<'EOF'
Install the SberOS Plasma shell and panel components into the current user's
Plasma data directory. This does not install the rest of AeroThemePlasma or
change the current panel layout.

Usage: install.sh [--dry-run] [--activate-clock]

  --activate-clock  Replace the current panel's stock digital clock with the
                    SberOS clock/calendar applet (backs up the config first).
EOF
}

for arg in "$@"; do
    case "$arg" in
        --dry-run) dry_run=1 ;;
        --activate-clock) activate_clock=1 ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'Unknown option: %s\n' "$arg" >&2; usage >&2; exit 2 ;;
    esac
done

if [[ "$(id -u)" -eq 0 ]]; then
    echo "Run this script as your desktop user, without sudo." >&2
    exit 1
fi

if ! command -v kpackagetool6 >/dev/null 2>&1; then
    echo "kpackagetool6 is required (install the Plasma 6 workspace tools)." >&2
    exit 1
fi

export XDG_DATA_HOME="$data_home"

backup_root="$state_home/sberos-shell/plasma-install/$(date -u +%Y%m%dT%H%M%SZ)-$$-$RANDOM"
backup_created=0

clock_config() {
    python3 - "$config_file" "$1" <<'PY'
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
mode = sys.argv[2]
if not path.is_file():
    raise SystemExit(f"Plasma applet config is missing: {path}")
text = path.read_text()
lines = text.splitlines(keepends=True)
sections = []
start = 0
for index, line in enumerate(lines):
    if line.startswith("[") and line.rstrip().endswith("]"):
        if index > start:
            sections.append((header, start, index))
        header, start = line.strip(), index
if lines and start < len(lines):
    sections.append((header, start, len(lines)))

panels = set()
for header, begin, end in sections:
    match = re.fullmatch(r"\[Containments\]\[(\d+)\]", header)
    if match and any(line.strip() == "plugin=org.kde.panel" for line in lines[begin + 1:end]):
        panels.add(match.group(1))

matches = []
for header, begin, end in sections:
    match = re.fullmatch(r"\[Containments\]\[(\d+)\]\[Applets\]\[(\d+)\]", header)
    if match and match.group(1) in panels:
        plugin = next((line.strip() for line in lines[begin + 1:end] if line.strip().startswith("plugin=")), "")
        if plugin in ("plugin=org.kde.plasma.digitalclock", "plugin=io.gitgud.wackyideas.clockcalendar"):
            matches.append((begin, end, plugin))

if len(matches) != 1:
    raise SystemExit(f"Expected exactly one supported clock applet in a panel; found {len(matches)}")
if mode == "check":
    print("stock" if matches[0][2] == "plugin=org.kde.plasma.digitalclock" else "active")
    raise SystemExit(0)

begin, end, plugin = matches[0]
if plugin == "plugin=io.gitgud.wackyideas.clockcalendar":
    print("SberOS clock/calendar is already active; no panel config change is needed.")
    raise SystemExit(0)

for index in range(begin + 1, end):
    if lines[index].strip() == "plugin=org.kde.plasma.digitalclock":
        lines[index] = re.sub(r"org\.kde\.plasma\.digitalclock", "io.gitgud.wackyideas.clockcalendar", lines[index])
        break
else:
    raise SystemExit("Clock applet changed while preparing activation; no config was written.")

if mode == "dry-run":
    print("Would replace the current panel's stock digital clock with SberOS clock/calendar.")
elif mode == "write":
    temp = path.with_name(path.name + ".sberos-tmp")
    temp.write_text("".join(lines))
    temp.chmod(path.stat().st_mode & 0o777)
    temp.replace(path)
    print("Activated SberOS clock/calendar in the current panel.")
PY
}

if ((activate_clock)); then
    clock_state="$(clock_config check)"
fi

install_package() {
    local type="$1"
    local id="$2"
    local source="$3"
    local relative_root="$4"
    local target="$data_home/$relative_root/$id"
    local action=--install

    if [[ ! -d "$source" ]]; then
        printf 'Package source is missing: %s\n' "$source" >&2
        return 1
    fi

    if [[ -e "$target" ]]; then
        action=--upgrade
        if ((dry_run)); then
            printf 'Would back up %s to %s\n' "$target" "$backup_root/$relative_root/$id"
        else
            mkdir -p "$backup_root/$relative_root"
            cp -a -- "$target" "$backup_root/$relative_root/$id"
            backup_created=1
        fi
    fi

    printf '%s %s (%s)\n' "${action#--}" "$id" "$type"
    if ((dry_run)); then
        return 0
    fi

    kpackagetool6 --type "$type" "$action" "$source"
}

install_package "Plasma/Shell" \
    "io.gitgud.wackyideas.desktop" \
    "$script_dir/shells/sberos.desktop" \
    "plasma/shells"

install_package "Plasma/LayoutTemplate" \
    "io.gitgud.wackyideas.taskbar" \
    "$script_dir/layout-templates/sberos.taskbar" \
    "plasma/layout-templates"

for package in \
    io.gitgud.wackyideas.panel=sberos.panel \
    io.gitgud.wackyideas.desktopcontainment=sberos.desktopcontainment \
    io.gitgud.wackyideas.sbermenu=sberos.sbermenu \
    io.gitgud.wackyideas.smarttasks=sberos.smarttasks \
    io.gitgud.wackyideas.clockcalendar=sberos.clockcalendar \
    KdeControlStation=sberos.controlcenter \
    com.mcc45tr.filesearch=sberos.filesearch
do
    id="${package%%=*}"
    package_dir="${package#*=}"
    install_package "Plasma/Applet" \
        "$id" \
        "$script_dir/plasmoids/$package_dir" \
        "plasma/plasmoids"
done

# Retire the separate launcher package after the combined applet is installed.
old_launcher="$data_home/plasma/plasmoids/p-connor.plasma-drawer"
if [[ -d "$old_launcher" ]]; then
    if ((dry_run)); then
        printf 'Would back up and remove standalone launcher %s\n' "$old_launcher"
    else
        mkdir -p "$backup_root/plasma/plasmoids"
        cp -a -- "$old_launcher" "$backup_root/plasma/plasmoids/p-connor.plasma-drawer"
        backup_created=1
        kpackagetool6 --type Plasma/Applet --remove p-connor.plasma-drawer
    fi
fi

if ((dry_run)); then
    if ((activate_clock)); then
        clock_config dry-run
        if [[ "$clock_state" == stock ]]; then
            printf 'Would back up %s to %s/config/%s\n' "$config_file" "$backup_root" "$(basename "$config_file")"
        fi
    fi
    echo "Dry run complete; no files were installed."
else
    if ((activate_clock)) && [[ "$clock_state" == stock ]]; then
        mkdir -p "$backup_root/config"
        cp -a -- "$config_file" "$backup_root/config/$(basename "$config_file")"
        backup_created=1
        clock_config write
    fi
    if ((backup_created)); then
        printf 'Previous user-local package copies were backed up to %s\n' "$backup_root"
    fi
    echo "SberOS Plasma packages are installed for this user."
    if ((activate_clock)); then
        echo "Only the current panel's clock applet was changed; the rest of the layout was left intact."
    else
        echo "The current panel layout was left intact; the installed startup layout applies to a new SberOS shell profile."
    fi
    echo "Restart plasmashell to reload the installed package files."
fi
