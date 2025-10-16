# ~/.config/fish/config.fish

function setup_variables
    # PATH
    set -g PATH $HOME/.pixi/bin $PATH

    # よく使う変数
    set -g EDITOR nvim

    # OSを判定してグローバル変数に設定
    set -l os (uname)
    if test "$os" = Darwin
        set -g IS_MACOS 1
        set -g IS_WSL ""
    else if test "$os" = Linux
        set -g IS_MACOS ""
        set -g IS_WSL ""
    else
        set -g IS_MACOS ""
        set -g IS_WSL 1
    end

    # rsyncで使う変数
    set -gx INCLUDE_TEXTS --include={'*.c','*.cpp','*.h','*.hpp','*.py','*.sh','*.lua','*.txt','*.md','*.json','*.yaml','*.yml','*.csv','*.tsv','*.ini','*.cfg','*.conf','*.xml','*.html','*.htm','*.js','*.css','*.java','*.go','*.rs','*.rb','*.pl','*.php'}
    set -gx INCLUDE_TEXTSONLY --include='*/' --include={'*.c','*.cpp','*.h','*.hpp','*.py','*.sh','*.lua','*.txt','*.md','*.json','*.yaml','*.yml','*.csv','*.tsv','*.ini','*.cfg','*.conf','*.xml','*.html','*.htm','*.js','*.css','*.java','*.go','*.rs','*.rb','*.pl','*.php'} --exclude='*'

    set -gx EXCLUDE_BINS --exclude={'*.jpg','*.png','*.json','*.bag','*.bin','*.mp4','*.pth','*.h5','*.db','*.pkl','*.a','*.MP4','*.raw','*.nfs0000*','.#*'}
    set -gx EXCLUDE_BINS_MORE --exclude={'*.png','*.jpg','*.jpeg','*.json','*.bag','*.bin','*.mp4','*.MP4','*.m4a','*.gif','*.pth','*.ckpt*','*.pt','*.h5','*.db','*.mdb','*.pkl','*.a','*.o','*.raw','*.so','*.zip','*.nfs0000*','.#*'}

    # そのほか
    pixi completion --shell fish | source
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

    # git
    if test -n "$IS_MACOS"
        alias gitu='git add . && git commit && git push'
    end
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

    # Linux環境向けのクリップボードエイリアス
    if not test -n "$IS_WSL"; and not test -n "$IS_MACOS"
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
    abbr --add tm tn
    abbr --add ks "tmux -u kill-session -t"
    abbr --add kp "tmux -u kill-pane -t"
    abbr --add kw "tmux -u kill-window -t"
    abbr --add tls "tmux -u ls"
    abbr --add ta "tmux -u a -t"
    abbr --add y yazi
end

function setup_functions
    function myls
        if command -v lsd > /dev/null
            lsd $argv
        else
            /bin/ls --color $argv
        end
    end

    function cdls
        builtin cd $argv && /bin/ls -U --color
    end

    function venv
        set PWD_ORIG $PWD
        if not type -q uv
            echo "uv command not found. Check if you're in the right environment"
            return 1
        end
        while true
            if test -f .venv/bin/activate
                break
            end
            if test $PWD = "/"
                printf '\033[1;31;49m%s\033[m\n' 'No virtualenv found'
                builtin cd $PWD_ORIG
                return 1
            end
            builtin cd ..
        end
        source .venv/bin/activate.fish ^/dev/null; or source .venv/bin/activate
        if test $PWD != $PWD_ORIG
            printf "\033[6;31;50mvenv at a different directory\033[m\n"
        end
        printf 'venv at \033[1;32;49m%s\033[m\n' $PWD
        builtin cd $PWD_ORIG
    end

    # Load confidential configurations
    function load_conf_conf
        set -l conf_file $HOME/syncthing_config/secrets.fish
        if test -f $conf_file
            source $conf_file
            echo "Loaded confidential configurations from $conf_file"
        else
            echo "Confidential configuration file $conf_file not found."
        end
    end

    alias o="xdg_open2"
    function xdg_open2
        if test -n $IS_WSL
            # WSL
            if test -z $argv
                explorer.exe .
            else
                builtin cd $argv; explorer.exe .; builtin cd -
            end
            return 0
        end
        if test -n $IS_MACOS
            # macOS
            if test -z $argv
                open .
            else
                open $argv
            end
            return 0
        end
        # otherwise Linux
        if test $argv = ""
            xdg-open .
        else
            xdg-open $argv
        end
    end

    function history
        builtin history
    end

    function fzfkill
        { date; ps -ef } | fzf --bind='ctrl-r:reload(date; ps -ef)' --header='Press CTRL-R to reload\n\n' --header-lines=2 --preview='echo {}' --preview-window=down,3,wrap --layout=reverse --height=80% | awk '{print $2}' | xargs kill -9
    end
    bind -M insert \cq fzfkill

    # Copy current command content to clipboard
    # https://askubuntu.com/questions/413436/copy-current-terminal-prompt-to-clipboard
    function copy_line_to_clipboard
        set cmd (commandline)
        if set -q DISPLAY; and type -q xclip
            echo -n $cmd | xclip -selection clipboard
        else
            # Use OSC52 to copy
            printf "\e]52;c;%s\a" (echo -n $cmd | base64 | tr -d '\n')
        end
    end
    bind -M insert \cy copy_line_to_clipboard
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

    ## ^G^S で Git のステータスを表示
    function git_status
        echo ""
        set_color --bold --underline green
        echo "git brahches:"
        set_color normal
        git branch -vv
        echo ""
        set_color --bold --underline green
        echo "git status:"
        set_color normal
        git status -s
        # show prompt again
        commandline -f repaint
    end
    bind -M insert \cg\cs git_status

    ## ^G^D で Git の差分を表示
    function git_diff
        git diff
        # show prompt again
        commandline -f repaint
    end
    bind -M insert \cg\cd git_diff

    # fzf の設定
    if type -q fzf
        # fzfの基本的なキーバインドを読み込む (推奨)
        fzf --fish | source

        # fzfが使うデフォルトコマンドを `fd` に設定
        set -x FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
        set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
        set -x FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'

        # ghqで管理するリポジトリにfzfで移動する関数
        function fzf_pjc
            # ghqのリストからfzfでプロジェクトを選択
            set -l project_name (ghq list | sort | fzf)

            # プロジェクトが選択された場合のみ実行
            if test -n "$project_name"
                cd (ghq root)/$project_name
                myls
            end

            # プロンプトを再描画する
            commandline -f repaint
        end
        # Ctrl + ] に関数を割り当て
        bind -M insert \c] fzf_pjc
    else
        echo "fzf not found"
    end

    # Check if both fzf and zoxide are installed
    if type -q fzf; and type -q zoxide

        zoxide init fish --cmd='j' | source

        function zi_and_prompt
            # Get directory list from 
            ji
            # Repaint the command line to show the new prompt
            commandline -f repaint
        end

        # Bind the function to Ctrl+K
        bind -M insert \ck zi_and_prompt
    else
        echo "fzf or zoxide not found; zooxide keybinding not set"
    end
end

# Call setup functions
setup_variables
setup_aliases
setup_functions
setup_keybinds
