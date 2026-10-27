#!/usr/bin/env bash
set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
dry_run=0
install_args=()
service=plasma-plasmashell.service
drop_in="$config_home/systemd/user/$service.d/sberos-shell.conf"
expected_override=$'[Service]\nExecStart=\nExecStart=/usr/bin/plasmashell --no-respawn --shell-plugin io.gitgud.wackyideas.desktop'

usage() {
    cat <<'EOF'
Install the current SberOS Plasma packages, configure the SberOS shell plugin,
and restart the Plasma shell.

Usage: install-and-restart.sh [--dry-run] [--activate-clock]

  --dry-run       Preview package and service configuration changes; do not write or restart.
  --activate-clock  Also replace the current panel clock, backing up its config.
EOF
}

for arg in "$@"; do
    case "$arg" in
        --dry-run) dry_run=1; install_args+=(--dry-run) ;;
        --activate-clock) install_args+=(--activate-clock) ;;
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

systemctl --user cat "$service" >/dev/null 2>&1 || {
    printf 'Cannot read the user service %s. Is Plasma running in this session?\n' "$service" >&2
    exit 1
}

if [[ -L "$drop_in" || ( -e "$drop_in" && ! -f "$drop_in" ) ]]; then
    printf 'Unexpected service override at %s; leaving it unchanged.\n' "$drop_in" >&2
    exit 1
fi
if [[ -f "$drop_in" && "$(cat -- "$drop_in")" != "$expected_override" ]]; then
    printf 'Service override at %s has unexpected contents; leaving it unchanged.\n' "$drop_in" >&2
    exit 1
fi

if ((dry_run)) && [[ ! -f "$drop_in" ]]; then
    printf 'Would configure %s to start the SberOS Plasma shell using %s.\n' "$service" "$drop_in"
fi

"$script_dir/install.sh" "${install_args[@]}"

if ((dry_run)); then
    echo "Dry run complete; Plasma was not restarted."
    exit 0
fi

override_created=0
if [[ ! -f "$drop_in" ]]; then
    mkdir -p -- "$(dirname -- "$drop_in")"
    temp_override="$(mktemp "$(dirname -- "$drop_in")/.sberos-shell.conf.XXXXXX")"
    printf '%s\n' "$expected_override" > "$temp_override"
    chmod 0644 "$temp_override"
    mv -- "$temp_override" "$drop_in"
    override_created=1
fi

rollback_override() {
    local reason="$1"
    if ((override_created)); then
        rm -f -- "$drop_in"
        systemctl --user daemon-reload || true
        systemctl --user restart "$service" || true
    fi
    printf '%s\n' "$reason" >&2
    exit 1
}

echo "Reloading $service to apply the installed packages..."
systemctl --user daemon-reload || rollback_override "Could not reload the Plasma user service configuration."
effective_exec="$(systemctl --user show "$service" -p ExecStart --value)" || rollback_override "Could not verify the Plasma shell command."
if [[ "$effective_exec" != *"--shell-plugin io.gitgud.wackyideas.desktop"* ]]; then
    rollback_override "The effective ExecStart does not select the SberOS Plasma shell."
fi
systemctl --user restart "$service" || rollback_override "Could not restart $service."
systemctl --user is-active --quiet "$service" || rollback_override "$service did not become active."

systemctl --user show "$service" \
    -p ActiveState -p SubState -p MainPID -p NRestarts
echo "SberOS Plasma packages are installed and the Plasma shell has restarted."
