#! /usr/bin/env bash

# VARS
GSET="gsettings set"
GDESKTOP="org.gnome.desktop"
GINTERFACE="$GDESKTOP.interface"
GKEYBIND="$GDESKTOP.wm.keybindings"
GDAEMON="org.gnome.settings-daemon.plugins.media-keys"

# Clean slate
dconf reset -f /org/gnome/

# Theme
$GSET $GINTERFACE clock-format '12h'
$GSET $GINTERFACE cursor-theme 'Adwaita'
$GSET $GINTERFACE gtk-theme 'Adwaita-dark'
$GSET $GINTERFACE icon-theme 'Adwaita'

# Touchpad
$GSET $GDESKTOP.peripherals.touchpad natural-scroll true
$GSET $GDESKTOP.peripherals.touchpad tap-to-click true
$GSET $GDESKTOP.wm.preferences button-layout ':close'

# Shortcuts
$GSET $GKEYBIND switch-applications "[]"
$GSET $GKEYBIND switch-applications-backward "[]"
$GSET $GKEYBIND switch-windows "['<alt>tab']"
$GSET $GKEYBIND switch-windows-backward "['<Shift><Alt>Tab']"

DDAEMON_C0="/${GDAEMON//\./\/}/custom-keybindings/custom0/" 
$GSET $GDAEMON custom-keybindings "['$DDAEMON_C0']"
dconf load "$DDAEMON_C0" << EOF
[/]
binding='<Primary><Alt>t'
command='gnome-terminal'
name='term'
EOF

# Dash layout
$GSET org.gnome.shell favorite-apps "['firefox.desktop', 'spotify.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop']"

# Terminal
term_profile=$(gsettings get org.gnome.Terminal.ProfilesList default)
term_profile=${term_profile:1:-1}
term_dconf="/org/gnome/terminal/legacy/profiles:/:$term_profile/"
term_gsetting="org.gnome.Terminal.Legacy.Profile:$term_dconf"

$GSET "$term_gsetting" use-theme-colors false
$GSET "$term_gsetting" bold-is-bright true
$GSET "$term_gsetting" background-color 'rgb(46,52,54)'
$GSET "$term_gsetting" foreground-color 'rgb(211,215,207)'

