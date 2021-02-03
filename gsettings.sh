#! /bin/sh

command -v gsettings > /dev/null || exit

dconf reset -f /org/gnome/

GSET="gsettings set"

$GSET org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
$GSET org.gnome.desktop.peripherals.touchpad natural-scroll true
$GSET org.gnome.desktop.peripherals.touchpad tap-to-click true
$GSET org.gnome.desktop.wm.preferences button-layout ':close'

dconf load /org/gnome/shell/ << EOF
[/]
favorite-apps=['firefox.desktop', 'spotify.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop']
EOF

