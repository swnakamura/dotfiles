function cdls
    if test (count $argv) -eq 1; and string match -q -- - $argv[1]
        set argv $OLDPWD
    end
    set -l previous $PWD
    builtin cd $argv
    or return
    if test "$PWD" != "$previous"
        set -g dirprev $dirprev $previous
        set -e dirnext
    end
    ls -U
end
