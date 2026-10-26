#!/usr/bin/env bash
# Build/install Sirca for the current user, restarting it only if it was running.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SERVICE="sirca-shell.service"
was_active=0
stopped=0

if [[ "${EUID}" -eq 0 ]]; then
    echo "Run this script as your desktop user, not as root." >&2
    exit 1
fi

if systemctl --user is-active --quiet "$SERVICE"; then
    was_active=1
fi

restart_if_needed() {
    if (( was_active && stopped )); then
        systemctl --user start "$SERVICE"
        stopped=0
    fi
}
trap restart_if_needed EXIT

if (( was_active )); then
    echo "Stopping active Sirca service before replacing its binary..."
    systemctl --user stop "$SERVICE"
    stopped=1
fi

echo "Building and installing Sirca..."
"$SCRIPT_DIR/shell/install.sh"

systemctl --user daemon-reload

if (( was_active )); then
    echo "Starting Sirca service..."
    systemctl --user start "$SERVICE"
    stopped=0
    systemctl --user --no-pager --full status "$SERVICE"
else
    echo "Installed. Sirca was not running, so it was left stopped."
    echo "Start it with: sirca-shell-switch on"
fi
