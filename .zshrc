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
setopt interactivecomments # Allow comments in interactive shell

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
zstyle ':completion:*' cache-path $HOME/.zsh/cache

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

HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
WORDCHARS=${WORDCHARS//\/[&.;]}                                 # Don't consider certain characters part of the word
zmodload zsh/complist # used for bindkey -M menuselect

# Export locale
export LC_CTYPE=en_US.UTF-8

### Keybindings section
bindkey -v                                                 # Use vi keybindings

# Easy cursor movement in insert mode inspired by emacs
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^B' backward-char
bindkey '^F' forward-char
bindkey '^P' up-line-or-history
bindkey '^N' down-line-or-history
bindkey '^U' backward-kill-line


bindkey -M menuselect '^g' .send-break                        # send-break2回分の効果
bindkey -M menuselect '^k' accept-and-infer-next-history      # 次の補完メニューを表示する
bindkey -M menuselect '^r' history-incremental-search-forward # 補完候補内インクリメンタルサーチ

## Navigate words with ctrl+arrow keys
bindkey '^[Oc' forward-word                                     #
bindkey '^[Od' backward-word                                    #
# bindkey '^[[1;5D' backward-word                                 #
# bindkey '^[[1;5C' forward-word                                  #
# bindkey '^H' backward-kill-word                                 # delete previous word with ctrl+backspace
bindkey '^[[Z' undo                                             # Shift+tab undo last action

## <C-o> to edit current line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^O" edit-command-line

# ^G^S to view git status
bindkey "^G^S" git_status
git_status() {
    echo ""
    echo "\e[1;4;32mgit branches\e[m:"
    git branch -vv
    echo ""
    echo "\e[1;4;32mgit status\e[m:"
    git status -s
    echo ""
    echo ""
    # show prompt again
    zle reset-prompt
}
zle -N git_status

# ^G^D to view git diff
git_diff() {
    echo ""
    echo "\e[1;4;32mgit diff\e[m:"
    git diff
    echo ""
    echo ""
    # show prompt again
    zle reset-prompt
}
zle -N git_diff
bindkey "^G^D" git_diff

## fzf binding
if [[ -f $HOME/.fzf.zsh ]]; then
    # load fzf settings
    source $HOME/.fzf.zsh

    # Use fd command for fzf
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

    # Use mdfind command for fzf. doesn't work
    # export FZF_DEFAULT_COMMAND='mdfind -onlyin $HOME -name "*"'
    # export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    # export FZF_ALT_C_COMMAND='mdfind -onlyin $HOME -name "* kind:folder"' 

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
if uname -r | grep -q 'Darwin'; then
    alias gitu='git add . && git commit && git push'
fi
alias history='history -E'

alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

cdls ()
{
  \cd "$@" && \ls -U --color
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
        ls --color $*
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
alias vs='nvim -u ~/.config/nvim/simple.lua'
alias y='yazi'
alias e="emacs"
alias duh="du -h -d1"
alias kill9="kill -9"

alias venv-home="source ~/.venv/bin/activate" # source virtualenv at home directory
alias venv-here="source .venv/bin/activate"   # source virtualenv at current directory
alias venv="venv-here || venv-home"   # Try sourcing virtualenv at current directory, then home directory

alias rn='ranger --choosedir=/tmp/rangerdir; LASTDIR=`cat /tmp/rangerdir`; cd "$LASTDIR"'

alias fzfkill="(date; ps -ef) | fzf --bind='ctrl-r:reload(date; ps -ef)' --header=$'Press CTRL-R to reload\n\n' --header-lines=2 --preview='echo {}' --preview-window=down,3,wrap --layout=reverse --height=80% | awk '{print $2}' | xargs kill -9"

notify_and_say() {
    osascript -e "display notification \"$*\" with title \"Title\""
    say "$*"
}

alias notify-say=notify_and_say

IS_WSL=$(uname -r | grep 'microsoft')
IS_MACOS=$(uname | grep 'Darwin')

xdg_open2() {
    if [[ -n $IS_WSL ]]; then
        # WSL
        if [ -z $* ]; then
            explorer.exe .
        else
            (\cd $*; explorer.exe .)
        fi
        return 0
    fi
    if [[ -n $IS_MACOS ]]; then
        # macOS
        if [[ -z $* ]]; then
            open .
        else
            open $*
        fi
        return 0
    fi
    # otherwise Linux
    if [[ -z $* ]]; then
        xdg-open .
    else
        xdg-open $*
    fi
}
alias o="xdg_open2"
alias imo='f(){convert $1 sixel:-;}; f'

# If not wsl or macos, is linux and map xclip to pbcopy
if [[ -z $IS_WSL ]] && [[ -z $IS_MACOS ]]; then
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
fi

alias pip_update_all='pip freeze --local | grep -v "^\-e" | cut -d = -f 1 | xargs pip install -U'
alias wget_cache_website='wget --mirror --page-requisites --quiet --show-progress --no-parent --convert-links --execute robots=off'
alias jl='julia'
alias manj='LANG=ja_JP.UTF-8 man'

alias gmsg='git diff --staged | ollama run tavernari/git-commit-message | tee >(pbcopy)' # Generate commit message from staged changes

### suffix alias
function extract() {
  local tmp_dir="$(mktemp -d --tmpdir=./)"
  local archive_file_name="$(basename "$1")"
  # /dev/null に投げてるのはchpwd対策
  local absolute_path="$(cd $(dirname $1) > /dev/null 2>&1 && pwd)/${archive_file_name}"

  while read line; do
    local suf=$(echo -n $line | cut -d' ' -f1)
    if [[ ${archive_file_name} == *${suf} ]] then
      local suffix=$suf
      local command="$(echo $line | sed -E 's/^[.a-zA-Z0-9]+ +//')"
      break
    fi
  done < <(echo  \
'.tar.gz  tar xzvf
.tgz     tar xzvf
.tar.xz  tar Jxvf
.zip     unzip
.lzh     lha e
.tar.bz2 tar xjvf
.tbz     tar xjvf
.tar.Z   tar zxvf
.gz      gzip -dc
.bz2     bzip2 -dc
.Z       uncompress
.tar     tar xvf')

  # 展開
  ln -s "${absolute_path}" "${tmp_dir}/${archive_file_name}"
  (
    cd "${tmp_dir}" > /dev/null 2>&1
    ${=command} ${archive_file_name} || exit 1
    rm "${archive_file_name}"
  )
  # 展開が失敗していれば、tmp_dirを消して1を返す
  if [[ $? != '0' ]] ; then
    rm -rf "${tmp_dir}"
    return 1
  fi

  local dir_name="$(ls -A "${tmp_dir}")"
  if [[ -d "${tmp_dir}/${dir_name}" ]]; then
    if [[ -d "./${dir_name}" ]]; then
      (
        echo "cannot move directory '${dir_name}': File exists"
        echo "extracted files in ${tmp_dir}/${dir_name}"
      ) 1>&2
      return 1
    else
      'mv' "${tmp_dir}/${dir_name}" ./
      rm -rf "${tmp_dir}"
    fi
  else
    local dir_name="$(basename "${archive_file_name}" "${suffix}")"
    if [[ -d "./${dir_name}" ]]; then
      (
        echo "cannot move directory '${dir_name}': File exists"
        echo "extracted directory as ${tmp_dir}"
      ) 1>&2
    else
      'mv' "${tmp_dir}" "${dir_name}"
    fi
  fi
}
alias -s {gz,tgz,zip,lzh,bz2,tbz,Z,tar,arj,xz}=extract

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
# zmodload zsh/terminfo
# bindkey "$terminfo[kcuu1]" history-substring-search-up
# bindkey "$terminfo[kcud1]" history-substring-search-down
# bindkey '^[[A' history-substring-search-up			
# bindkey '^[[B' history-substring-search-down

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
export PATH=$HOME/.cargo/bin:${PATH}
export PATH=$HOME/bin:${PATH}
export PATH=$HOME/.local/share/gem/ruby/3.0.0/bin:${PATH}

if command -v nvim &> /dev/null
then
    export EDITOR=$(which nvim)
else
    echo "nvim not found"
fi

# sheldon
if command -v sheldon &> /dev/null; then
    cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}
    sheldon_cache="$cache_dir/sheldon.zsh"
    sheldon_toml="$HOME/.config/sheldon/plugins.toml"
    if [[ ! -r "$sheldon_cache" || ! -s "$sheldon_cache" || "$sheldon_toml" -nt "$sheldon_cache" ]]; then
        mkdir -p $cache_dir
        sheldon source > $sheldon_cache
    fi
    source "$sheldon_cache"
    unset cache_dir sheldon_cache sheldon_toml
    eval "$(sheldon source)"
    cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}
    sheldon_cache="$cache_dir/sheldon.zsh"
    sheldon_toml="$HOME/.config/sheldon/plugins.toml"
    if [[ ! -r "$sheldon_cache" || "$sheldon_toml" -nt "$sheldon_cache" ]]; then
        mkdir -p $cache_dir
        sheldon source > $sheldon_cache
    fi
    source "$sheldon_cache"
    unset cache_dir sheldon_cache sheldon_toml
else
    echo "sheldon not loaded"
    echo "Therefore, z.lua not loaded"
fi

if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
else
    PROMPT_TIME='%F{3}%D{%m-%d %H:%M:%S}%f'
    PROMPT_USER_NAME='%F{2}%n%f'
    PROMPT_HOST_NAME='%F{2}%m%f'
    PROMPT_CWD='%F{6}%~%f'
    PROMPT="%B$PROMPT_TIME%b \
%B$PROMPT_USER_NAME%b \
in %{[1;2;32m%}$PROMPT_HOST_NAME%{[0m%} \
in %B${PROMPT_CWD}%b -> "
fi

## fzf+z.lua binding
if which fzf > /dev/null && which _zlua > /dev/null; then
    # use fzf to find repos in ghq
    zlua_fzf() {
        local dir_name=$(z | tac | fzf --no-sort)
        local dir_name=${dir_name##[0-9]* }
        if [ -n "${dir_name}" ]; then
            \cd ${dir_name}
            ls
            zle redisplay
        fi
        pwd
    }
    zle -N zlua_fzf
    bindkey "^K" zlua_fzf
else
    echo zlua_fzf not loaded
fi

# Misc functions to test the shell color features
test_colors(){
    for style in {0..8}; do
        for fg in {30..37}; do
            for bg in {40..47}; do
                # \e[m resets the color
                echo -ne "\e[$style;$fg;${bg}m\\\e[$style;$fg;${bg}m\e[m ";
            done;
            echo;
        done;
    done;
    echo ""
}

test_colors_256(){
    for i in {0..255} ; do
        printf "\x1b[48;5;%sm%3d\e[0m " "$i" "$i"
        if (( i == 15 )) || (( i > 15 )) && (( (i-15) % 6 == 0 )); then
            printf "\n";
        fi
    done
}

## Abbreviations
if command -v abbr &> /dev/null; then
    abbr -S g="git" >/dev/null
    abbr -S gf="git fetch" >/dev/null
    abbr -S gl='git l' >/dev/null
    abbr -S gld='git ld' >/dev/null
    abbr -S glo='git lo' >/dev/null

    abbr -S de='deactivate' >/dev/null
    abbr -S py='python3' >/dev/null
    abbr -S ipy='ipython' >/dev/null
    abbr -S jn='jupyter notebook' >/dev/null

    abbr -S v="nvim" >/dev/null
    abbr -S n="neovide" >/dev/null

    abbr -S tm="tn" >/dev/null
    abbr -S ks="tmux -u kill-session -t" >/dev/null
    abbr -S kp="tmux -u kill-pane -t" >/dev/null
    abbr -S kw="tmux -u kill-window -t" >/dev/null
    abbr -S tls="tmux -u ls" >/dev/null
    abbr -S ta="tmux -u a -t" >/dev/null
else
    alias g="git" >/dev/null
    alias gf="git fetch" >/dev/null
    alias gl='git l' >/dev/null
    alias gld='git ld' >/dev/null
    alias glo='git lo' >/dev/null

    alias de='deactivate' >/dev/null
    alias py='python3' >/dev/null
    alias ipy='ipython' >/dev/null
    alias jn='jupyter notebook' >/dev/null

    alias v="nvim" >/dev/null
    alias n="neovide" >/dev/null

    alias tm="tn" >/dev/null
    alias ks="tmux -u kill-session -t" >/dev/null
    alias kp="tmux -u kill-pane -t" >/dev/null
    alias kw="tmux -u kill-window -t" >/dev/null
    alias tls="tmux -u ls" >/dev/null
    alias ta="tmux -u a -t" >/dev/null
fi

# For servers
alias gpustat-all='ssh as gpustat-all'
alias gpustat-all-fast='ssh as gpustat-all-fast'
alias gtop="$HOME/scripts/gtop"
alias gtopa="$HOME/scripts/gtop-all"
alias ssync="$HOME/scripts/ssync"
alias rsync="rsync --exclude-from=$HOME/.rsyncignore"

EXCLUDE_LIST=$(echo --exclude={"*.png","*.jpg","*.json","*.bag","*.bin","*.mp4",'*.pth',"*.h5","*.db","*.pkl","*.a","*.MP4","*.raw","*.nfs0000*",".#*"})

# Copy from/to server the lap scripts
function sync-lap-from(){
    # Should have an argument
    if [ $# -lt 2 ]; then
        echo "Usage: sync-lap-from <dst> <file>"
        return 1
    fi
    SERVER=$1
    shift
    TARGET=$1
    shift
    OPTIONS=$@
    ssync -aZ --update $SERVER:~/lap/$TARGET/ $HOME/lap/$TARGET/ $OPTIONS $EXCLUDE_LIST
}

function sync-lap-to(){
    # Should have an argument
    if [ $# -lt 2 ]; then
        echo "Usage: sync-lap-to <dst> <file>"
        return 1
    fi
    SERVER=$1
    shift
    TARGET=$1
    shift
    OPTIONS=$@
    ssync -aZ --update $HOME/lap/$TARGET/ $SERVER:~/lap/$TARGET/ $OPTIONS $EXCLUDE_LIST
}

# Copy scripts from/to SERVER
function sync-from() {
    # Should have an argument
    if [ $# -lt 2 ]; then
        echo "Usage: sync-from <dst> <file> <OPTIONS?>"
        return 1
    fi
    SERVER=$1
    shift
    TARGET=$1
    shift
    OPTIONS=$@
    echo "Syncing from $SERVER:$TARGET", "OPTIONS: $OPTIONS"
    if [[ "$TARGET" == /* || "$TARGET" == ~* ]]; then
        # TARGET is absolute path
        ssync -aZ --update $SERVER:$TARGET/ $TARGET/ $OPTIONS $EXCLUDE_LIST
    else
        # TARGET is relative path
        ssync -aZ --update $SERVER:$(pwd)/$TARGET/ $(pwd)/$TARGET/ $OPTIONS $EXCLUDE_LIST
    fi
}

function sync-to(){
    # Should have an argument
    if [ $# -lt 2 ]; then
        echo "Usage: sync-to <dst> <file> <OPTIONS?>"
        return 1
    fi
    SERVER=$1
    shift
    TARGET=$1
    shift
    OPTIONS=$@
    if [[ "$TARGET" == /* || "$TARGET" == ~* ]]; then
        # TARGET is absolute path
        ssync -aZ --update $TARGET/ $SERVER:$TARGET/ $OPTIONS $EXCLUDE_LIST
    else
        # TARGET is relative path
        ssync -aZ --update $(pwd)/$TARGET/ $SERVER:$(pwd)/$TARGET/ $OPTIONS $EXCLUDE_LIST
    fi
}

gpustat ()
{
    ssh "$@" "/usr/bin/gpustat -up; ps aux --sort -%cpu" | head -n $(($(tput lines)-2)) | cut -c -$(tput cols)
}
watch-gpustat ()
{
    watch 'ssh' $@' "/usr/bin/gpustat -up; ps aux --sort -%cpu" | head -n $(($(tput lines)-2)) | cut -c -$(tput cols)'
}

# Use the same completion
compdef gtop=ssh
compdef ssync=scp
