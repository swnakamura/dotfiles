# ~/.config/fish/config.fish

function setup_variables
    # よく使う変数
    set -gx EDITOR nvim

    # いまはアメリカ在住
    # set -gx TZ 'America/Los_Angeles'
    # 日本在住に戻った
    set -gx TZ 'Asia/Tokyo'

    # path to pixi binaries
    fish_add_path ~/.pixi/bin/

    # Fishのキーバインドをviモードに変更
    set -g fish_key_bindings fish_vi_key_bindings

    # OSを判定してグローバル変数に設定
    set -gx IS_MACOS ""
    set -gx IS_LINUX ""
    set -gx IS_WSL   ""
    set -l os (uname)
    if test "$os" = Darwin
        set -g IS_MACOS 1
    else if test "$os" = Linux
        set -g IS_LINUX 1
    else
        set -g IS_WSL 1
    end

    # rsyncで使う変数
    set -gx INCLUDE_TEXTS --include={'*.c','*.cpp','*.h','*.hpp','*.py','*.sh','*.lua','*.txt','*.md','*.json','*.yaml','*.yml','*.csv','*.tsv','*.ini','*.cfg','*.conf','*.xml','*.html','*.htm','*.js','*.css','*.java','*.go','*.rs','*.rb','*.pl','*.php'}
    set -gx INCLUDE_TEXTSONLY --include='*/' --include={'*.c','*.cpp','*.h','*.hpp','*.py','*.sh','*.lua','*.txt','*.md','*.json','*.yaml','*.yml','*.csv','*.tsv','*.ini','*.cfg','*.conf','*.xml','*.html','*.htm','*.js','*.css','*.java','*.go','*.rs','*.rb','*.pl','*.php'} --exclude='*'

    set -gx EXCLUDE_BINS --exclude={'*.jpg','*.png','*.json','*.bag','*.bin','*.mp4','*.pth','*.h5','*.db','*.pkl','*.a','*.MP4','*.raw','*.nfs0000*','.#*'}
    set -gx EXCLUDE_BINS_MORE --exclude={'*.png','*.jpg','*.jpeg','*.json','*.bag','*.bin','*.mp4','*.MP4','*.m4a','*.gif','*.pth','*.ckpt*','*.pt','*.h5','*.db','*.mdb','*.pkl','*.a','*.o','*.raw','*.so','*.zip','*.nfs0000*','.#*'}
end

function setup_aliases
    # 基本的なエイリアス
    alias cp="cp -i"
    alias df='df -h'
    alias free='free -m'
    alias history='history -E'
    alias ...='cd ../..'
    alias ....='cd ../../..'
    alias .....='cd ../../../..'
    alias duh="du -h -d1"
    alias kill9="kill -9"
    alias jl='julia'
    alias manj='LANG=ja_JP.UTF-8 man'

    # gitのstaged内容からOllamaでコミットメッセージを生成しクリップボードにコピー
    # Zshの `>(pbcopy)` はFishではサポートされないため `tee /dev/tty | pbcopy` で代用
    alias gmsg='git diff --staged | ollama run tavernari/git-commit-message | tee /dev/tty | pbcopy'

    # ls (myls関数を使用)
    alias ls="myls"
    alias ll="myls -l"
    alias llh="myls -lh"
    alias lhl="myls -lh"
    alias la="myls -a"
    alias lal="myls -la"
    alias lla="myls -la"

    # cd (cdls関数を使用)
    alias cd="cdls"

    # fzf連携 (zoxideを想定)
    alias zc="z -c"
    alias zi="z -I"

    # その他ツール
    alias vs='nvim -u ~/.config/nvim/simple.lua'
    alias rn='ranger --choosedir=/tmp/rangerdir; and set LASTDIR (cat /tmp/rangerdir); and cd "$LASTDIR"'
    alias imo='functions -c imo f; and f' # one-liner function alias
    alias notify-say=notify_and_say
    alias pip_update_all='pip freeze --local | grep -v "^\-e" | cut -d = -f 1 | xargs pip install -U'
    alias wget_cache_website='wget --mirror --page-requisites --quiet --show-progress --no-parent --convert-links --execute robots=off'
    alias o="xdg_open2"

    # Linux環境向けのクリップボードエイリアス
    if test -n "$IS_LINUX"
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
    end

    # サーバー上での実行向け
    alias gtop="$HOME/scripts/gtop"
    alias gtopa="$HOME/scripts/gtop-all"
    alias ssync="$HOME/scripts/ssync"
    alias rsync="rsync --exclude-from=$HOME/.rsyncignore"
    alias run_sif=~/singularity/scripts/run_sif.sh # To run sif for uv in server

    # Abbreviations
    abbr --add g git
    abbr --add gf "git fetch"
    abbr --add gl "git l"
    abbr --add gld "git ld"
    abbr --add glo "git lo"
    abbr --add de "deactivate"
    abbr --add py python3
    abbr --add ipy ipython
    abbr --add jn "jupyter lab"
    abbr --add v nvim
    abbr --add n neovide
    abbr --add ks "tmux -u kill-session -t"
    abbr --add kp "tmux -u kill-pane -t"
    abbr --add kw "tmux -u kill-window -t"
    abbr --add tls "tmux -u ls"
    abbr --add y yazi
    if test -n $IS_LINUX
        abbr --add zl "systemd-run --scope --user zellij"
    else
        abbr --add zl "zellij"
    end
    abbr --add zls "zellij ls"
end

function setup_keybinds
    ## <C-o> を押して現在のコマンドラインを$EDITORで編集
    bind -M insert \co edit_command_buffer

    # 矢印キーの代わりにC-f/b/p/n
    bind -M insert \cf forward-char
    bind -M insert \cb backward-char
    bind -M insert \cp up-or-search
    bind -M insert \cn down-or-search

    # c-a/e to beginning/end of line
    bind -M insert \ca beginning-of-line
    bind -M insert \ce end-of-line

    bind -M insert \cq fzfkill
    bind -M insert \cy copy_line_to_clipboard

    bind -M insert \cg\cs git_status

    bind -M insert \cg\cd git_diff

    # fzf の設定
    if type -q fzf

        fzf --fish | source

        # fzfが使うデフォルトコマンドを `fd` に設定
        set -x FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
        set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
        set -x FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'

        # Ctrl + ] に関数を割り当て
        bind -M insert \c] fzf_pjc
    else
        echo "fzf not found"
    end

    # Check if both fzf and zoxide are installed
    if type -q fzf; and type -q zoxide

        zoxide init fish --cmd='j' | source

        # Bind the function to Ctrl+K
        bind -M insert \ck zi_and_prompt
    else
        echo "fzf or zoxide not found; zoxide keybinding not set"
    end
end

# Call setup functions
setup_variables
setup_aliases
setup_keybinds
