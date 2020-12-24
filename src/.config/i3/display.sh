#! /bin/sh

# Disable Displays that are disconnected but think they still exist
xrandr | awk '/disconnected/{print $1}' | xargs -I{} xrandr --output {} --off

# Laptop Display
xrandr --output eDP-1 --auto

if xrandr | grep "DP-2-1 connected" > /dev/null; then
	xrandr --output DP-2-1 --auto --left-of eDP-1 --primary
fi
