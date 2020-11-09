#! /bin/sh

usage() {
	EXEC_PATH=$(dirname "$0")
	EXEC_NAME=$(basename "$0")
	echo "$EXEC_PATH/$EXEC_NAME -h: Shows Help Message"
	echo "$EXEC_PATH/$EXEC_NAME -y: Auto Accept Dialogs"
}

change_shell_prompt() {
	printf "Change Default Shell? [y/n] "
	read -r REPLY
	REPLY=$(echo "$REPLY" | tr '[:upper:]' '[:lower:]')
	[ "$REPLY" = "y" ] && return 0
	[ "$REPLY" = "n" ] && return 1
	echo "Bad Answer, Try Again!"
	change_shell_prompt # Retry prompt if bad answer
}

export AUTO_ACCEPT=false

while getopts ":hy" o; do
	case "${o}" in
		h) usage; exit;;
		y) export AUTO_ACCEPT=true;;
		?) echo "Invalid Option: -$OPTARG"; usage; exit 2;;
	esac
done

EXECS=$(find src -type f -exec awk '/^#!.*sh$/{print FILENAME}' {} \;)
for file in $EXECS
do
	chmod +x "$file" || exit $?
done
cd src || exit $?
	cp --preserve=all -r . "$HOME/"
cd - > /dev/null || exit $?

if [ -r "/etc/passwd" ]
then
	ZSH_PATH=$(command -v zsh || exit $?)
	DEFAULT_SHELL=$(awk -F: "/^$USER:.*:$UID:$GID/{print \$7}" /etc/passwd)

	if [ "$DEFAULT_SHELL" != "$ZSH_PATH" ]
	then
		if $AUTO_ACCEPT || change_shell_prompt
		then
			echo "Password Required to change shell"
			chsh -s "$ZSH_PATH"
		fi
	fi
else
	echo "Cannot open /etc/passwd. Required to get default shell!"
	echo "User must change shell on their own"
fi

# Reload i3 config if running
if ! (pgrep "^i3$" && i3-msg reload) > /dev/null
then
	echo "Error Reloading i3wm"
fi
