#! /bin/sh

usage() {
	EXEC_PATH=$(dirname "$0")
	EXEC_NAME=$(basename "$0")
	echo "$EXEC_PATH/$EXEC_NAME -h: Shows Help Message"
	echo "$EXEC_PATH/$EXEC_NAME -p: Allow Package Install"
	echo "$EXEC_PATH/$EXEC_NAME -y: Auto Accept Dialogs"
	echo "$EXEC_PATH/$EXEC_NAME -x: Overrides Xorg check and enables desktop tools"
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

yay_fallback() {
	YAY=yay
	PACKAGES=$(sed "s/:aur//g" packages/arch.list | xargs)
	if ! command -v "$YAY" > /dev/null; then
		echo "Yay not detected, falling back to pacman."
		echo "AUR Packages will not be installed."
		echo "Go to https://github.com/Jguer/yay#installation for installation"
		YAY=sudo pacman
		PACKAGES=$(sed "s/.*:aur//g" packages/arch.list | xargs)
	fi
	$YAY -Syu --noconfirm
	echo "$PACKAGES" | xargs $YAY -S --noconfirm --needed
}

alias reload_i3="(command -v pgrep i3-msg && pgrep '^i3$' && i3-msg reload)"
check_systemd() {
	systemctl status $@ > /dev/null
}
check_systemd_user() {
	systemctl --user status $@ > /dev/null
}
export ALLOW_PACKAGE=false
export ALLOW_XORG=false
export AUTO_ACCEPT=false

while getopts ":hxpy" o; do
	case "${o}" in
		h) usage; exit;;
		p) export ALLOW_PACKAGE=true;;
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
	ZSH_PATH=$(command -v zsh || exit $?)
	_UID=$(id -u)
	_GID=$(id -g)
	DEFAULT_SHELL=$(awk -F: "/^$USER:.*:$_UID:$_GID/{print \$7}" /etc/passwd)

	if [ "$DEFAULT_SHELL" != "$ZSH_PATH" ]; then
		if prompt "Change Default Shell"; then
			echo "Password Required to change shell"
			chsh -s "$ZSH_PATH"
		fi
	fi
else
	echo "Cannot open /etc/passwd. Required to get default shell!"
	echo "User must change shell on their own"
fi

OS=$(. /etc/os-release; echo "$ID")
if $ALLOW_PACKAGE && prompt "Install Packages"; then
	if [ "$OS" = "arch" ]; then
		yay_fallback || exit $?
	elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
		echo "Debian Based Systems not supported yet."
	else
		echo "Unknown Distro."
	fi
fi

if $ALLOW_XORG || xset q &>/dev/null; then
	# Reload i3 config if running
	pgrep "i3$" >/dev/null && prompt "Reload i3" && reload_i3 > /dev/null
	
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

