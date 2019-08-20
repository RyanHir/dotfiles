#! /bin/sh

DIR=$(pwd)
OS=$(cat /etc/os-release | grep "^ID" | sed "s/ID=//")

NONROOT=$(ls nonroot)
ROOT=$(ls root)

for X in $NONROOT
do
	cd "${DIR}/nonroot/${X}"
	sh install.sh
	cd "${DIR}"
done

for X in $ROOT
do
	cd "${DIR}/root/${X}"
	sudo sh install.sh $USER
	cd "${DIR}"
done

if [ "$OS" = "arch" ]
then
	# Get Packages
	sudo pacman \
		--needed \
		--noconfirm \
		--noprogressbar \
		--color=never \
		-Syu \
		i3-gaps \
		i3lock \
		pulseaudio \
		pulseaudio-alsa \
		feh \
		rofi \
		udiskie \
		xf86-video-intel
fi
