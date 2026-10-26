#!/usr/bin/env bash
set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
dry_run=0

usage() {
    cat <<'EOF'
Install the SberOS Plasma shell and panel components into the current user's
Plasma data directory. This does not install the rest of AeroThemePlasma or
change the current panel layout.

Usage: install-sberos-panel.sh [--dry-run]
EOF
}

for arg in "$@"; do
    case "$arg" in
        --dry-run) dry_run=1 ;;
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
    "$script_dir/plasma/shells/io.gitgud.wackyideas.desktop" \
    "plasma/shells"

install_package "Plasma/LayoutTemplate" \
    "io.gitgud.wackyideas.taskbar" \
    "$script_dir/plasma/layout-templates/io.gitgud.wackyideas.taskbar" \
    "plasma/layout-templates"

for id in \
    io.gitgud.wackyideas.panel \
    io.gitgud.wackyideas.desktopcontainment \
    io.gitgud.wackyideas.sbermenu \
    io.gitgud.wackyideas.smarttasks \
    io.gitgud.wackyideas.clockcalendar \
    p-connor.plasma-drawer \
    KdeControlStation \
    com.mcc45tr.filesearch
do
    install_package "Plasma/Applet" \
        "$id" \
        "$script_dir/plasma/plasmoids/$id" \
        "plasma/plasmoids"
done

if ((dry_run)); then
    echo "Dry run complete; no files were installed."
else
    if ((backup_created)); then
        printf 'Previous user-local package copies were backed up to %s\n' "$backup_root"
    fi
    echo "SberOS Plasma packages are installed for this user."
    echo "The current panel layout was left intact; the installed startup layout applies to a new SberOS shell profile."
    echo "Restart plasmashell to reload the installed package files."
fi
