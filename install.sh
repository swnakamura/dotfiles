#!/bin/bash
SCRIPTHOME="$( cd "$(dirname "$0")" || exit ; pwd -P )"
echo Script is executed at "$SCRIPTHOME"

function link_to_home() {
    echo "Linking $1"
    # If parent directory doesn't exist, create it
    if [[ ! -e ~/$1 ]]; then
        mkdir -p "$(dirname ~/$1)"
    fi
    if [[ -e ~/$1 ]]; then
        if [[ -L ~/$1 ]]; then
            echo "	unlinked old link"
            unlink ~/$1
        else
            echo "	Moving $1 to $1.old"
            mv ~/$1 ~/${1}.old
        fi
    fi
    echo "	linked new link"
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
link_to_home .config/lsd
# karabiner settings are not portable; connected mouses and keyboards matter
# mkdir -p ~/.config/karabiner
# link_to_home .config/karabiner/karabiner.json
link_to_home .config/git
link_to_home .config/zathura
link_to_home .rsyncignore
link_to_home .wezterm.lua
link_to_home .popt
