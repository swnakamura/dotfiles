function __notify_long --on-event fish_postexec
    # 直前のコマンドの終了ステータスを退避（以降のコマンドで $status が上書きされるため）
    set -l exit_status $status

    # $CMD_DURATION はミリ秒。60000ms = 60秒
    if test $CMD_DURATION -lt 60000
        return
    end

    # 対話的に長居しがちなコマンドは除外
    set -l cmd_name (string split ' ' -- $argv[1])[1]
    switch $cmd_name
        case vim nvim vi emacs less more man ssh tmux screen htop top watch fzf
            return
    end

    set -l secs (math -s0 "$CMD_DURATION / 1000")
    set -l mark "✓"
    test $exit_status -ne 0; and set mark "✗($exit_status)"
    set -l msg "$mark [$secs s] $argv[1]"
    set -l seq "\033]777;notify;fish;$msg\007"

    if set -q TMUX
        printf "\033Ptmux;\033%b\033\\" "$seq" >/dev/tty
    else
        printf "%b" "$seq" >/dev/tty
    end
end
