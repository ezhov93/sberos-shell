# Appearance architecture

[简体中文](AppearanceArchitecture.zh-CN.md)

For AI contributors. Read [project boundaries](ProjectArchitecture.md) and
[window rendering](WindowAppearance.md) before changing presentation or compositor code.
This is the current design, not a runtime acceptance report.

## Ownership and source entry points

| Owner | Contract |
| --- | --- |
| `shell/desktop/modules/common/AppearanceConfigService.qml` | Validated Shell appearance settings, migrations and snapshots |
| `AppearanceTokens.qml` in the same directory | Derived visual tokens, version 9; consumers use tokens rather than duplicate style branches |
| `IconAppearanceService.qml`, `BundledIcons.qml`, `BundledIcon.qml`, `SystemIconResolver.qml` | Icon mode/persistence, named bundled assets and centralized system-theme fallback |
| `shell/desktop/DesktopEnvironment.qml` | `appearance-settings` IPC endpoint |
| `apps/settings/` | Separate process; edits through IPC, never imports Shell internals |
| `shared/qml/colorize/` | Portable pure-JS palette/HCT algorithms; no dependency on Quickshell |
| `shared/qml/controls/` and Shell common components | Reusable surfaces/controls that consume explicit theme inputs |

`AppearanceConfigService` owns Shell configuration; `AppearanceTokens` derives colors, geometry,
opacity and motion. Surfaces represented in the Smart Panel mock use the Shell-local
`FrostedSurface`: KWin's `Kos.SurfaceShape` draws the translucent tint and background blur,
while QML keeps text and controls sharp. `OpaqueSurface` remains for surfaces outside the mock
and inner cards that the mock depicts as solid. The Shell's resolved light/dark mode is synchronized to `Core.Settings`,
so UI Kit palette values follow the Shell configuration. Removed shell-style and glass-preset
fields have no migration or compatibility aliases; configuration loads only supported fields.
Bar layout accepts full-width or floating. Dock pins, sizes and independent state are preserved.
Standalone app preferences remain separate; see [project context](../PROJECT_CONTEXT.md).

The Shell creates one bottom Dock surface. A legacy `barIntegratedWithDock: false`
value is ignored; the standalone top Bar and its settings page are not launched.
The Sber entry point is mounted as the Dock's leading accessory and uses the
existing Shell action services. The five-zone layout and screen-centered Oska
search remain tracked separately in [`PANEL-010`](../../docs/tasks/PANEL-010.md).

## Persistence and IPC

`Quickshell.stateDir/appearance/config.json` is loaded from the supported field set only.
Removed style fields and their migrations, aliases and fallbacks are not retained. Validate
remaining values before applying them. Icon settings use separate
`appearance/icon-appearance.json`; it reads its supported schema without fallback to the old
Dock configuration path. Saving is debounced through `JsonConfigStore` → platform `state.write`
→ `QSaveFile`, rather than a QML shell command.

Settings calls `appearance-settings` snapshot/update operations and receives a complete snapshot.
Check the endpoint when adding a supported setting; expose bounded values and handle unavailable
Shell/platform services. Legacy Glass controls and alternate Shell appearance modes have been
removed from the Shell copy; `refs/NextKde/` remains the comparison source.

## Color and contrast invariants

Use `AppearanceTokens.isDarkTheme` and semantic content tokens for foreground contrast. Do not
pick ink directly from the system dark-mode flag. Mock-targeted surfaces use the local frosted
material and an opaque fallback when the compositor protocol is unavailable; other shell-owned
surfaces use palette fills. Transparent window roots are allowed only when a child surface paints
the visible content. Compositor protocol support remains available to other consumers but is not enabled for Shell
surfaces. See protocol ownership in [window appearance](WindowAppearance.md).

Wallpaper accent palettes are generated locally in `shared/qml/colorize/`: `monet` uses CAM16/HCT,
while `chinese` and `japanese` select traditional-color data with the shared contrast policy.
Shell surface colors come from `Sber.Theme` instead. Keep sRGB byte rounding, HCT gamut handling
and contrast regression tests together; do not replace the wallpaper algorithm with external
`matugen` processes or approximate Lab conversion. Extract wallpaper colors from the original
image, not Plasma's black/white placeholder. Resolve Plasma's wallpaper configuration through the
current `plasmashellrc` ShellPackage, not a hardcoded old appletsrc.

The source colorize directory is not a compiled `Kos.Ui` module. Keep source aliases, `qmldir`,
resource deployment and relative imports working in both Shell and Settings. Portable app/shared
code must not import Quickshell-specific adapters. Opaque Shell surfaces use shared UI Kit tokens;
do not scatter individual style checks throughout every control.

## Icons, geometry and motion

Register Shell-owned imagery by stable name in `BundledIcons`; render through `BundledIcon` or
its registry source. Do not depend on workstation absolute paths or font glyphs. Application
icons, media art and file thumbnails follow their own contracts. System-theme exceptions such as
the Dock trash icon resolve through `SystemIconResolver`, with centralized candidates and bundled fallback.

Use token geometry and motion values consistently across Dock, bar and widgets. Dock window-animation
targets use stable layout slot centers and static icon size in compositor-global coordinates;
hover magnification must not move a minimize target. Keep desktop file spacing in
[DesktopIcons](DesktopIcons.md). Material surfaces and continuous compositor corners have different
rendering owners; a visual style change must not duplicate clipping or shadows.

## Verification and review

Run checks per [Development](Development.md). Cover supported snapshot/IPC values,
light/dark/system themes, frosted mock surfaces and opaque fallback, bar/Dock integration, source/installed
module paths, icon resolution and reduced motion. Review fullscreen/maximized/mixed-scale
window behavior separately in [WindowAppearance](WindowAppearance.md). GUI checks must confirm
blur stays behind surface content and does not clip at rounded corners.
