# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
# if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
#   source /usr/share/zsh/manjaro-zsh-prompt
# fi

##### personal settings #####

[ -z "$PS1" ] && return
# (d) is default on

# ------------------------------
# General Settings
# ------------------------------
# export LANG=en_US.UTF-8  # 文字コードをUTF-8に設定
export KCODE=u           # KCODEにUTF-8を設定
export AUTOFEATURE=true  # autotestでfeatureを動かす
export LESS="-iMRj$(($(tput lines)/2))"

export MOZ_DBUS_REMOTE=1 # waylandでFirefoxなどをターミナルから開く際に必要

setopt auto_cd # 自動でcdする

stty stop undef # ctrl-sを使わない

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

setopt caseglob # case SENSITIVE glob

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

### History ###
HISTFILE=~/.zsh_history   # ヒストリを保存するファイル
HISTSIZE=10000            # メモリに保存されるヒストリの件数
SAVEHIST=10000            # 保存されるヒストリの件数
setopt bang_hist          # !を使ったヒストリ展開を行う(d)
setopt extended_history   # ヒストリに実行時間も保存する
setopt hist_ignore_all_dups   # 直前と同じコマンドはヒストリに追加しない
setopt share_history      # 他のシェルのヒストリをリアルタイムで共有する
setopt hist_reduce_blanks # 余分なスペースを削除してヒストリに保存する

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


# ------------------------------
# Other Settings
# ------------------------------

### Aliases ###
alias history='history -E'

cdls ()
{
  \cd "$@" && ls -F --color=auto
}

tn ()
{
    if [ $# -eq 1 ] ; then
        \tmux new -u -s "$1"
    else
        \tmux -u
    fi
}

alias c="cdls"
alias cd="cdls"
alias zc="z -c"
alias zi="z -I"
alias ls="ls -F --color=auto"
alias ll="ls -lFh --color=auto"
alias la="ls -a --color=auto"
alias lal="ls -laFh --color=auto"
alias lla="ls -laFh --color=auto"
alias v="nvim"
alias nv="~/ghq/github.com/Kethku/neovide/target/release/neovide --multigrid"
alias e="emacs"
alias duh="du -h -d1"
alias kill9="kill -9"

alias rn='ranger --choosedir=/tmp/rangerdir; LASTDIR=`cat /tmp/rangerdir`; cd "$LASTDIR"'

alias g="git"
alias gs="git branch -v;git status -s"
alias gf="git fetch"
alias gl='git l'
alias gld='git ld'

xdg_open2() {
    if uname -r | grep -q 'microsoft'; then
        if [ -z $* ]; then
            explorer.exe .
        else
            (\cd $*; explorer.exe .)
        fi
        return 0
    fi
    if [ -z $* ]; then
        xdg-open .
    else
        xdg-open $*
    fi
}
alias o="xdg_open2"

alias tm="tn"
alias ks="tmux kill-session -t"
alias kp="tmux kill-pane -t"
alias kw="tmux kill-window -t"
alias tls="tmux ls"
alias ta="tmux a -t"
# alias tac="tmux a -c \`pwd\` -t" # attach and set current directory the default directory for the session
alias pip_update_all='pip freeze --local | grep -v "^\-e" | cut -d = -f 1 | xargs pip install -U'
# alias pyv='source ~/3.7/bin/activate'
alias de='conda deactivate'
alias py='python3'
alias ipy='ipython'
alias jn='jupyter notebook'
# alias dcp='docker cp'
# alias dc='docker container'
# alias di='docker image'
# alias da='docker attach'
# alias d='docker'
alias drun='docker run -it --rm --gpus all --device /dev/nvidia0 --device /dev/nvidia-uvm --device /dev/nvidia-uvm-tools --device /dev/nvidiactl'
alias nf='neofetch'
alias nem='neomutt'
# alias wcache='wget --mirror --page-requisites --quiet --show-progress --no-parent --convert-links --execute robots=off'
alias jl='julia'
alias manj='LANG=ja_JP.UTF-8 man'

git_diff_wc(){
    args1=$1
    args2=$2
    [ -z $args1 ] && args1="1.day"
    [ -z $args2 ] && args2="HEAD"
    echo $args1 vs $args2
    git diff --word-diff-regex='.' `git log --before=$args1 -1 --format='%h'` $args2 \
    | sed -e 's/{+/\n{+/g' -e 's/+}/+}\n/g' -e 's/\[-/\n\[-/g' -e 's/-\]/-\]\n/g' \
    | rg '[\{\[][^\}\]]*[\}\]]' \
    | sed -e 's/{+//' -e 's/+}//' -e 's/\[-//' -e 's/-\]//' \
    | wc -m
}

# add necessary PATH
export PATH=~/.cargo/bin:${PATH}
export PATH=~/bin:${PATH}
export PATH=~/.local/share/gem/ruby/3.0.0/bin:${PATH}
export PATH=~/.neovim/bin:${PATH}
# export PATH=~/.pyenv/shims:${PATH}

if command -v nvim &> /dev/null
then
    export EDITOR=$(which nvim)
fi

# zplug
if command -v zplug &> /dev/null; then
    source /usr/share/zsh/scripts/zplug/init.zsh
    zplug "zsh-users/zsh-autosuggestions"
    zplug "zsh-users/zsh-syntax-highlighting", defer:2
    zplug load
fi

if [[ -f ~/.fzf.zsh ]]; then
    # fzf settings
    source ~/.fzf.zsh

    # use fzf to find repos in ghq
    fzf_pjc() {
        local project_name=$(ghq list | sort | fzf)
        if [ -n "${project_name}" ]; then
            local project_full_path=$(ghq root)/${project_name}
            # LBUFFER="cd ${project_full_path}"
            cd ${project_full_path}
            ls
            zle redisplay
        fi
    }
    zle -N fzf_pjc
    bindkey '^]' fzf_pjc
fi

if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

if $(command -v lua &> /dev/null) && [[ -f /usr/share/z.lua/z.lua ]]; then
    eval "$(lua /usr/share/z.lua/z.lua --init zsh enhanced once echo)"
fi
[ -f /opt/mambaforge/etc/profile.d/conda.sh ] && source /opt/mambaforge/etc/profile.d/conda.sh
