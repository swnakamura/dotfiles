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
