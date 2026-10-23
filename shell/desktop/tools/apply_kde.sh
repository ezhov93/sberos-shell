#!/bin/bash
# apply_kde.sh apply|revert — installs the generated colour scheme for the current user (no root).
# apply keeps a dated backup of every file it touches in ~/.local/state/glass-desktop/kde-backup/ (first apply only).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; B="$HOME/.local/state/glass-desktop/kde-backup"; SCHEMES="$HOME/.local/share/color-schemes"
case "${1:-}" in
  apply)
    python3 "$ROOT/tools/gen_kde.py"
    if [ ! -d "$B" ]; then mkdir -p "$B"; kreadconfig6 --file kdeglobals --group General --key ColorScheme > "$B/colorscheme.txt"; kreadconfig6 --file kdeglobals --group General --key accentColorFromWallpaper > "$B/accent-from-wallpaper.txt"; kreadconfig6 --file kdeglobals --group General --key AccentColor > "$B/accent.txt"; fi
    mkdir -p "$SCHEMES"; cp "$ROOT/build/kde/Glass.colors" "$SCHEMES/Glass.colors"
    # a custom accent colour overrides the scheme's selection colours (blue highlights everywhere): the look is monochrome
    kwriteconfig6 --file kdeglobals --group General --key AccentColor --delete
    kwriteconfig6 --file kdeglobals --group General --key accentColorFromWallpaper false
    plasma-apply-colorscheme BreezeDark >/dev/null; plasma-apply-colorscheme Glass >/dev/null   # toggle so the change is picked up even if Glass was already set
    echo "applied. Revert: $0 revert" ;;
  revert)
    [ -d "$B" ] || { echo "no backup in $B"; exit 1; }
    a="$(cat "$B/accent.txt" 2>/dev/null || true)"; [ -n "$a" ] && kwriteconfig6 --file kdeglobals --group General --key AccentColor "$a"
    plasma-apply-colorscheme Glass >/dev/null 2>&1 || true; prev="$(cat "$B/colorscheme.txt" 2>/dev/null)"; [ -n "$prev" ] || prev=BreezeLight; plasma-apply-colorscheme "$prev" >/dev/null 2>&1 || true; afw="$(cat "$B/accent-from-wallpaper.txt" 2>/dev/null)"; if [ -n "$afw" ]; then kwriteconfig6 --file kdeglobals --group General --key accentColorFromWallpaper "$afw"; else kwriteconfig6 --file kdeglobals --group General --key accentColorFromWallpaper --delete; fi
    rm -f "$SCHEMES/Glass.colors" "$SCHEMES/GlassLight.colors"
    rm -rf "$B"; echo "reverted to $(kreadconfig6 --file kdeglobals --group General --key ColorScheme)" ;;
  *) echo "usage: $0 apply|revert"; exit 2 ;;
esac
