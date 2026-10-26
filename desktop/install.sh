#!/usr/bin/env bash
set -Eeuo pipefail

readonly desktop_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
readonly state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
readonly state_dir="$state_home/sberos-desktop/installer"
readonly backup_dir="$state_dir/original"
readonly manifest="$state_dir/manifest.tsv"
readonly import_marker='/* SberOS desktop managed import */'

action="install"
mode="light"
dry_run=0
action_set=0
temp_dir=""

usage() {
    cat <<'USAGE'
Usage: desktop/install.sh [install|uninstall|status] [--mode light|dark] [--dry-run]

Install generated KDE color schemes, GTK user styles and the SberOS Kvantum
widget theme for the current user. Existing files are backed up in
$XDG_STATE_HOME/sberos-desktop/installer and restored by uninstall.

This script does not change the active Plasma color scheme or widget style,
restart applications, install the lock screen, or configure SDDM.
Those components have separate flows: desktop/lock/install.sh and
sudo desktop/sddm/install.sh.
USAGE
}

fail() {
    printf 'desktop install: %s\n' "$*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || fail "не найдена обязательная команда '$1'"
}

scope_path() {
    case "$1" in
        config) printf '%s/%s\n' "$config_home" "$2" ;;
        data) printf '%s/%s\n' "$data_home" "$2" ;;
        *) fail "неизвестный тип пути: $1" ;;
    esac
}

backup_path() {
    printf '%s/%s/%s\n' "$backup_dir" "$1" "$2"
}

file_hash() {
    sha256sum -- "$1" | cut -d ' ' -f 1
}

declare -A saved_exists=()
declare -A saved_hash=()
declare -A installed_hash=()
declare -a scopes=()
declare -a relatives=()
declare -a sources=()

asset_key() {
    printf '%s:%s' "$1" "$2"
}

load_manifest() {
    local scope relative existed old_hash new_hash key
    [[ -f "$manifest" ]] || return 1
    while IFS=$'\t' read -r scope relative existed old_hash new_hash; do
        [[ -n "$scope" && -n "$relative" ]] || continue
        key="$(asset_key "$scope" "$relative")"
        saved_exists["$key"]="$existed"
        saved_hash["$key"]="$old_hash"
        installed_hash["$key"]="$new_hash"
    done < "$manifest"
}

add_asset() {
    scopes+=("$1")
    relatives+=("$2")
    sources+=("$3")
}

check_manifest_files() {
    local key scope relative target expected
    for key in "${!installed_hash[@]}"; do
        scope="${key%%:*}"
        relative="${key#*:}"
        target="$(scope_path "$scope" "$relative")"
        expected="${installed_hash[$key]}"
        [[ -n "$expected" ]] || fail "состояние установки неполное; резервная копия сохранена в $state_dir"
        [[ ! -L "$target" ]] || fail "установленный путь стал symlink и не будет изменён: $target"
        [[ -f "$target" ]] || fail "установленный файл отсутствует; восстановление остановлено: $target"
        [[ "$(file_hash "$target")" == "$expected" ]] \
            || fail "файл изменён после установки; оставляю его без изменений: $target"
    done
}

prepare_state() {
    local scope="$1" relative="$2" target key saved backup
    key="$(asset_key "$scope" "$relative")"
    target="$(scope_path "$scope" "$relative")"
    [[ ! -L "$target" ]] || fail "путь является symlink и не будет изменён: $target"

    if [[ -n "${saved_exists[$key]+present}" ]]; then
        return 0
    fi

    if [[ -e "$target" ]]; then
        [[ -f "$target" ]] || fail "ожидался обычный файл: $target"
        saved_exists["$key"]=1
        saved_hash["$key"]="$(file_hash "$target")"
        (( dry_run )) && return 0
        backup="$(backup_path "$scope" "$relative")"
        mkdir -p -- "$(dirname -- "$backup")"
        cp -a -- "$target" "$backup"
    else
        saved_exists["$key"]=0
        saved_hash["$key"]="-"
    fi
}

write_manifest() {
    local temporary key scope relative
    mkdir -p -- "$state_dir"
    temporary="$(mktemp "$state_dir/.manifest.XXXXXX")"
    for key in "${!saved_exists[@]}"; do
        scope="${key%%:*}"
        relative="${key#*:}"
        printf '%s\t%s\t%s\t%s\t%s\n' \
            "$scope" "$relative" "${saved_exists[$key]}" \
            "${saved_hash[$key]}" "${installed_hash[$key]:--}" >> "$temporary"
    done
    sort -o "$temporary" "$temporary"
    mv -- "$temporary" "$manifest"
}

restore_from_manifest() {
    local key scope relative target backup exists
    for key in "${!saved_exists[@]}"; do
        scope="${key%%:*}"
        relative="${key#*:}"
        target="$(scope_path "$scope" "$relative")"
        exists="${saved_exists[$key]}"
        if [[ "$exists" == 1 ]]; then
            backup="$(backup_path "$scope" "$relative")"
            [[ -f "$backup" ]] || fail "резервная копия отсутствует: $backup"
            mkdir -p -- "$(dirname -- "$target")"
            cp -a -- "$backup" "$target"
        else
            rm -f -- "$target"
        fi
    done
}

run_install() {
    local output source target original gtk_css generated_css
    local i key scope relative

    [[ "$EUID" -ne 0 ]] || fail "это пользовательский установщик; запусти без sudo"
    [[ "$config_home" == /* && "$data_home" == /* && "$state_home" == /* ]] \
        || fail "XDG_CONFIG_HOME, XDG_DATA_HOME и XDG_STATE_HOME должны быть абсолютными путями"
    [[ ! -L "$state_dir" ]] || fail "каталог состояния является symlink и не будет изменён: $state_dir"
    require_command python3
    require_command sha256sum
    require_command cut
    require_command cmp
    require_command grep
    require_command cp
    require_command cat
    require_command install
    require_command mkdir
    require_command mktemp
    require_command mv
    require_command rm
    require_command sort
    require_command dirname

    temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/sberos-desktop.XXXXXX")"
    trap '[[ -z "${temp_dir:-}" ]] || rm -rf -- "$temp_dir"' EXIT
    output="$temp_dir/generated"
    python3 "$desktop_dir/tools/gen_sber_theme.py" --output "$output"

    for source in SberOSLight.colors SberOSDark.colors; do
        cmp -s "$output/kde/$source" "$desktop_dir/color_scheme/$source" \
            || fail "desktop/color_scheme/$source устарел; обнови его из gen_sber_theme.py"
    done

    add_asset data color-schemes/SberOSLight.colors "$output/kde/SberOSLight.colors"
    add_asset data color-schemes/SberOSDark.colors "$output/kde/SberOSDark.colors"
    add_asset config Kvantum/SberOS/SberOS.kvconfig "$desktop_dir/Kvantum/SberOS/SberOS.kvconfig"
    add_asset config Kvantum/SberOS/SberOS.svg "$desktop_dir/Kvantum/SberOS/SberOS.svg"
    add_asset config Kvantum/SberOS/SberOSDark.kvconfig "$desktop_dir/Kvantum/SberOS/SberOSDark.kvconfig"
    add_asset config Kvantum/SberOS/SberOSDark.svg "$desktop_dir/Kvantum/SberOS/SberOSDark.svg"
    add_asset config Kvantum/kvantum.kvconfig "$desktop_dir/Kvantum/kvantum.kvconfig"

    if [[ "$mode" == light ]]; then
        generated_css_3="$output/gtk/light/gtk-3.0.css"
        generated_css_4="$output/gtk/light/gtk-4.0.css"
    else
        generated_css_3="$output/gtk/dark/gtk-3.0.css"
        generated_css_4="$output/gtk/dark/gtk-4.0.css"
    fi
    add_asset config gtk-3.0/sberos.css "$generated_css_3"
    add_asset config gtk-4.0/sberos.css "$generated_css_4"

    if [[ -f "$manifest" ]]; then
        load_manifest
        check_manifest_files
    elif [[ -e "$state_dir" ]]; then
        fail "найден каталог состояния без manifest; проверь резервную копию вручную: $state_dir"
    fi

    for ((i=0; i<${#scopes[@]}; i++)); do
        scope="${scopes[$i]}"
        relative="${relatives[$i]}"
        source="${sources[$i]}"
        prepare_state "$scope" "$relative"
        target="$(scope_path "$scope" "$relative")"
        if (( dry_run )); then
            printf 'Установить %s -> %s\n' "$source" "$target"
        else
            install -D -m 644 -- "$source" "$target"
        fi
    done

    for relative in gtk-3.0/gtk.css gtk-4.0/gtk.css; do
        scope=config
        prepare_state "$scope" "$relative"
        target="$(scope_path "$scope" "$relative")"
        key="$(asset_key "$scope" "$relative")"
        original="$(backup_path "$scope" "$relative")"
        if [[ "${saved_exists[$key]}" == 1 ]]; then
            if (( dry_run )); then
                original="$target"
            else
                [[ -f "$original" ]] || fail "резервная копия отсутствует: $original"
            fi
        else
            original="$temp_dir/empty-gtk.css"
            : > "$original"
        fi
        if grep -Fq "$import_marker" "$original" \
            || grep -Fq '@import url("sberos.css");' "$original"; then
            fail "GTK stylesheet уже содержит импорт SberOS вне состояния этого установщика: $target"
        fi
        gtk_css="$temp_dir/$(basename "$(dirname "$target")").gtk.css"
        {
            printf '%s\n@import url("sberos.css");\n' "$import_marker"
            cat -- "$original"
        } > "$gtk_css"
        if (( dry_run )); then
            printf 'Добавить управляемый импорт в %s\n' "$target"
        else
            install -D -m 644 -- "$gtk_css" "$target"
        fi
    done

    if (( dry_run )); then
        printf 'Режим предпросмотра завершён; профиль пользователя не изменён.\n'
        return 0
    fi

    for ((i=0; i<${#scopes[@]}; i++)); do
        scope="${scopes[$i]}"
        relative="${relatives[$i]}"
        target="$(scope_path "$scope" "$relative")"
        key="$(asset_key "$scope" "$relative")"
        installed_hash["$key"]="$(file_hash "$target")"
    done
    for relative in gtk-3.0/gtk.css gtk-4.0/gtk.css; do
        key="$(asset_key config "$relative")"
        target="$(scope_path config "$relative")"
        installed_hash["$key"]="$(file_hash "$target")"
    done
    write_manifest
    printf 'Установлены палитры KDE, Kvantum и GTK (%s) для текущего пользователя.\n' "$mode"
    printf 'Резервные копии: %s\n' "$backup_dir"
    printf 'Выбор системной палитры и widgetStyle не менялся; установщики lock screen и SDDM не запускались.\n'
}

run_uninstall() {
    local key scope relative target
    [[ "$EUID" -ne 0 ]] || fail "это пользовательский установщик; запусти без sudo"
    [[ ! -L "$state_dir" ]] || fail "каталог состояния является symlink и не будет изменён: $state_dir"
    require_command sha256sum
    require_command cut
    require_command cp
    require_command rm
    require_command mkdir
    if [[ ! -f "$manifest" ]]; then
        printf 'Установка SberOS Desktop не найдена.\n'
        return 0
    fi
    load_manifest
    check_manifest_files
    if (( dry_run )); then
        for key in "${!saved_exists[@]}"; do
            scope="${key%%:*}"
            relative="${key#*:}"
            printf 'Восстановить %s\n' "$(scope_path "$scope" "$relative")"
        done
        printf 'Режим предпросмотра завершён; профиль пользователя не изменён.\n'
        return 0
    fi
    restore_from_manifest
    rm -rf -- "$state_dir"
    printf 'Удалены файлы установщика; сохранённые ранее файлы восстановлены.\n'
    printf 'Приложения не перезапущены, активная палитра и widgetStyle не переключались.\n'
}

run_status() {
    local key scope relative target expected actual state
    [[ "$EUID" -ne 0 ]] || fail "проверяй статус от имени пользователя, которому устанавливались файлы"
    require_command sha256sum
    require_command cut
    if [[ ! -f "$manifest" ]]; then
        printf 'SberOS Desktop не установлен этим скриптом.\n'
        return 0
    fi
    load_manifest
    for key in "${!saved_exists[@]}"; do
        scope="${key%%:*}"
        relative="${key#*:}"
        target="$(scope_path "$scope" "$relative")"
        expected="${installed_hash[$key]}"
        if [[ ! -e "$target" ]]; then
            state='отсутствует'
        elif [[ -L "$target" ]]; then
            state='symlink (вручную проверить)'
        else
            actual="$(file_hash "$target")"
            if [[ "$actual" == "$expected" ]]; then state='установлен'; else state='изменён'; fi
        fi
        printf '%s: %s\n' "$target" "$state"
    done
}

while (($#)); do
    case "$1" in
        install|uninstall|status)
            (( action_set == 0 )) || { usage >&2; exit 2; }
            action="$1"
            action_set=1
            shift
            ;;
        --mode)
            [[ $# -ge 2 ]] || { usage >&2; exit 2; }
            mode="$2"
            [[ "$mode" == light || "$mode" == dark ]] || fail "--mode принимает light или dark"
            shift 2
            ;;
        --dry-run)
            dry_run=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *) usage >&2; exit 2 ;;
    esac
done

case "$action" in
    install) run_install ;;
    uninstall) run_uninstall ;;
    status) run_status ;;
esac
