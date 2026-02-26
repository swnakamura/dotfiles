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
