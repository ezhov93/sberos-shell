# Sirca Shell

I wanted my KDE desktop to look like glass, and I could not get there with Plasma's own panels, so I wrote my own. Sirca Shell
is a top bar and a dock for KDE Plasma 6 on Wayland. The popups (quick settings, launcher, notifications, the media player)
grow out of the bar and the dock instead of floating next to them. KWin is still your compositor and your apps do not
change. Only Plasma's panels get replaced, and one command brings them back.

https://github.com/user-attachments/assets/1a73bd3d-5c41-4f6a-a333-6b80d5c2df79

## Read this first

I use this every day, but on exactly one computer: Ubuntu 26.04, Plasma 6.6, an NVIDIA card and one ultrawide screen. It is
the work of one person. On your machine something will probably be off, and I would rather tell you now than have you find
out the hard way.

- While the shell is on, Plasma's panels are off. Your panel layout is saved first, and `sirca-shell-switch off` puts it back
  exactly as it was. If the shell crashes five times within a minute, Plasma's panels come back by themselves.
- It takes over some shortcuts while it runs: Meta, Meta+Space, Meta+V, Meta+A, Print, Meta+Shift+S and R, Ctrl+Alt+Del and
  Alt+Tab. You get them back when you switch it off.
- The shell changes only its own appearance settings; it does not install or change system desktop themes.
- Only Plasma on Wayland. No X11, no Hyprland, Sway or GNOME.
- Several screens: every connected screen gets its own wallpaper and panel by default; edit mode can disable individual panels.
  Popups and shortcuts use the active or primary screen. I have tested two virtual screens and am still checking real hardware.
- I have never run it on AMD or Intel graphics. It should work. If it does not, I want to hear about it.
- No telemetry. It sends nothing anywhere.
- There is no warranty (GPL-3.0-or-later).

The installer goes through all of this with you before it touches anything, checks your system and says what will not work
on it, and lets you pick only the parts you want. `./install.py --dry-run` prints every command and changes nothing.

### If something breaks

Open an issue and tell me what you ran and what happened. I will go through it with you until it works or until we know why
it cannot. I mean that: this has only ever run on my machine, so your problem is most likely a bug I have not seen yet, not
something you did wrong. Your Plasma version, your GPU and the output of `./install.py --dry-run` are the most useful
things to include. If you cannot log in properly or your panels are gone, run `sirca-shell-switch off` from a terminal
first, then write to me.

## Interface and themes

The shell provides quick settings, an application and file launcher, grouped notifications, media controls, window previews, and an edit mode for arranging the bar and dock. Keyboard shortcuts include Meta+Space for search, Meta+A for the tile picker, Meta+V for clipboard history, and Meta+Shift+S for screenshots and screen recording.

The shell provides light and dark modes, seven accent colours, and bundled wallpapers. These settings affect Sirca only; KDE and GTK themes remain under system settings.

## SberOS workspace adaptation

The adapted shell combines the top bar and dock into one bottom panel. The old
`panelLayout` setting is ignored; the two-panel layout is no longer available. PANEL-001 divides it
into five opaque blocks with a fixed central Oska entry area, using UI Kit backgrounds.
The Sber menu now provides shell settings, terminal context/pinning, power/session
and collapse; full Oska behaviour remains a separate task. See
[shell/README.md](shell/README.md#sberos-unified-panel).

The shell's settings window now uses the shared SberOS UI Kit from `../ui-kit/`.
Build the UI Kit before building or installing this adapted shell; the build and
runtime path are documented in [shell/README.md](shell/README.md#sberos-adaptation).
The upstream installation instructions below do not build that workspace dependency.

The Smart Panel source requirements describe a GNOME extension. Their mapping
to this Qt/KWin prototype, requirement statuses and agreed scope are
tracked in [PANEL-000](../docs/tasks/PANEL-000.md) and the
[adaptation table](../docs/rules/panel-adaptation.md). The current unified default
does not constitute a production rollout or a migration from the GNOME panel.

## Install

```
./install.py
```

Install the shell alone or import the author’s optional bar and dock layout. Both choices leave system themes and wallpapers unchanged.

```
sirca-shell-switch on      # saves your Plasma panels and takes over
sirca-shell-switch off     # your panels come back exactly as they were
./uninstall.py             # removes what was installed, part by part
```


## What works and what does not

| | |
|---|---|
| KDE Plasma 6.6, Wayland, KWin | yes, this is what I use |
| KDE Plasma 6.7 | builds and runs against 6.7.5 in a headless test session (bar, dock, launcher, quick settings). I do not use 6.7 day to day yet, so tell me what you see |
| Older Plasma 6 | maybe. The shell might miss things |
| X11, Hyprland, Sway, GNOME | no |
| One screen | yes |
| Several screens | wallpaper and panel on all connected screens by default; individual panels can be disabled. Tested with two virtual screens only |
| NVIDIA | yes, developed on it |
| AMD, Intel | untested. Please tell me how it goes |
| Without plasmashell | yes: `sirca-shell-switch plasma off` masks it and the shell takes over the desktop, a passive system OSD and notifications (this is how I run it now). Volume, microphone and brightness changes show an icon, level and progress bar; other system OSD events show their text. `plasma on` brings it back |

**How heavy is it?** On my machine (7800X3D, RTX 5080, one 5120x1440 screen), from systemd's own accounting of
whole-day sessions: plasmashell with its panels averaged 1.4–1.6 % of one core, Sirca Shell doing the same job 0.2–0.4 %,
with a similar memory footprint (about 420 MB resident, peaks under 1 GB for both). Not a benchmark, just my days. The

## What is in here

| folder | what |
|---|---|
| `shell/` | the shell itself (C++ and QML). Its README lists every feature, the settings, scripting and the build dependencies |
| `wallpapers/` | the wallpapers I use: one picture in seven colours, dark and light (5120 × 1440) |
| `setups/` | the colour themes, and my bar and dock layout as a file for `sirca-shell-setup import` |

## Licence and credits

Everything written for this project is GPL-3.0-or-later, see `LICENSE`. A lot of it stands on other people's work, and each
folder keeps their notices:

- `shell/qml/control/` derives from **Plasma Control Hub** by zayronxio; `shell/applets/` holds forks of KDE Plasma applets (their headers are kept).
- Fonts: **Outfit** and **Inter**, SIL Open Font License.
- Icons come from the system icon theme selected by the user; no icon pack is bundled or installed.

Thank you to all of them.

The agreed Smart Panel scope keeps our Qt/QML/UI Kit stack and KWin/Wayland;
no GNOME extension is planned. Corporate settings are outside MVP. The Sber menu
settings entry opens the shell settings rather than KDE systemsettings.
