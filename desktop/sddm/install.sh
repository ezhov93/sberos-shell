#!/usr/bin/env bash
set -Eeuo pipefail

readonly theme_id="sberos-light"
readonly theme_source="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/usr/share/sddm/themes/hexabee-light" && pwd)"
readonly themes_root="/usr/share/sddm/themes"
readonly config_root="/etc/sddm.conf.d"
readonly config_name="99-sberos-shell.conf"
readonly config_path="$config_root/$config_name"
readonly target_path="$themes_root/$theme_id"
readonly marker_name=".sberos-shell-managed"
readonly manifest_name=".sberos-shell-manifest"
readonly config_contents=$'[Theme]\nCurrent=sberos-light\n'

usage() {
    cat <<'EOF'
Usage: desktop/sddm/install.sh [install|uninstall|status]

Install or remove the SberOS SDDM theme. Installation requires root; status
can be run by any user. The script does not restart SDDM or change autologin.
EOF
}

fail() {
    printf 'sddm install: %s\n' "$*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 \
        || fail "не найдена команда '$1' (пакет Debian: $2)"
}

require_root() {
    [[ "$EUID" -eq 0 ]] || fail "для установки и удаления нужны права root; запусти через sudo"
}

check_source() {
    [[ -f "$theme_source/Main.qml" && -f "$theme_source/theme.conf" && -f "$theme_source/metadata.desktop" ]] \
        || fail "неполная тема в $theme_source"
}

write_manifest() {
    local directory="$1"
    (
        cd -- "$directory"
        find . -type f ! -name "$manifest_name" -print0 \
            | sort -z \
            | xargs -0 -r sha256sum
    )
}

check_managed_theme() {
    local actual_manifest

    [[ ! -L "$target_path" ]] || fail "путь темы является symlink и не будет изменён: $target_path"
    [[ -d "$target_path" ]] || return 1
    [[ -f "$target_path/$marker_name" && -f "$target_path/$manifest_name" ]] \
        || fail "каталог $target_path уже существует и не отмечен как установленный этим скриптом"

    actual_manifest="$(mktemp)"
    if ! write_manifest "$target_path" > "$actual_manifest" \
        || ! cmp -s "$target_path/$manifest_name" "$actual_manifest"; then
        rm -f -- "$actual_manifest"
        fail "тема $target_path изменена после установки; оставляю её без изменений"
    fi
    rm -f -- "$actual_manifest"
}

check_config_conflict() {
    local compatibility_current

    [[ ! -L "$config_path" ]] \
        || fail "конфигурация является symlink и не будет изменена: $config_path"
    if [[ -e "$config_path" ]] && ! cmp -s <(printf '%s' "$config_contents") "$config_path"; then
        fail "конфигурация уже существует и отличается; разреши конфликт вручную: $config_path"
    fi

    # SDDM reads the compatibility file /etc/sddm.conf after the config
    # directories, so a conflicting Current value there would override us.
    if [[ -f /etc/sddm.conf ]]; then
        compatibility_current="$(awk '
            /^\[Theme\][[:space:]]*$/ { in_theme = 1; next }
            /^\[/ { in_theme = 0 }
            in_theme && /^[[:space:]]*Current[[:space:]]*=/ {
                sub(/^[^=]*=[[:space:]]*/, "")
                sub(/[[:space:]]*[#;].*$/, "")
                value = $0
            }
            END { print value }
        ' /etc/sddm.conf)"
        if [[ -n "$compatibility_current" && "$compatibility_current" != "$theme_id" ]]; then
            fail "/etc/sddm.conf задаёт Theme.Current=$compatibility_current с более высоким приоритетом; разреши это вручную, файл не изменён"
        fi
    fi
}

make_staged_theme() {
    local staged="$1"

    mkdir -- "$staged"
    cp -a -- "$theme_source/." "$staged/"
    sed -i \
        -e 's/^Name=.*/Name=SberOS Light/' \
        -e 's/^Theme-Id=.*/Theme-Id=sberos-light/' \
        "$staged/metadata.desktop"
    printf 'Managed by desktop/sddm/install.sh.\n' > "$staged/$marker_name"
    write_manifest "$staged" > "$staged/$manifest_name"
}

install_theme() {
    local staged backup="" had_theme=0 config_temp=""

    require_root
    check_source
    require_command cp coreutils
    require_command awk mawk
    require_command cmp diffutils
    require_command find findutils
    require_command mktemp coreutils
    require_command mkdir coreutils
    require_command mv coreutils
    require_command rm coreutils
    require_command rmdir coreutils
    require_command sed sed
    require_command sha256sum coreutils
    require_command sort coreutils
    require_command xargs findutils
    require_command chmod coreutils
    [[ -d "$themes_root" ]] || fail "не найден каталог тем SDDM: $themes_root (установи sddm)"

    check_config_conflict
    mkdir -p -- "$config_root"
    if [[ -e "$target_path" || -L "$target_path" ]]; then
        check_managed_theme
        had_theme=1
    fi

    staged="$(mktemp -d "$themes_root/.${theme_id}.stage.XXXXXX")"
    rmdir -- "$staged"
    make_staged_theme "$staged"
    config_temp="$(mktemp "$config_root/.${config_name}.XXXXXX")"
    printf '%s' "$config_contents" > "$config_temp"
    chmod 644 "$config_temp"

    if (( had_theme )); then
        backup="$(mktemp -d "$themes_root/.${theme_id}.backup.XXXXXX")"
        rmdir -- "$backup"
        mv -- "$target_path" "$backup"
    fi

    if ! mv -- "$staged" "$target_path"; then
        [[ -z "$backup" ]] || mv -- "$backup" "$target_path"
        rm -f -- "$config_temp"
        fail "не удалось установить тему в $target_path"
    fi

    if ! mv -- "$config_temp" "$config_path"; then
        rm -rf -- "$target_path"
        [[ -z "$backup" ]] || mv -- "$backup" "$target_path"
        fail "не удалось записать конфигурацию $config_path"
    fi

    [[ -z "$backup" ]] || rm -rf -- "$backup"
    printf 'Установлена тема SDDM %s. Она будет выбрана при следующем запуске greeter.\n' "$theme_id"
    printf 'SDDM не перезапущен; текущая сессия не затронута.\n'
}

uninstall_theme() {
    local backup="" found_config=0

    require_root
    require_command cmp diffutils
    require_command find findutils
    require_command mktemp coreutils
    require_command mv coreutils
    require_command rm coreutils
    require_command rmdir coreutils
    require_command sha256sum coreutils
    require_command sort coreutils
    require_command xargs findutils

    if [[ -e "$target_path" || -L "$target_path" ]]; then
        check_managed_theme
    fi
    if [[ -e "$config_path" || -L "$config_path" ]]; then
        [[ ! -L "$config_path" ]] || fail "конфигурация является symlink и не будет удалена: $config_path"
        cmp -s <(printf '%s' "$config_contents") "$config_path" \
            || fail "конфигурация изменена и не будет удалена: $config_path"
        found_config=1
    fi

    if [[ -d "$target_path" ]]; then
        backup="$(mktemp -d "$themes_root/.${theme_id}.remove.XXXXXX")"
        rmdir -- "$backup"
        mv -- "$target_path" "$backup"
    fi
    if (( found_config )) && ! rm -- "$config_path"; then
        [[ -z "$backup" ]] || mv -- "$backup" "$target_path"
        fail "не удалось удалить конфигурацию $config_path"
    fi
    [[ -z "$backup" ]] || rm -rf -- "$backup"
    [[ ! -d "$config_root" ]] || rmdir --ignore-fail-on-non-empty "$config_root" 2>/dev/null || true

    printf 'Тема SDDM удалена; прежний выбор темы снова действует при следующем запуске greeter.\n'
    printf 'SDDM не перезапущен.\n'
}

show_status() {
    if [[ -d "$target_path" && -f "$target_path/$marker_name" ]]; then
        printf 'Тема: установлена (%s)\n' "$target_path"
    elif [[ -e "$target_path" || -L "$target_path" ]]; then
        printf 'Тема: каталог существует, но не отмечен этим установщиком (%s)\n' "$target_path"
    else
        printf 'Тема: не установлена\n'
    fi

    if [[ -f "$config_path" ]] && cmp -s <(printf '%s' "$config_contents") "$config_path"; then
        printf 'Выбор SDDM: настроен на %s\n' "$theme_id"
    elif [[ -e "$config_path" || -L "$config_path" ]]; then
        printf 'Выбор SDDM: конфигурация существует и отличается (%s)\n' "$config_path"
    else
        printf 'Выбор SDDM: не настроен этим установщиком\n'
    fi
}

action="${1:-install}"
[[ "$#" -le 1 ]] || { usage >&2; exit 2; }
case "$action" in
    install) install_theme ;;
    uninstall|--undo) uninstall_theme ;;
    status) show_status ;;
    -h|--help|help) usage ;;
    *) usage >&2; exit 2 ;;
esac
