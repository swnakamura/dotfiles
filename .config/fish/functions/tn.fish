function tn
    if test (count $argv) -eq 1
        tmux -u new -s $argv
    else
        tmux -u new
    end
end
