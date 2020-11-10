#! /bin/sh

usage() {
	EXEC_PATH=$(dirname "$0")
	EXEC_NAME=$(basename "$0")
	echo "$EXEC_PATH/$EXEC_NAME -h: Shows Help Message"
	echo "$EXEC_PATH/$EXEC_NAME -y: Auto Accept Dialogs"
}

prompt() {
	$AUTO_ACCEPT && return 0
	printf "$1? [y/n] "
	read -r REPLY
	REPLY=$(echo "$REPLY" | tr '[:upper:]' '[:lower:]')
	[ "$REPLY" = "y" ] && return 0
	[ "$REPLY" = "n" ] && return 1
	echo "Bad Answer, Try Again!"
	prompt "$1" # Retry prompt if bad answer
}

alias reload_i3="(command -v pgrep i3-msg && pgrep '^i3$' && i3-msg reload)"

export AUTO_ACCEPT=false

while getopts ":hy" o; do
	case "${o}" in
		h) usage; exit;;
		y) export AUTO_ACCEPT=true;;
		?) echo "Invalid Option: -$OPTARG"; usage; exit 2;;
	esac
done

find src -type f -exec awk '/^#!.*sh$/{system("chmod +rwx " FILENAME)}' {} \;
if prompt "Overwrite Config Files"; then
	cd src || exit $?
		cp --preserve=all -r . "$HOME/"
	cd - > /dev/null || exit $?
fi

if [ -r "/etc/passwd" ]; then
	ZSH_PATH=$(command -v zsh || exit $?)
	DEFAULT_SHELL=$(awk -F: "/^$USER:.*:$UID:$GID/{print \$7}" /etc/passwd)

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

# Reload i3 config if running
reload_i3 > /dev/null

systemctl --user daemon-reload
systemctl --user enable --now pulseaudio
