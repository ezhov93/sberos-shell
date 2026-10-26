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

The screenshots confirm rendering of the copied Kvantum configs and SVG theme
assets, including green selected rows. They use the `offscreen` platform and do
not verify Wayland integration, popup windows, blur, or the appearance of the
whole Plasma desktop. No user configuration or installed theme files were
changed.
