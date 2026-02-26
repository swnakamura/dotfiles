function zar
    if test (count $argv) -gt 0
        zellij attach $argv
        return
    end
    set -l target (zellij ls -n | fzf | cut -d' ' -f 1)
    zellij attach $target
end
