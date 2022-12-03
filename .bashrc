# Aliases.
alias ll='ls -alF'
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Startup.
if [[ $(grep microsoft /proc/version) ]]; then
    wsl-startup
fi

# History.
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend

# Terminal.
shopt -s checkwinsize

# Prompt.
eval "$(starship init bash)"
