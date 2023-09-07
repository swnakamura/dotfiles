[ -z "$PS1" ] && return

### Options section
setopt correct            # Auto correct mistakes
setopt extendedglob       # Extended globbing. Allows using regular expressions with *
setopt nocaseglob         # Case insensitive globbing
setopt rcexpandparam      # Array expension with parameters
setopt nocheckjobs        # Don't warn about running processes when exiting
setopt numericglobsort    # Sort filenames numerically when it makes sense
setopt nobeep             # No beep
setopt appendhistory      # Immediately append history instead of overwriting
setopt histignorealldups  # If a new command is a duplicate, remove the older one
setopt autocd             # if only directory path is entered, cd there.
setopt inc_append_history # save commands are added to the history immediately, otherwise only when shell exits.
setopt histignorespace    # Don't save commands that start with space
setopt auto_pushd         # push past working directory list automatically
setopt prompt_subst       # eable substitution in prompt
setopt notify             # notify background job changes immediately
setopt equals             # expand `=command` as $(which command)

## history
setopt bang_hist            # !を使ったヒストリ展開を行う(d)
setopt extended_history     # ヒストリに実行時間も保存する
setopt hist_ignore_all_dups # 直前と同じコマンドはヒストリに追加しない
setopt share_history        # 他のシェルのヒストリをリアルタイムで共有する
setopt hist_reduce_blanks   # 余分なスペースを削除してヒストリに保存する
setopt hist_verify          # ヒストリを呼び出してから実行する間に一旦編集可能
setopt hist_no_store        # historyコマンドは履歴に登録しない
setopt hist_expand          # 補完時にヒストリを自動的に展開
setopt append_history       # ヒストリをすぐに追加

## completions
setopt auto_list     # 補完候補を一覧で表示する(d)
setopt auto_menu     # 補完キー連打で補完候補を順に表示する(d)
setopt list_packed   # 補完候補をできるだけ詰めて表示する
# setopt menu_complete # 一度のTabで補完だけでなく絞り込みまで始める
setopt list_types    # 補完候補にファイルの種類も表示する

zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' # Case insensitive tab completion
zstyle ':completion:*' rehash true                              # automatically find new executables in path 
zstyle ':completion:*' menu select                              # Highlight menu selection
## Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

## Add coreutils path for macOS
## This is added here to load dircolors
MACOS_COREUTILS_PATH="/opt/homebrew/opt/coreutils/libexec/gnubin"
if [[ -d $MACOS_COREUTILS_PATH ]]; then
    export PATH="$MACOS_COREUTILS_PATH:$PATH"
fi

export LSCOLORS=Exfxcxdxbxegedabagacad
eval "$(dircolors -b)"
export ZLS_COLORS=$LS_COLORS
export CLICOLOR=true
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
WORDCHARS=${WORDCHARS//\/[&.;]}                                 # Don't consider certain characters part of the word
zmodload zsh/complist # used for bindkey -M menuselect


### Keybindings section
bindkey -e
bindkey '^[[7~' beginning-of-line                               # Home key
bindkey '^[[H' beginning-of-line                                # Home key
if [[ "${terminfo[khome]}" != "" ]]; then
  bindkey "${terminfo[khome]}" beginning-of-line                # [Home] - Go to beginning of line
fi
bindkey '^[[8~' end-of-line                                     # End key
bindkey '^[[F' end-of-line                                     # End key
if [[ "${terminfo[kend]}" != "" ]]; then
  bindkey "${terminfo[kend]}" end-of-line                       # [End] - Go to end of line
fi
bindkey '^[[2~' overwrite-mode                                  # Insert key
bindkey '^[[3~' delete-char                                     # Delete key
bindkey '^[[C'  forward-char                                    # Right key
bindkey '^[[D'  backward-char                                   # Left key
bindkey '^[[5~' history-beginning-search-backward               # Page up key
bindkey '^[[6~' history-beginning-search-forward                # Page down key

bindkey -M menuselect '^g' .send-break                        # send-break2回分の効果
bindkey -M menuselect '^k' accept-and-infer-next-history      # 次の補完メニューを表示する
bindkey -M menuselect '^r' history-incremental-search-forward # 補完候補内インクリメンタルサーチ

## Navigate words with ctrl+arrow keys
bindkey '^[Oc' forward-word                                     #
bindkey '^[Od' backward-word                                    #
bindkey '^[[1;5D' backward-word                                 #
bindkey '^[[1;5C' forward-word                                  #
bindkey '^H' backward-kill-word                                 # delete previous word with ctrl+backspace
bindkey '^[[Z' undo                                             # Shift+tab undo last action

## <C-o> to edit current line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^O" edit-command-line

# ^G^S to view git status
bindkey "^G^S" git_status
git_status() {
    git branch -v
    git status -s
    eval $PROMPT
}
zle -N git_status

## fzf binding
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
            myls
            zle redisplay
        fi
    }
    zle -N fzf_pjc
    bindkey '^]' fzf_pjc
else
    echo "fzf not found"
fi

### Alias section
alias cp="cp -i"                                                # Confirm before overwriting something
alias df='df -h'                                                # Human-readable sizes
alias free='free -m'                                            # Show sizes in MB
alias gitu='git add . && git commit && git push'
alias history='history -E'

cdls ()
{
  \cd "$@" && myls
}

tn ()
{
    if [ $# -eq 1 ] ; then
        \tmux new -u -s "$1"
    else
        \tmux -u
    fi
}

myls ()
{
    if command -v lsd &> /dev/null; then
        lsd $*
    else
        ls $*
    fi
}

alias cd="cdls"
alias zc="z -c"
alias zi="z -I"
alias ls="myls"
alias ll="myls -l"
alias la="myls -a"
alias lal="myls -la"
alias lla="myls -la"
alias v="nvim"
alias e="emacs"
alias duh="du -h -d1"
alias kill9="kill -9"

alias rn='ranger --choosedir=/tmp/rangerdir; LASTDIR=`cat /tmp/rangerdir`; cd "$LASTDIR"'

alias g="git"
alias gf="git fetch"
alias gl='git l'
alias gld='git ld'

xdg_open2() {
    if uname -r | grep -q 'microsoft'; then
        # WSL
        if [ -z $* ]; then
            explorer.exe .
        else
            (\cd $*; explorer.exe .)
        fi
        return 0
    fi
    if uname | grep -q 'Darwin'; then
        # macOS
        if [[ -z $* ]]; then
            open .
        else
            open $*
        fi
        return 0
    fi
    # otherwise Linux
    if [ -z $* ]; then
        xdg-open .
    else
        xdg-open $*
    fi
}
alias o="xdg_open2"
alias imo='f(){convert $1 sixel:-;}; f'

alias tm="tn"
alias ks="tmux kill-session -t"
alias kp="tmux kill-pane -t"
alias kw="tmux kill-window -t"
alias tls="tmux ls"
alias ta="tmux a -t"
# alias tac="tmux a -c \`pwd\` -t" # attach and set current directory the default directory for the session
alias pip_update_all='pip freeze --local | grep -v "^\-e" | cut -d = -f 1 | xargs pip install -U'
alias de='conda deactivate'
alias py='python3'
alias ipy='ipython'
alias jn='jupyter notebook'
alias wget_cache_website='wget --mirror --page-requisites --quiet --show-progress --no-parent --convert-links --execute robots=off'
alias jl='julia'
alias manj='LANG=ja_JP.UTF-8 man'

# Theming section  
autoload -U compinit colors zcalc
compinit -d
colors

# Color man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-iMRj15

### Plugins section: Enable fish style features
# Use syntax highlighting
# source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Use history substring search
# source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
# bind UP and DOWN arrow keys to history substring search
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up			
bindkey '^[[B' history-substring-search-down

# Set terminal window and tab/icon title
#
# usage: title short_tab_title [long_window_title]
#
# See: http://www.faqs.org/docs/Linux-mini/Xterm-Title.html#ss3.1
# Fully supports screen and probably most modern xterm and rxvt
# (In screen, only short_tab_title is used)
function title {
  emulate -L zsh
  setopt prompt_subst

  [[ "$EMACS" == *term* ]] && return

  # if $2 is unset use $1 as default
  # if it is set and empty, leave it as is
  : ${2=$1}

  case "$TERM" in
    xterm*|putty*|rxvt*|konsole*|ansi|mlterm*|alacritty|kitty|wezterm|st*)
      print -Pn "\e]2;${2:q}\a" # set window name
      print -Pn "\e]1;${1:q}\a" # set tab name
      ;;
    screen*|tmux*)
      print -Pn "\ek${1:q}\e\\" # set screen hardstatus
      ;;
    *)
    # Try to use terminfo to set the title
    # If the feature is available set title
    if [[ -n "$terminfo[fsl]" ]] && [[ -n "$terminfo[tsl]" ]]; then
      echoti tsl
      print -Pn "$1"
      echoti fsl
    fi
      ;;
  esac
}

ZSH_THEME_TERM_TAB_TITLE_IDLE="%15<..<%~%<<" #15 char left truncated PWD
ZSH_THEME_TERM_TITLE_IDLE="%n@%m:%~"

# Runs before showing the prompt
function mzc_termsupport_precmd {
  [[ "${DISABLE_AUTO_TITLE:-}" == true ]] && return
  title $ZSH_THEME_TERM_TAB_TITLE_IDLE $ZSH_THEME_TERM_TITLE_IDLE
}

# Runs before executing the command
function mzc_termsupport_preexec {
  [[ "${DISABLE_AUTO_TITLE:-}" == true ]] && return

  emulate -L zsh

  # split command into array of arguments
  local -a cmdargs
  cmdargs=("${(z)2}")
  # if running fg, extract the command from the job description
  if [[ "${cmdargs[1]}" = fg ]]; then
    # get the job id from the first argument passed to the fg command
    local job_id jobspec="${cmdargs[2]#%}"
    # logic based on jobs arguments:
    # http://zsh.sourceforge.net/Doc/Release/Jobs-_0026-Signals.html#Jobs
    # https://www.zsh.org/mla/users/2007/msg00704.html
    case "$jobspec" in
      <->) # %number argument:
        # use the same <number> passed as an argument
        job_id=${jobspec} ;;
      ""|%|+) # empty, %% or %+ argument:
        # use the current job, which appears with a + in $jobstates:
        # suspended:+:5071=suspended (tty output)
        job_id=${(k)jobstates[(r)*:+:*]} ;;
      -) # %- argument:
        # use the previous job, which appears with a - in $jobstates:
        # suspended:-:6493=suspended (signal)
        job_id=${(k)jobstates[(r)*:-:*]} ;;
      [?]*) # %?string argument:
        # use $jobtexts to match for a job whose command *contains* <string>
        job_id=${(k)jobtexts[(r)*${(Q)jobspec}*]} ;;
      *) # %string argument:
        # use $jobtexts to match for a job whose command *starts with* <string>
        job_id=${(k)jobtexts[(r)${(Q)jobspec}*]} ;;
    esac

    # override preexec function arguments with job command
    if [[ -n "${jobtexts[$job_id]}" ]]; then
      1="${jobtexts[$job_id]}"
      2="${jobtexts[$job_id]}"
    fi
  fi

  # cmd name only, or if this is sudo or ssh, the next cmd
  local CMD=${1[(wr)^(*=*|sudo|ssh|mosh|rake|-*)]:gs/%/%%}
  local LINE="${2:gs/%/%%}"

  title '$CMD' '%100>...>$LINE%<<'
}

autoload -U add-zsh-hook
add-zsh-hook precmd mzc_termsupport_precmd
add-zsh-hook preexec mzc_termsupport_preexec

# Required for $langinfo
zmodload zsh/langinfo

# URL-encode a string
#
# Encodes a string using RFC 2396 URL-encoding (%-escaped).
# See: https://www.ietf.org/rfc/rfc2396.txt
#
# By default, reserved characters and unreserved "mark" characters are
# not escaped by this function. This allows the common usage of passing
# an entire URL in, and encoding just special characters in it, with
# the expectation that reserved and mark characters are used appropriately.
# The -r and -m options turn on escaping of the reserved and mark characters,
# respectively, which allows arbitrary strings to be fully escaped for
# embedding inside URLs, where reserved characters might be misinterpreted.
#
# Prints the encoded string on stdout.
# Returns nonzero if encoding failed.
#
# Usage:
#  zsh_urlencode [-r] [-m] [-P] <string> [<string> ...]
#
#    -r causes reserved characters (;/?:@&=+$,) to be escaped
#
#    -m causes "mark" characters (_.!~*''()-) to be escaped
#
#    -P causes spaces to be encoded as '%20' instead of '+'
function zsh_urlencode() {
  emulate -L zsh
  local -a opts
  zparseopts -D -E -a opts r m P

  local in_str="$@"
  local url_str=""
  local spaces_as_plus
  if [[ -z $opts[(r)-P] ]]; then spaces_as_plus=1; fi
  local str="$in_str"

  # URLs must use UTF-8 encoding; convert str to UTF-8 if required
  local encoding=$langinfo[CODESET]
  local safe_encodings
  safe_encodings=(UTF-8 utf8 US-ASCII)
  if [[ -z ${safe_encodings[(r)$encoding]} ]]; then
    str=$(echo -E "$str" | iconv -f $encoding -t UTF-8)
    if [[ $? != 0 ]]; then
      echo "Error converting string from $encoding to UTF-8" >&2
      return 1
    fi
  fi

  # Use LC_CTYPE=C to process text byte-by-byte
  local i byte ord LC_ALL=C
  export LC_ALL
  local reserved=';/?:@&=+$,'
  local mark='_.!~*''()-'
  local dont_escape="[A-Za-z0-9"
  if [[ -z $opts[(r)-r] ]]; then
    dont_escape+=$reserved
  fi
  # $mark must be last because of the "-"
  if [[ -z $opts[(r)-m] ]]; then
    dont_escape+=$mark
  fi
  dont_escape+="]"

  # Implemented to use a single printf call and avoid subshells in the loop,
  # for performance
  local url_str=""
  for (( i = 1; i <= ${#str}; ++i )); do
    byte="$str[i]"
    if [[ "$byte" =~ "$dont_escape" ]]; then
      url_str+="$byte"
    else
      if [[ "$byte" == " " && -n $spaces_as_plus ]]; then
        url_str+="+"
      else
        ord=$(( [##16] #byte ))
        url_str+="%$ord"
      fi
    fi
  done
  echo -E "$url_str"
}

# Emits the control sequence to notify many terminal emulators
# of the cwd
#
# Identifies the directory using a file: URI scheme, including
# the host name to disambiguate local vs. remote paths.
function mzc_termsupport_cwd {
  # Percent-encode the host and path names.
  local URL_HOST URL_PATH
  URL_HOST="$(zsh_urlencode -P $HOST)" || return 1
  URL_PATH="$(zsh_urlencode -P $PWD)" || return 1

  # common control sequence (OSC 7) to set current host and path
  printf "\e]7;%s\a" "file://${URL_HOST}${URL_PATH}"
}

# Use a precmd hook instead of a chpwd hook to avoid contaminating output
# i.e. when a script or function changes directory without `cd -q`, chpwd
# will be called the output may be swallowed by the script or function.
add-zsh-hook precmd mzc_termsupport_cwd

# File and Dir colors for ls and other outputs

### misc section
stty stop undef # Do not use ctrl-s

export MOZ_DBUS_REMOTE=1 # waylandでFirefoxなどをターミナルから開く際に必要


# ------------------------------
# OSC 133
# ------------------------------
_prompt_executing=""
function __prompt_precmd() {
    local ret="$?"
    if test "$_prompt_executing" != "0"
    then
      _PROMPT_SAVE_PS1="$PS1"
      _PROMPT_SAVE_PS2="$PS2"
      PS1=$'%{\e]133;P;k=i\a%}'$PS1$'%{\e]133;B\a\e]122;> \a%}'
      PS2=$'%{\e]133;P;k=s\a%}'$PS2$'%{\e]133;B\a%}'
    fi
    if test "$_prompt_executing" != ""
    then
       printf "\033]133;D;%s;aid=%s\007" "$ret" "$$"
    fi
    printf "\033]133;A;cl=m;aid=%s\007" "$$"
    _prompt_executing=0
}
function __prompt_preexec() {
    PS1="$_PROMPT_SAVE_PS1"
    PS2="$_PROMPT_SAVE_PS2"
    printf "\033]133;C;\007"
    _prompt_executing=1
}
preexec_functions+=(__prompt_preexec)
precmd_functions+=(__prompt_precmd)

# ------------------------------
# Other Settings
# ------------------------------

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
else
    echo "nvim not found"
fi

# zplug
if [ -f /usr/share/zsh/scripts/zplug/init.zsh ]; then
    ZPLUG_INIT=/usr/share/zsh/scripts/zplug/init.zsh
elif [ -f /opt/homebrew/opt/zplug/init.zsh ]; then
    ZPLUG_INIT=/opt/homebrew/opt/zplug/init.zsh
fi
if [ -n $ZPLUG_INIT ]; then
    source $ZPLUG_INIT
    zplug "zsh-users/zsh-autosuggestions"
    zplug "zsh-users/zsh-syntax-highlighting", defer:2
    zplug load
else
    echo "zplug not loaded"
fi

if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
else
    PROMPT_TIME='%F{3}%D{%m-%d %H:%M:%S}%f'
    PROMPT_USER_NAME='%F{2}%n%f'
    PROMPT_CWD='%F{6}%~%f'
    PROMPT='%B$PROMPT_TIME%b %B$PROMPT_USER_NAME%b in %B${PROMPT_CWD}%b -> '
fi

if $(command -v lua &> /dev/null) && [[ -f /usr/share/z.lua/z.lua ]]; then
    eval "$(lua /usr/share/z.lua/z.lua --init zsh enhanced once echo)"
elif $(command -v brew &> /dev/null); then
    eval "$(lua $(brew --prefix z.lua)/share/z.lua/z.lua --init zsh)"
else
    echo "z.lua not loaded"
fi

## fzf+z.lua binding
if which fzf > /dev/null && which _zlua > /dev/null; then
    # use fzf to find repos in ghq
    zlua_fzf() {
        local dir_name=$(z | tac | fzf +s)
        local dir_name=${dir_name##* }
        if [ -n "${dir_name}" ]; then
            \cd ${dir_name}
            ls
            zle redisplay
        fi
    }
    zle -N zlua_fzf
    bindkey "^K" zlua_fzf
else
    echo "zlua_fzf" not loaded
fi

