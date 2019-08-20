
if ${use_color}
then
	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
	alias egrep='egrep --colour=auto'
	alias fgrep='fgrep --colour=auto'
fi

alias autoremove="sudo pacman -Rcns \$(pacman -Qdtq)"
