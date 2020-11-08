#! /bin/sh

operator=$(echo "$1" | cut -c1-1)
current=$(sh $HOME/.local/bin/statusbar/volume | sed "s/.*://;s/%//" | tr -d " ")

if [ "$operator" = "+" ]
then
	if [ "$current" -ge 100 ]
	then
		exit
	fi
fi

pactl set-sink-volume @DEFAULT_SINK@ $1
