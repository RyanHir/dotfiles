#! /bin/sh

DIR=$(pwd)
OS=$(grep "^ID" /etc/os-release | sed "s/ID=//")

NONROOT=$(ls nonroot)
ROOT=$(ls root)

for X in $NONROOT
do
	cd "${DIR}/nonroot/${X}" || exit
	sh install.sh
done
#cd "$DIR" || exit

if [ "$1" = "YES" ]
then
	for X in $ROOT
	do
		cd "${DIR}/root/${X}" || exit
		sh install.sh
		#cd "${DIR}" || exit
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
			CHECK=$(pacman -Qs "$X" | grep "^local" | grep "$X ")
			if [ -z "$CHECK" ]
			then
				sudo pacman \
					--needed \
					--noconfirm \
					-Syu \
					"$X"
			fi
		done
	fi
elif [ "$1" = "NO" ]
then
	echo "Opted out from root mode"
else
	echo "Root Oution not provided, skipping"
fi
