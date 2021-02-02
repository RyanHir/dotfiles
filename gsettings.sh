#! /bin/sh

command -v gsettings > /dev/null || exit

GSET="gsettings set"

KEYBIND="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/"

$GSET org.gnome.desktop.peripherals.touchpad tap-to-click true
$GSET org.gnome.desktop.peripherals.touchpad natural-scroll true
$GSET org.gnome.desktop.wm.preferences button-layout ':close'

$GSET org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
    "['$KEYBIND/custom0/']"

dconf reset -f "$KEYBIND" 
dconf load "$KEYBIND" << EOF
[custom0]
binding='<Primary><Alt>t'
command='gnome-terminal'
name='term'
EOF

