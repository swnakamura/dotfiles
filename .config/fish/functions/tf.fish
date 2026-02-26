function tf --description "tmuxセッションにアタッチ。引数があればそのセッションにアタッチ、なければfzfで選択"
    if test (count $argv) -gt 0
        tmux -u attach -t $argv
        return
    end
    set -l target (tmux -u ls | grep -v 'no server running' | fzf | cut -d: -f1)
    tmux -u attach -t $target
end
