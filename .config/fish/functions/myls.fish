function myls
    if command -v lsd > /dev/null
        lsd $argv
    else
        /bin/ls --color $argv
    end
end
