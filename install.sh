#! /bin/sh

DIR=$(pwd)
HOME="/home/$USER/"
FILES="${DIR}/files/"
OS=$(cat /etc/os-release | grep "^ID" | sed "s/ID=//")
DIRTOHIDE="${FILES}/launchfiles/"
TOHIDE=$(ls "${DIRTOHIDE}")

function install_i3lock() {
	sudo cp "${FILES}/lock.service" "/etc/systemd/system/lock@.service"
	sudo systemctl daemon-reload
	sudo systemctl enable "lock@$USER"
}

mkdir -p "${HOME}/.config/i3/"
mkdir -p "${HOME}/.config/gtk-3.0/"
mkdir -p "${HOME}/.local/share/applications/"

cp "${FILES}/bashrc" "${HOME}/.bashrc"
cp "${FILES}/i3config" "${HOME}/.config/i3/config"
cp "${FILES}/gtk-config" "${HOME}/.config/gtk-3.0/settings.ini"

for x in $TOHIDE
do
	cp "${DIRTOHIDE}/${x}" "${HOME}/.local/share/applications"
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
		pulseaudio-alsa

	install_i3lock
else
	echo "Cancel if i3lock is not installed"
	echo "If installed press any key to continue"
	read

	install_i3lock
fi

exit 0
