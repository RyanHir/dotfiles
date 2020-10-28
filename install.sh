#! /bin/bash

function usage {
	echo -e "./$(basename "$0") -h: Shows Help Message"
	echo -e "./$(basename "$0") -p: Do Install Packages"
	echo -e "./$(basename "$0") -y: Auto Accept Dialogs"
}

export INSTALLPKG=false

while getopts ":h:p" o; do
	case "${o}" in
		h) usage; exit;;
		p) export INSTALLPKG=true;;
		?) echo "Invalid Option: -$OPTARG"; usage; exit 2;;
	esac
done

{
	cd src || exit 3
	cp -r . "$HOME/"
}

PACKAGES=(zsh git fonts-noto)

if $INSTALLPKG
then
	SUDO=""
	if ! [ "$UID" = "0" ]
	then
		if ! command -v sudo 1> /dev/null
		then
			echo "Not ran as root"
			exit
		else
			SUDO=sudo
		fi
	fi
	if command -v apt-get 1> /dev/null
	then
		$SUDO apt-get update -y -qq
		$SUDO apt-get install -y -qq "${PACKAGES[@]}" || exit 4
	fi
fi

DEFAULT_SHELL=$(grep ^$(id -un): /etc/passwd | sed 's/.*://;s/.*\///')

if [ "$DEFAULT_SHELL" != "zsh" ]
then
	LOC=$(command -v zsh || exit 5)
	echo "Password Required to change shell"
	chsh -s "$LOC"
fi
