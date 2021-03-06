#! /usr/bin/env bash

NEWT_COLORS_FILE="$(dirname "$0")/src/.config/whiptail.env"
export NEWT_COLORS_FILE

usage() {
	cat << EOF
Usage:
    ./$(basename "$0") [ARGS]
Args:
    -h	Shows This Help Message
    -l	Bypass Locale Generation
    -t	Do not affect xorg/gtk settings
    -p	Enable Package Installation, Extention of -y
    -x	Overrides XOrg Check and enabled extra services
    -y	Auto Accept Dialogs
EOF
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

quiet_run_as() {
    (command -v "$1" > /dev/null) || return
    "$@" || return
}
export -f quiet_run_as

_pgrep() {
    DATA=$(ps -A | awk '$4~/'"$1"'/{print $1}')
    test -n "$DATA" || return
}
export DENY_LOCALE_GEN=false
export DENY_XORG_CONFIG=false
export ALLOW_PACKAGE=false
export ALLOW_ROOT_MOD=false
export ALLOW_XORG=false
export AUTO_ACCEPT=false

while getopts ":hltprxy" o; do
    case "${o}" in
	h) usage; exit;;
	l) export DENY_LOCALE_GEN=true;;
	t) export DENY_XORG_CONFIG=true;;
	p) export ALLOW_PACKAGE=true;;
	r) export ALLOW_ROOT_MOD=true;;
	x) export ALLOW_XORG=true;;
	y) export AUTO_ACCEPT=true;;
	?) echo "Invalid Option: -$OPTARG"; usage; exit 2;;
    esac
done

grep -rl src -e "#\!.*sh" | xargs chmod +rwx
if prompt "Overwrite Config Files"; then
    if $DENY_XORG_CONFIG; then
    (
	cd src || exit $?
	FILES=$(find . -type f -o -type l | grep -v ".x\|gtk")
	for FILE in $FILES; do
	    mkdir -p "$(dirname "$FILE")" 
	    cp "$FILE" "$HOME/$(dirname "$FILE")"
	done
    )
    else
    (
	cd src || exit $?
	cp --preserve=all -r . "$HOME/"
    )
    fi	
fi

if [ -r "/etc/passwd" ]; then
    SHELL_="$(command -v zsh)"
    DEFAULT_SHELL=$(grep "^$USER:" /etc/passwd | cut -d: -f7)

    if [ -n "$SHELL_" ] && [ "$DEFAULT_SHELL" != "$SHELL_" ]; then
	if prompt "Change Default Shell"; then
	    echo "Password Required to change shell"
	    chsh -s "$SHELL_"
	fi
    fi
else
    echo "Cannot open /etc/passwd. Required to get default shell!"
    echo "User must change shell on their own"
fi

# shellcheck source=/dev/null
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
if $ALLOW_PACKAGE && prompt "Install Packages"; then
    source <(cat /etc/*release)
    [ -n "$ID_LIKE" ] && ID="$ID_LIKE"
    case "$(echo "$ID" | tr '[:upper:]' '[:lower:]')" in
	arch)
	    sudo pacman -Syu || exit
	    # Install
	    sed "/^!/d" packages/arch.list | xargs \
		sudo pacman -S --noconfirm --needed
	    # Uninstall, fail sucessfully
	    sed "/^!/!d;s/!//g" packages/arch.list | xargs \
		sudo pacman -Rsc --noconfirm || true
	;;
	debian) echo "Debian Package Support Not Yet Supported";;
	*) echo "Unknown Distro: $ID";;
    esac
fi

XORG_OVERRIDE=false
XORG_RUNNING=false
($ALLOW_XORG && ! $DENY_XORG_CONFIG) && XORG_OVERRIDE=true
(quiet_run_as xset q > /dev/null) && XORG_RUNNING=true

if $XORG_OVERRIDE || $XORG_RUNNING; then
    GDM_MSG="Enable GDM Logim Manager"
    PA_MSG="Enable Pulseaudio"

    PA_SYSCTL=false
    GDM_SYSCTL=false
    (! systemctl --user is-active --quiet pulseaudio && prompt "$PA_MSG") \
	&& PA_SYSCTL=true
    (! systemctl is-active --quiet gdm && prompt "$GDM_MSG") \
	&& GDM_SYSCTL=true

    $PA_SYSCTL && systemctl --user daemon-reload
    $PA_SYSCTL && systemctl --user enable --now pulseaudio

    $GDM_SYSCTL && systemctl daemon-reload
    $GDM_SYSCTL && systemctl enable --now gdm
else
    echo "WARN: Xorg not running, assuming is a server enviorment. Override with \"-x\""
fi

if $ALLOW_ROOT_MOD && prompt "ROOT: Patches For Backlight Support"; then
    groups | grep video > /dev/null || sudo usermod -aG video "$USER"
    UDEV_PATH="/etc/udev/rules.d/backlight.rules"
    UDEV_PATH_DEFAULT="/etc/udev/rules.d/81-backlight.rules"
    UDEV_TEMPLATE='ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="acpi_video0"'

    [ -e "$UDEV_PATH" ] \
	|| echo "Reboot when complete to fix backlight controls"
    echo "$UDEV_TEMPLATE, GROUP=\"video\", MODE=\"0664\"" \
	| sudo tee "$UDEV_PATH"
    echo "$UDEV_TEMPLATE, ATTR{brightness}=\"8\"" \
	| sudo tee "$UDEV_PATH_DEFAULT"
fi

# shellcheck source=/dev/null disable=SC2091
source <(quiet_run_as locale)
LANG_NEED_UPDATE=false
[ -n "$LANG" ] && [ "$LANG" != "en_US.UTF-8" ] && LANG_NEED_UPDATE=true

if $LANG_NEED_UPDATE && ! $DENY_LOCALE_GEN; then
    sudo sed -i "s/#en_US/en_US/;/#.*/d" /etc/locale.gen
    sudo locale-gen
    sudo localectl set-locale "LANG=en_US.UTF-8"
fi

sh ./gsettings.sh

fi # end linux specific
