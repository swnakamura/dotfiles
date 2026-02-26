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
    commandline -f repaint
end
