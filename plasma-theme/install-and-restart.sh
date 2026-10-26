#!/usr/bin/env bash
set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
dry_run=0
install_args=()

usage() {
    cat <<'EOF'
Install the current SberOS Plasma packages and restart the configured Plasma shell.

Usage: install-and-restart.sh [--dry-run] [--activate-clock]

  --dry-run       Preview package installation; do not restart Plasma.
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

service=plasma-plasmashell.service
service_definition="$(systemctl --user cat "$service" 2>/dev/null)" || {
    printf 'Cannot read the user service %s. Is Plasma running in this session?\n' "$service" >&2
    exit 1
}
if [[ "$service_definition" != *"--shell-plugin io.gitgud.wackyideas.desktop"* ]]; then
    printf '%s is not configured to start the SberOS Plasma shell; leaving the session unchanged.\n' "$service" >&2
    exit 1
fi

"$script_dir/install.sh" "${install_args[@]}"

if ((dry_run)); then
    echo "Dry run complete; Plasma was not restarted."
    exit 0
fi

echo "Reloading $service to apply the installed packages..."
systemctl --user daemon-reload
systemctl --user restart "$service"
systemctl --user is-active --quiet "$service"

systemctl --user show "$service" \
    -p ActiveState -p SubState -p MainPID -p NRestarts
echo "SberOS Plasma packages are installed and the Plasma shell has restarted."
