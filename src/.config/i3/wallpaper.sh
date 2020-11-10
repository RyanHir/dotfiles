#! /bin/sh

set -e

SLEEP_MINUTES="$1"

SLEEP_SECONDS=$((SLEEP_MINUTES * 60))
while true; do
	feh --bg-fill ~/.cache/i3lock/current/wall.png
	echo "Sleeping for $SLEEP_MINUTES minute(s)"
	sleep "$SLEEP_SECONDS"
done
