#! /usr/bin/env bash

. "$HOME/.config/wallpaper.env"

#SHAPE=$(identify "$WALL_PATH" | awk '{print $4}')
#convert "$WALL_PATH" RGB:- \
#    | i3lock --raw "$SHAPE:rgb" --image /dev/stdin

i3lock -c "$WALL_COLR"
