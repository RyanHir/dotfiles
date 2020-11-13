#! /bin/sh

set -e

. ~/.config/env

SLEEP_MINUTES="$1"
SLEEP_SECONDS=$((SLEEP_MINUTES * 60))
while true; do
	set-wallpaper
	echo "Sleeping for $SLEEP_MINUTES minute(s)"
	sleep "$SLEEP_SECONDS"
done
