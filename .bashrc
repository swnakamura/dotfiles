alias tls="tmux ls"
alias ta="tmux a -t"

cdls ()
{
  \cd "$@" && ls -F --color=auto
}

alias c="cdls"
alias cd="cdls"
alias ls="ls -F --color=auto"
alias ll="ls -lFh --color=auto"
alias la="ls -a --color=auto"
alias lal="ls -laFh --color=auto"
alias lla="ls -laFh --color=auto"

alias g="git"
alias gs="git branch -v;git status -s"
alias gf="git fetch"
alias gl='git l'
alias gld='git ld'
