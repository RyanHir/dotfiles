#! /bin/sh

operator=$(echo "$1" | cut -c1-1)
current=$(sh $HOME/.local/bin/statusbar/volume | sed "s/.*://;s/%//" | tr -d " ")

[ "$operator" = "+" ] && [ "$current" -ge 100 ] && exit

# Update Audio Server
pactl set-sink-volume "@DEFAULT_SINK@" "$1"

# Update UI
pkill -RTMIN+10 i3blocks

