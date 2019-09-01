#! /bin/sh

OS=$(grep "^ID" /etc/os-release | sed "s/ID=//")

if [ "$OS" = "arch" ]
then
	PACKAGES="\
		i3-gaps\
		i3lock\
		pulseaudio\
		pulseaudio-alsa\
		alsa-utils\
		feh\
		rofi\
		udiskie\
		xf86-video-intel\
		xorg-xinit\
		xorg-server"
	for X in $PACKAGES
	do
		CHECK=$(pacman -Qs "$X" | grep "^local.*$X")
		if [ -z "$CHECK" ]
		then
			sudo pacman \
				--needed \
				--noconfirm \
				-Syu \
				"$X"
		fi
	done
else
	printf "Not on Arch Linux!\n"
	exit
fi
