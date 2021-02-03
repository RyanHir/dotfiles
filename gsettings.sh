#! /bin/sh

# VARS
GSET="gsettings set"

# Clean slate
dconf reset -f /org/gnome/

# Theme
$GSET org.gnome.desktop.interface clock-format '12h'
$GSET org.gnome.desktop.interface cursor-theme 'Adwaita'
$GSET org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
$GSET org.gnome.desktop.interface icon-theme 'Adwaita'

# Touchpad
$GSET org.gnome.desktop.peripherals.touchpad natural-scroll true
$GSET org.gnome.desktop.peripherals.touchpad tap-to-click true
$GSET org.gnome.desktop.wm.preferences button-layout ':close'

# Dash layout
$GSET org.gnome.shell favorite-apps "['firefox.desktop', 'spotify.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop']"

