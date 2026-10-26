#!/usr/bin/env bash
set -Eeuo pipefail

readonly package_id="sberos.lock"
readonly package_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/sberos.lock" && pwd)"
readonly user_package_root="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/shells"
readonly systemd_user_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
readonly dropin_name="sberos-lock.conf"
readonly dropin_contents=$'[Service]\nEnvironment=PLASMA_DEFAULT_SHELL=sberos.lock\n'
readonly legacy_package_id="onur.glasslock"
readonly legacy_dropin_name="onur-glasslock.conf"
readonly legacy_dropin_contents=$'[Service]\nEnvironment=PLASMA_DEFAULT_SHELL=onur.glasslock\n'

usage() {
    cat <<'EOF'
Usage: desktop/lock/install.sh [install|uninstall|status]

Install SberOS Lock for the current user. The KWin drop-in selects it for the
KScreenLocker greeter on the next KWin start; this script does not restart KWin
or change plasmashell's ShellPackage.
EOF
}

fail() {
    printf 'lock install: %s\n' "$*" >&2
    exit 1
}

require_command() {
    local command_name="$1"
    local install_hint="$2"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        fail "не найдена обязательная команда '$command_name'. Установи зависимость: $install_hint"
    fi
}

require_runtime() {
    [[ "$EUID" -ne 0 ]] \
        || fail "это пользовательский установщик; запусти его обычным пользователем, без sudo"

    require_command kpackagetool6 'sudo apt install kpackagetool6'
    require_command systemctl 'sudo apt install systemd'
    require_command grep 'sudo apt install grep'
    require_command cmp 'sudo apt install coreutils'
    require_command mktemp 'sudo apt install coreutils'
    require_command chmod 'sudo apt install coreutils'
    require_command mv 'sudo apt install coreutils'
    require_command mkdir 'sudo apt install coreutils'
    require_command rm 'sudo apt install coreutils'
    require_command rmdir 'sudo apt install coreutils'
    require_command dirname 'sudo apt install coreutils'

    if ! systemctl --user show-environment >/dev/null 2>&1; then
        fail "нет пользовательского systemd bus. Запусти скрипт из сеанса Plasma; если systemd user manager не установлен, установи systemd."
    fi
}

select_kwin_unit() {
    local preferred other unit load_state

    case "${XDG_SESSION_TYPE:-}" in
        wayland)
            preferred="plasma-kwin_wayland.service"
            other="plasma-kwin_x11.service"
            ;;
        x11)
            preferred="plasma-kwin_x11.service"
            other="plasma-kwin_wayland.service"
            ;;
        *)
            preferred="plasma-kwin_wayland.service"
            other="plasma-kwin_x11.service"
            ;;
    esac

    for unit in "$preferred" "$other"; do
        if systemctl --user is-active --quiet "$unit"; then
            printf '%s\n' "$unit"
            return 0
        fi
    done

    for unit in "$preferred" "$other"; do
        load_state="$(systemctl --user show "$unit" -p LoadState --value 2>/dev/null || true)"
        if [[ "$load_state" == "loaded" ]]; then
            printf '%s\n' "$unit"
            return 0
        fi
    done

    fail "не найден пользовательский KWin unit. Нужен Plasma с plasma-kwin_wayland.service или plasma-kwin_x11.service."
}

dropin_path_for() {
    printf '%s/%s.d/%s\n' "$systemd_user_dir" "$1" "$dropin_name"
}

legacy_dropin_path_for() {
    printf '%s/%s.d/%s\n' "$systemd_user_dir" "$1" "$legacy_dropin_name"
}

check_legacy_installation() {
    local unit destination legacy_path

    legacy_path="$user_package_root/$legacy_package_id"
    [[ ! -L "$legacy_path" ]] \
        || fail "путь старого пакета является symlink и не будет изменён: $legacy_path"

    for unit in plasma-kwin_wayland.service plasma-kwin_x11.service; do
        destination="$(legacy_dropin_path_for "$unit")"
        if [[ -e "$destination" || -L "$destination" ]]; then
            [[ ! -L "$destination" ]] \
                || fail "старый drop-in является symlink и не будет изменён: $destination"
            cmp -s <(printf '%s' "$legacy_dropin_contents") "$destination" \
                || fail "старый drop-in изменён и не будет удалён: $destination"
        fi
    done
}

remove_legacy_installation() {
    local unit destination legacy_path

    legacy_path="$user_package_root/$legacy_package_id"
    if [[ -d "$legacy_path" ]]; then
        kpackagetool6 --type Plasma/Shell --remove "$legacy_package_id"
        printf 'Удалён прежний пользовательский пакет %s.\n' "$legacy_package_id"
    fi

    for unit in plasma-kwin_wayland.service plasma-kwin_x11.service; do
        destination="$(legacy_dropin_path_for "$unit")"
        if [[ -f "$destination" ]] && cmp -s <(printf '%s' "$legacy_dropin_contents") "$destination"; then
            rm -- "$destination"
            rmdir --ignore-fail-on-non-empty "$(dirname -- "$destination")" 2>/dev/null || true
            printf 'Удалён прежний KWin drop-in %s.\n' "$destination"
        fi
    done
}

write_dropin() {
    local destination="$1"
    local directory temporary

    directory="$(dirname -- "$destination")"
    mkdir -p -- "$directory"

    if [[ -L "$destination" ]]; then
        fail "drop-in является symlink и не будет перезаписан: $destination"
    fi

    if [[ -e "$destination" ]]; then
        if ! cmp -s <(printf '%s' "$dropin_contents") "$destination"; then
            fail "drop-in уже существует и отличается; сохрани его и разреши конфликт вручную: $destination"
        fi
        return 0
    fi

    temporary="$(mktemp "$directory/.${dropin_name}.XXXXXX")"
    printf '%s' "$dropin_contents" > "$temporary"
    chmod 644 "$temporary"
    mv -- "$temporary" "$destination"
}

install_lock() {
    local unit destination

    [[ -f "$package_dir/metadata.json" && -f "$package_dir/contents/lockscreen/LockScreen.qml" ]] \
        || fail "неполный пакет в $package_dir"
    grep -Fq '"Id": "sberos.lock"' "$package_dir/metadata.json" \
        || fail "metadata.json не содержит ожидаемый ID $package_id"

    unit="$(select_kwin_unit)"
    destination="$(dropin_path_for "$unit")"

    check_legacy_installation

    if [[ -L "$user_package_root/$package_id" ]]; then
        fail "путь установленного пакета является symlink и не будет перезаписан: $user_package_root/$package_id"
    fi

    if [[ -L "$destination" ]]; then
        fail "drop-in является symlink и не будет перезаписан: $destination"
    fi
    if [[ -e "$destination" ]] && ! cmp -s <(printf '%s' "$dropin_contents") "$destination"; then
        fail "drop-in уже существует и отличается; сохрани его и разреши конфликт вручную: $destination"
    fi

    if [[ -d "$user_package_root/$package_id" ]]; then
        kpackagetool6 --type Plasma/Shell --upgrade "$package_dir"
    else
        kpackagetool6 --type Plasma/Shell --install "$package_dir"
    fi

    write_dropin "$destination"
    remove_legacy_installation
    systemctl --user daemon-reload

    printf 'Установлен пользовательский lock screen %s.\n' "$package_id"
    printf 'KWin unit: %s\n' "$unit"
    printf 'KScreenLocker применит его при следующем запуске KWin/входе; текущую сессию скрипт не перезапускает.\n'
}

uninstall_lock() {
    local unit destination package_path found_dropin=0

    # Check every supported unit before changing anything. A modified drop-in
    # is user data, so leave it and stop instead of deleting it silently.
    for unit in plasma-kwin_wayland.service plasma-kwin_x11.service; do
        destination="$(dropin_path_for "$unit")"
        if [[ -e "$destination" || -L "$destination" ]]; then
            [[ ! -L "$destination" ]] \
                || fail "drop-in является symlink и не будет удалён: $destination"
            cmp -s <(printf '%s' "$dropin_contents") "$destination" \
                || fail "drop-in изменён и не будет удалён: $destination"
            found_dropin=1
        fi
    done

    package_path="$user_package_root/$package_id"
    [[ ! -L "$package_path" ]] \
        || fail "путь установленного пакета является symlink и не будет удалён: $package_path"
    if [[ -d "$package_path" ]]; then
        kpackagetool6 --type Plasma/Shell --remove "$package_id"
        printf 'Удалён пользовательский пакет %s.\n' "$package_id"
    else
        printf 'Пользовательский пакет %s не установлен.\n' "$package_id"
    fi

    for unit in plasma-kwin_wayland.service plasma-kwin_x11.service; do
        destination="$(dropin_path_for "$unit")"
        if [[ -f "$destination" ]] && cmp -s <(printf '%s' "$dropin_contents") "$destination"; then
            rm -- "$destination"
            rmdir --ignore-fail-on-non-empty "$(dirname -- "$destination")" 2>/dev/null || true
        fi
    done

    if (( found_dropin )); then
        systemctl --user daemon-reload
        printf 'KWin drop-in удалён. Изменение действует со следующего запуска KWin/входа.\n'
    else
        printf 'KWin drop-in отсутствовал.\n'
    fi
}

show_status() {
    local unit package_path destination

    package_path="$user_package_root/$package_id"
    if [[ -d "$package_path" ]]; then
        kpackagetool6 --type Plasma/Shell --show "$package_id"
    else
        printf 'Пользовательский пакет %s не установлен.\n' "$package_id"
    fi

    unit="$(select_kwin_unit)"
    destination="$(dropin_path_for "$unit")"
    printf 'KWin unit: %s (%s)\n' "$unit" "$(systemctl --user is-active "$unit" || true)"
    if [[ -f "$destination" ]] && cmp -s <(printf '%s' "$dropin_contents") "$destination"; then
        printf 'Lock screen выбран для greeter при следующем старте KWin.\n'
    else
        printf 'KWin drop-in не установлен.\n'
    fi
}

action="${1:-install}"
case "$action" in
    install)
        [[ "$#" -le 1 ]] || { usage >&2; exit 2; }
        require_runtime
        install_lock
        ;;
    uninstall|--undo)
        [[ "$#" -le 1 ]] || { usage >&2; exit 2; }
        require_runtime
        uninstall_lock
        ;;
    status)
        [[ "$#" -le 1 ]] || { usage >&2; exit 2; }
        require_runtime
        show_status
        ;;
    -h|--help|help)
        usage
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac
