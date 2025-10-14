#!/bin/bash
SCRIPTHOME="$( cd "$(dirname "$0")" || exit ; pwd -P )"
echo Script is executed at "$SCRIPTHOME"

function link_to_home() {
    echo -n "Linking $1 ... "
    # If parent directory doesn't exist, create it
    if [[ ! -e ~/$1 ]]; then
        mkdir -p "$(dirname ~/"$1")"
    fi
    if [[ -e ~/$1 ]]; then
        if [[ -L ~/$1 ]]; then
            echo -n "unlinked old link ... "
            unlink ~/"$1"
        else
            echo "Moving $1 to $1.old"
            mv ~/"$1" ~/"$1".old
        fi
    fi
    echo -n "linked new link"
    ln -s "$SCRIPTHOME"/"$1" ~/"$1"
    echo
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
link_to_home .config/kitty
link_to_home .config/neovide
link_to_home .config/fish
link_to_home .rsyncignore
link_to_home .wezterm.lua
link_to_home .popt
link_to_home .spacemacs
link_to_home scripts/ssync

# If linux, link fcitx5 hotkey extension
# To use this, you need to run: `yay -S fcitx5-lua`
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    link_to_home .local/share/fcitx5/addon/hotkey-extension.conf
    link_to_home .local/share/fcitx5/lua/hotkey-extension
fi
