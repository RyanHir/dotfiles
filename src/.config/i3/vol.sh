#! /bin/sh

operator=$(echo "$1" | cut -c1-1)
current=$(pacmd dump-volumes | awk 'NR==1{print $8}' | sed 's/\%//')
[ $operator = "+" ] && [ $current -ge 100 ] && exit

pactl set-sink-volume @DEFAULT_SINK@ $1
