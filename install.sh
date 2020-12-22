#! /usr/bin/env bash

usage() {
	EXEC_PATH=$(dirname "$0")
	EXEC_NAME=$(basename "$0")
	echo "$EXEC_PATH/$EXEC_NAME -h: Shows Help Message"
	echo "$EXEC_PATH/$EXEC_NAME -l: bypass locale gen"
	echo "$EXEC_PATH/$EXEC_NAME -p: allow package install"
	echo "$EXEC_PATH/$EXEC_NAME -x: Overrides Xorg check and enables desktop tools"
	echo "$EXEC_PATH/$EXEC_NAME -y: Auto Accept Dialogs"
}

prompt() {
	$AUTO_ACCEPT && return 0
	if ! command -v whiptail > /dev/null; then
		printf "%s? [y/n] " "$1"
		read -r REPLY
		REPLY=$(echo "$REPLY" | tr '[:upper:]' '[:lower:]')
		[ "$REPLY" = "y" ] && return 0
		[ "$REPLY" = "n" ] && return 1
		echo "Bad Answer, Try Again!"
		prompt "$1" # Retry prompt if bad answer
	else
		whiptail --title "$1" --yesno "" 5 50
		return "$?"
	fi
}

check_systemd() {
	systemctl status "$@" > /dev/null
}
check_systemd_user() {
	systemctl --user status "$@" > /dev/null
}
check_is_linux() {
	[[ "$OSTYPE" == "linux-gnu"* ]]
	return $?
}
export DENY_LOCALE_GEN=false
export ALLOW_PACKAGE=false
export ALLOW_ROOT_MOD=false
export ALLOW_XORG=false
export AUTO_ACCEPT=false

while getopts ":hlprxy" o; do
	case "${o}" in
		h) usage; exit;;
		l) export DENY_LOCALE_GEN=true;;
		p) export ALLOW_PACKAGE=true;;
		r) export ALLOW_ROOT_MOD=true;;
		x) export ALLOW_XORG=true;;
		y) export AUTO_ACCEPT=true;;
		?) echo "Invalid Option: -$OPTARG"; usage; exit 2;;
	esac
done

grep -rl src -e "#\!.*sh" | xargs chmod +rwx
if prompt "Overwrite Config Files"; then
	cd src || exit $?
		cp --preserve=all -r . "$HOME/"
	cd - > /dev/null || exit $?
fi

if [ -r "/etc/passwd" ]; then
	SHELL_PATH="/bin/bash"
	_UID=$(id -u)
	_GID=$(id -g)
	DEFAULT_SHELL=$(awk -F: "/^$USER:.*:$_UID:$_GID/{print \$7}" /etc/passwd)

	if [ "$DEFAULT_SHELL" != "$SHELL_PATH" ]; then
		if prompt "Change Default Shell"; then
			echo "Password Required to change shell"
			chsh -s "$SHELL_PATH"
		fi
	fi
else
	echo "Cannot open /etc/passwd. Required to get default shell!"
	echo "User must change shell on their own"
fi

# shellcheck source=/dev/null
if check_is_linux && $ALLOW_PACKAGE && prompt "Install Packages"; then
	source <(cat /etc/*release)
	[ -z "$ID_LIKE" ] || ID="$ID_LIKE"
	case "$ID" in
	arch)
		sudo pacman -Syu || exit $?
		xargs -a "packages/arch.list" \
			sudo pacman -S --noconfirm --needed || exit $?
	;;
	debian)
		echo "Debian Package Support Not Yet Supported"
	;;
	*)
		echo "Unknown Distro: $ID"
	;;
	esac
else
	check_is_linux || echo "WARNING: Package installation only supported on GNU/Linux"
fi

if check_is_linux && ($ALLOW_XORG || (command -V xset && xset q) &>/dev/null); then
	# Reload i3 config if running
	if pgrep "i3$" > /dev/null && prompt "Reload i3"; then
		i3-msg reload > /dev/null
	fi
	
	if ! check_systemd_user pulseaudio && prompt "Enable Pulseaudio"
	then
		systemctl --user daemon-reload
		systemctl --user enable --now pulseaudio
	
		if ! check_systemd bluetooth > /dev/null && prompt "Enable Bluetooth"; then
			sudo systemctl daemon-reload
			sudo systemctl enable --now bluetooth
		fi
	fi
else
	echo "WARN: Xorg not running, assuming is a server enviorment. Override with \"-x\""
fi

if check_is_linux && $ALLOW_ROOT_MOD \
	&& prompt "ROOT: Patches For Backlight Support"; then
	groups | grep video > /dev/null || sudo usermod -aG video "$USER"
	UDEV_PATH="/etc/udev/rules.d/backlight.rules"
	UDEV_PATH_DEFAULT="/etc/udev/rules.d/81-backlight.rules"
	UDEV_TEMPLATE='ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="acpi_video0"'

	[ -e "$UDEV_PATH" ] || \
		echo "Reboot when complete to fix backlight controls"
	echo "$UDEV_TEMPLATE, GROUP=\"video\", MODE=\"0664\"" \
		| sudo tee "$UDEV_PATH"
	echo "$UDEV_TEMPLATE, ATTR{brightness}=\"8\"" \
		| sudo tee "$UDEV_PATH_DEFAULT"
fi

if check_is_linux && command -V locale > /dev/null; then
	# shellcheck source=/dev/null
	source <(locale)
	if [ "$LANG" != "en_US.UTF-8" ] && ! $DENY_LOCALE_GEN; then
		sudo sed -i "s/#en_US/en_US/;/#.*/d" /etc/locale.gen
		sudo locale-gen
		sudo localectl set-locale "LANG=en_US.UTF-8"
	fi
fi
