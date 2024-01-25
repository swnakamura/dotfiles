#!/bin/bash
SCRIPTHOME="$( cd "$(dirname "$0")" || exit ; pwd -P )"
echo Script is executed at "$SCRIPTHOME"

function link_to_home() {
    if [[ -e ~/$1 ]]; then
        if [[ -L ~/$1 ]]; then
            unlink ~/$1
        else
            mv ~/$1 ~/${1}.old
        fi
    fi
    ln -s "$SCRIPTHOME"/$1 ~/$1
}

link_to_home .tmux.conf
link_to_home .latexmkrc
link_to_home .zshrc
link_to_home .fzf.bash
link_to_home .fzf.zsh
link_to_home .wezterm.lua
link_to_home .config/starship.toml
link_to_home .config/sheldon
mkdir -p ~/.config/karabiner
link_to_home .config/karabiner/karabiner.json
link_to_home .config/git
link_to_home .config/zathura
