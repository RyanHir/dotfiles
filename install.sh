#! /bin/bash

function usage {
	EXEC_PATH=$(dirname "$0")
	EXEC_NAME=$(basename "$0")
	echo -e "$EXEC_PATH/$EXEC_NAME -h: Shows Help Message"
}

while getopts ":h:py" o; do
	case "${o}" in
		h) usage; exit;;
		?) echo "Invalid Option: -$OPTARG"; usage; exit 2;;
	esac
done

cd src || exit $?
	cp -r . "$HOME/"
cd - > /dev/null || exit $?

if [ -r "/etc/passwd" ]
then
	ZSH_PATH=$(command -v zsh || exit $?)
	DEFAULT_SHELL=$(awk -F: "/^$USER/{print \$7}" /etc/passwd)

	if [ "$DEFAULT_SHELL" != "$ZSH_PATH" ]
	then
		echo "Password Required to change shell"
		chsh -s "$ZSH_PATH"
	fi
else
	echo "Cannot open /etc/passwd. Required to get default shell!"
	echo "User must change shell on their own"
fi

# Reload i3 config if running
if pgrep "^i3$" > /dev/null
then
	if ! i3-msg reload > /dev/null
	then
		echo "Error Reloading i3wm"
	fi
fi
