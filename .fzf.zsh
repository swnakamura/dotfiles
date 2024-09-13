# Setup fzf
# ---------

if [[ -d /opt/homebrew ]]; then
    # macOS
    if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
      PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
    fi

    # Auto-completion
    # ---------------
    [[ $- == *i* ]] && source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2> /dev/null

    # Key bindings
    # ------------
    source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
else
    # linux
    if [[ ! "$PATH" == *$HOME/.fzf/bin* ]]; then
      export PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
    fi

    # Auto-completion
    # ---------------
    [[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.zsh" 2> /dev/null

    # Key bindings
    # ------------
    [[ -e $HOME/.fzf/shell/key-bindings.zsh ]] && source "$HOME/.fzf/shell/key-bindings.zsh"
    [[ -e /usr/share/fzf/key-bindings.zsh ]] && source "/usr/share/fzf/key-bindings.zsh"
    [[ -e /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source "/usr/share/doc/fzf/examples/key-bindings.zsh"
fi
