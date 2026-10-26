# Kvantum UI Kit palette preview

Date: 2026-10-26. Scenario: `09-02` (light/dark desktop style).

The SberOS light and dark Kvantum configs were previewed with Qt 6.11.2 on
Linux using the installed `Kvantum::Style` plugin and an isolated temporary
XDG profile. The preview contains common Qt Widgets controls: buttons, a text
field, combo box, checkbox, radio button, slider, progress bar, and selected /
disabled list rows. The preview palette matches the generated SberOS UI Kit KDE
schemes so the selected state can be inspected without changing the user's
system color scheme.

- [Light theme](kvantum-light.png)
- [Dark theme](kvantum-dark.png)

The offscreen screenshots confirm rendering of the copied Kvantum configs and
SVG theme assets, including green selected rows. For these captures, a Qt
`QPalette` matching the generated SberOS color schemes was set explicitly; the
temporary profile did not install KDE color schemes.

After the preview, the user requested installation. The updated theme is now in
the user's `~/.config/Kvantum/SberOS/`; its previous copy and selector are backed
up under
`~/.local/state/sberos-kvantum-20261026-before-ui-kit-palette/`. The installed
light theme was opened in Kvantum Preview under the current Wayland session and
captured here: [installed light theme](kvantum-wayland.png). The live session
uses `SberOSLight`. The dark theme was rendered offscreen; Wayland dark mode,
popup windows, blur, and other Plasma surfaces remain unchecked.
