#! /bin/sh

DIR=$(pwd)
OS=$(grep "^ID" /etc/os-release | sed "s/ID=//")

NONROOT=$(ls nonroot)
ROOT=$(ls root)

question() {
	printf "%s (y/n)? " "$1"
	old_stty_cfg=$(stty -g)
	stty raw -echo ; answer=$(head -c 1) ; stty "$old_stty_cfg" # Careful playing with stty
	if echo "$answer" | grep -iq "^y" ;then
		printf "Yes\n"
		return 1
	else
		printf "No\n"
		return 0
	fi
}

for X in $NONROOT
do
	cd "${DIR}/nonroot/${X}" || exit
	sh install.sh
done

if echo "$1" | grep -iq "^n"
then
	printf "No Root Mode\n"
	exit
elif [ -z "$1" ] && question "Run Root Mode?"
then
	printf "No Root Mode\n"
	exit
elif echo "$1" | grep -iq "^y"  
then
	for X in $ROOT
	do
		cd "${DIR}/root/${X}" || exit
		sh install.sh
	done
else
	printf "An error has occured!\n"
	printf "Please run command with the flag \"y\" or \"n\"\n"
	printf "to enable or disable root mode.\n"
fi
