function fzf_pjc
    set -l project_name (ghq list | sort | fzf)

    if test -n "$project_name"
        cd (ghq root)/$project_name
        myls
    end

    commandline -f repaint
end
