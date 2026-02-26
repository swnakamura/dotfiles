function za
    if test (count $argv) -gt 0
        zellij attach $argv
        return
    end
    set -l target (zellij ls -n | grep -v EXITED | fzf | cut -d' ' -f 1)
    zellij attach $target
end
