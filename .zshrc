[ -z "$PS1" ] && return
# (d) is default on

# ------------------------------
# General Settings
# ------------------------------
export LANG=en_US.UTF-8  # 文字コードをUTF-8に設定
export KCODE=u           # KCODEにUTF-8を設定
export AUTOFEATURE=true  # autotestでfeatureを動かす
export LESS="-iMR"

setopt auto_cd # 自動でcdする

# ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
setopt hist_ignore_all_dups
# ヒストリを呼び出してから実行する間に一旦編集可能
setopt hist_verify
# 余分な空白は詰めて記録
setopt hist_reduce_blanks 
# historyコマンドは履歴に登録しない
setopt hist_no_store
# 補完時にヒストリを自動的に展開
setopt hist_expand


setopt auto_pushd        # cd時にディレクトリスタックにpushdする
setopt correct           # コマンドのスペルを訂正する
setopt prompt_subst      # プロンプト定義内で変数置換やコマンド置換を扱う
setopt notify            # バックグラウンドジョブの状態変化を即時報告する
setopt equals            # =commandを`which command`と同じ処理にする

### Complement ###
autoload -U compinit; compinit -u # 補完機能を有効にする
setopt auto_list               # 補完候補を一覧で表示する(d)
setopt auto_menu               # 補完キー連打で補完候補を順に表示する(d)
setopt list_packed             # 補完候補をできるだけ詰めて表示する
setopt list_types              # 補完候補にファイルの種類も表示する
bindkey "^[[Z" reverse-menu-complete  # Shift-Tabで補完候補を逆順する("\e[Z"でも動作する)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # 補完時に大文字小文字を区別しない

### VirtualEnvWrapper ###
if [ -f /Library/Frameworks/Python.framework/Versions/3.6/bin/virtualenvwrapper.sh ]; then
   #export VIRTUALENVWRAPPER_PYTHON=/Library/Frameworks/Python.framework/Versions/3.6/bin/python3
   #export WORKON_HOME=$HOME/.virtualenvs
   #source /Library/Frameworks/Python.framework/Versions/3.6/bin/virtualenvwrapper.sh

fi

### History ###
HISTFILE=~/.zsh_history   # ヒストリを保存するファイル
HISTSIZE=10000            # メモリに保存されるヒストリの件数
SAVEHIST=10000            # 保存されるヒストリの件数
setopt bang_hist          # !を使ったヒストリ展開を行う(d)
setopt extended_history   # ヒストリに実行時間も保存する
setopt hist_ignore_dups   # 直前と同じコマンドはヒストリに追加しない
setopt share_history      # 他のシェルのヒストリをリアルタイムで共有する
setopt hist_reduce_blanks # 余分なスペースを削除してヒストリに保存する

# マッチしたコマンドのヒストリを表示できるようにする
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# すべてのヒストリを表示する
function history-all { history -E 1 }

# ------------------------------
# Look And Feel Settings
# ------------------------------
### Ls Color ###
# 色の設定
export LSCOLORS=Exfxcxdxbxegedabagacad
# 補完時の色の設定
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
# ZLS_COLORSとは？
export ZLS_COLORS=$LS_COLORS
# lsコマンド時、自動で色がつく(ls -Gのようなもの？)
export CLICOLOR=true
# 補完候補に色を付ける
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

#Title
#時刻を表示させる
precmd() {
   #[[ -t 1 ]] || return
   #case $TERM in
       #*xterm*|rxvt|(dt|k|E)term)
       #print -Pn "\e]2;[%~]\a"    
 #;;
       ## screen)
       ##      #print -Pn "\e]0;[%n@%m %~] [%l]\a"
       ##      print -Pn "\e]0;[%n@%m %~]\a"
       ##      ;;
   #esac
}


# ------------------------------
# Other Settings
# ------------------------------

### Aliases ###
alias history='history -E'

banditssh()
{
  ssh bandit"$@"@bandit.labs.overthewire.org -p 2220
}

cdls ()
{
  \cd "$@" && ls
}

fetchlatexpdf ()
{
  ~/.zsh_functions/fetchlatexpdf.sh $@
}

latexmkandfetchpdf ()
{
  ~/.zsh_functions/latexmk.sh $@
}

tn ()
{
    if [ $# -eq 1 ] ; then
        \tmux new -s "$1"
    else
        \tmux
    fi
}

alias cd="cdls"
alias ls="ls -F"
alias ll="ls -lFh"
alias la="ls -a"
alias lal="ls -laFh"
alias lla="ls -laFh"
alias vim="nvim"
alias vi="nvim"
alias v="nvim"
alias e="emacs"
alias duh="du -h -d1"
alias gp="g++ -std=c++11 -Wall"
alias gc="gcc -Wall -std=c17"
alias cleantextmp="rm -rf ~/.tmp/tex"

alias tm="tn"
alias ks="tmux kill-session -t"
alias kp="tmux kill-pane -t"
alias kw="tmux kill-window -t"
alias tls="tmux ls"
alias ta="tmux a -t"
alias pip_update_all='pip freeze --local | grep -v "^\-e" | cut -d = -f 1 | xargs pip install -U'
alias pyv='source ~/3.7/bin/activate'
alias de='deactivate'
alias py='python3'
alias ipy='ipython'
alias jn='jupyter notebook'
alias g='git'
alias dcp='docker cp'
alias dc='docker container'
alias di='docker image'
alias da='docker attach'
alias d='docker'
alias latexmk='latexmkandfetchpdf'
alias pytags='ctags -R --python-kinds=+cfmvi'
alias nf='neofetch'

# add necessary PATH
export PATH="/miniconda3/bin:$PATH"
export PATH="/usr/local/texlive/2018/bin/x86_64-darwin:$PATH"
export PATH="/usr/local/Homebrew/bin:$PATH"
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/opt/llvm/bin:$PATH
export PATH=/usr/local/opt/openssl/bin:$PATH
export PATH=~/my_dev_apps/nvim-osx64/bin:$PATH

# add GOPATH
export GOPATH=$HOME/go
export PATH=$PATH:$(go env GOPATH)/bin

# Set Spaceship ZSH as a prompt
autoload -U promptinit; promptinit
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_TIME_SHOW=true
SPACESHIP_USER_SHOW=false
SPACESHIP_CHAR_SYMBOL="$ "
prompt spaceship

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
# Override auto-title when static titles are desired ($ title My new title)
title() { export TITLE_OVERRIDDEN=1; echo -en "\e]0;$*\a"}
# Turn off static titles ($ autotitle)
autotitle() { export TITLE_OVERRIDDEN=0 }; autotitle
# Condition checking if title is overridden
overridden() { [[ $TITLE_OVERRIDDEN == 1 ]]; }
# Echo asterisk if git state is dirty
gitDirty() { [[ $(git status 2> /dev/null | grep -o '\w\+' | tail -n1) != ("clean"|"") ]] && echo "*" }

# Show cwd when shell prompts for input.
precmd() {
   if overridden; then return; fi
   cwd=${$(pwd)##*/} # Extract current working dir only
   print -Pn "\e]0;$cwd$(gitDirty)\a" # Replace with $pwd to show full path
}

# Prepend command (w/o arguments) to cwd while waiting for command to complete.
preexec() {
   if overridden; then return; fi
   printf "\033]0;%s\a" "${1%% *} | $cwd$(gitDirty)" # Omit construct from $1 to show args
}

# fzf configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
