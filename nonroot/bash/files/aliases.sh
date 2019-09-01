
if ${use_color}
then
	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
	alias egrep='egrep --colour=auto'
	alias fgrep='fgrep --colour=auto'
fi

alias autoremove="sudo pacman -Rcns \$(pacman -Qdtq)"
alias wifi="nmtui-connect"

function device_ip() {
	ip -o addr | awk '{if($3 == "inet") {gsub(/\/.*/,"");print $2 " " $4}}'
}