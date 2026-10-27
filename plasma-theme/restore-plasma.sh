#!/usr/bin/env bash
set -Eeuo pipefail

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
service=plasma-plasmashell.service
drop_in="$config_home/systemd/user/$service.d/sberos-shell.conf"
expected_override=$'[Service]\nExecStart=\nExecStart=/usr/bin/plasmashell --no-respawn --shell-plugin io.gitgud.wackyideas.desktop'
dry_run=0

usage() {
    cat <<'EOF'
Restore the ordinary KDE Plasma shell for the current user.

Usage: restore-plasma.sh [--dry-run]

  --dry-run  Show what would change without restarting Plasma.
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

if ! command -v systemctl >/dev/null 2>&1; then
    echo "systemctl is required to restart the Plasma user service." >&2
    exit 1
fi

if [[ ! -e "$drop_in" && ! -L "$drop_in" ]]; then
    echo "SberOS Plasma service override is absent; nothing was changed."
    exit 0
fi

if [[ -L "$drop_in" || ! -f "$drop_in" || "$(cat -- "$drop_in")" != "$expected_override" ]]; then
    printf 'Unexpected contents in %s; leaving the Plasma service unchanged.\n' "$drop_in" >&2
    exit 1
fi

if ((dry_run)); then
    printf 'Would back up and remove %s, then reload and restart %s.\n' "$drop_in" "$service"
    exit 0
fi

mkdir -p -- "$state_home/sberos-shell/plasma-restore"
backup_dir="$(mktemp -d "$state_home/sberos-shell/plasma-restore/$(date -u +%Y%m%dT%H%M%SZ)-XXXXXX")"
cp -a -- "$drop_in" "$backup_dir/sberos-shell.conf"
rm -- "$drop_in"

rollback() {
    cp -a -- "$backup_dir/sberos-shell.conf" "$drop_in"
    systemctl --user daemon-reload || true
    systemctl --user restart "$service" || true
    printf 'Plasma restore failed; the SberOS override was restored from %s.\n' "$backup_dir" >&2
    exit 1
}

systemctl --user daemon-reload || rollback
effective_exec="$(systemctl --user show "$service" -p ExecStart --value)" || rollback
if [[ "$effective_exec" != *"/plasmashell"* || "$effective_exec" == *"--shell-plugin"* ]]; then
    printf 'Unexpected effective ExecStart: %s\n' "$effective_exec" >&2
    rollback
fi

systemctl --user restart "$service" || rollback
systemctl --user is-active --quiet "$service" || rollback

printf 'Ordinary Plasma is active. Previous SberOS override: %s/sberos-shell.conf\n' "$backup_dir"
systemctl --user show "$service" -p ActiveState -p SubState -p MainPID || true
