# SberOS SDDM theme

`install.sh` installs the theme as `sberos-light` in `/usr/share/sddm/themes`
and selects it with `/etc/sddm.conf.d/99-sberos-shell.conf`. Run installation
and removal as root; `status` is read-only:

```sh
sudo desktop/sddm/install.sh install
desktop/sddm/install.sh status
sudo desktop/sddm/install.sh uninstall
```

The installer copies the theme from `usr/share/sddm/themes/hexabee-light/`,
retains its attribution and license metadata, and changes only its display name
and theme ID in the installed copy. A private manifest lets it upgrade or remove
that copy only while its files remain unchanged. Existing files at the target
paths are preserved and reported as conflicts. Removing the exact config drop-in
restores SDDM's previous theme selection.

The installer does not restart SDDM, alter PAM, or enable autologin. In
particular, it does not install `etc/sddm.conf.d/kde_settings.conf`, which is a
local example containing an autologin setting. SDDM reads `/etc/sddm.conf` with
higher priority than the configuration directories; if that compatibility file
selects another theme, installation stops without changing it. A changed
drop-in or modified installed theme also stops removal rather than deleting
user changes.

After installation, the theme is used when the SDDM greeter next starts. A
greeter restart or reboot may be needed for it to appear; the script deliberately
does not interrupt an active desktop session. Relevant scenarios: `01-01`,
`01-02`, `01-21`, `01-22`, `01-23`, `01-26`, `01-30`, `01-31`.
