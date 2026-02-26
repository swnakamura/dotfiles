function copy_line_to_clipboard
    # Copy current command content to clipboard
    # https://askubuntu.com/questions/413436/copy-current-terminal-prompt-to-clipboard
    set cmd (commandline)
    if set -q DISPLAY; and type -q xclip
        echo -n $cmd | xclip -selection clipboard
    else
        # Use OSC52 to copy
        printf "\e]52;c;%s\a" (echo -n $cmd | base64 | tr -d '\n')
    end
end
