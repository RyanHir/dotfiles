#! /bin/sh

DIR=$(pwd)

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

runroot() {
	for X in $ROOT
	do
		cd "${DIR}/root/${X}" || exit
		sh install.sh
	done
	cd "${DIR}"
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
elif [ -z "$1" ]
then
	if ! question "Run Root Mode"
	then
		runroot
	else
		printf "No Root Mode\n"
		exit
	fi
elif echo "$1" | grep -iq "^y"  
then
	runroot
else
	printf "An error has occured!\n"
	printf "Please run command with the flag \"y\" or \"n\"\n"
	printf "to enable or disable root mode.\n"
fi
