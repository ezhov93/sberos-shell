# Desktop integration

The repository-level `desktop/` directory is the source of truth for desktop
integration work.

- `Kvantum/`, `lock/`, `sddm/`, and `wallpapers/` contain the current SberOS
  desktop assets and installers.
- `tools/`, `tests/`, and `docs/` contain the SberOS palette adapter, checks,
  and migration notes.
- See [`docs/SBEROS.md`](docs/SBEROS.md) for the UI Kit palette contract and
  integration boundaries.

Sirca no longer bundles its former Glass desktop tools or offers their KDE/GTK
appearance installer. Its light/dark mode and accent themes remain shell-local.

## User installation

From the repository root, install the generated KDE color schemes, GTK user
styles, and Kvantum theme for the current user:

```sh
desktop/install.sh install --mode light
desktop/install.sh install --mode dark
desktop/install.sh status
desktop/install.sh uninstall
```

`install.sh` generates palettes from UI Kit resources, checks the checked-in
`color_scheme/SberOSLight.colors` and `SberOSDark.colors`, and backs up files it
replaces under `$XDG_STATE_HOME/sberos-desktop/installer/`. `uninstall` restores
those files and refuses to remove files changed after installation. The selected
GTK stylesheet is imported from `gtk.css`; both KDE color schemes are installed
but not applied. Kvantum's user selector is set to `SberOS`, while KDE's
`widgetStyle` remains unchanged. The `--mode` option selects only the GTK CSS;
running applications are not restarted.

The Plasma lock screen and SDDM greeter have separate installers because they
use different system components and permissions:

```sh
desktop/lock/install.sh install
sudo desktop/sddm/install.sh install
```

The root installer does not install either component or change the active
session. SDDM is not restarted automatically.
