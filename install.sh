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
	sh install.sh
	cd "${DIR}"
done

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
		CHECK=$(pacman -Qs $X | grep "local" | grep "$X ")
		if [ -z "$CHECK" ]
		then
			sudo pacman \
				--needed \
				--noconfirm \
				-Syu \
				$X
		fi
	done
fi
