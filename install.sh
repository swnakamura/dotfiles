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

# mkdir -p ~/.config/git; ln -sf "$SCRIPTHOME"/.gitignore_global ~/.config/git/ignore
# mkdir -p ~/.ctags.d/; ln -sf "$SCRIPTHOME"/.ctags.d/vim.ctags   ~/.ctags.d/vim.ctags
# mkdir -p ~/.config/kitty; ln -sf "$SCRIPTHOME"/.config/kitty/kitty.conf ~/.config/kitty/kitty.conf

# ln -s "$SCRIPTHOME"/.config/fontconfig/conf.d ~/.config/fontconfig/conf.d
# ln -s "$SCRIPTHOME"/.w3m ~/.w3m
# ln -s "$SCRIPTHOME"/.config/libskk ~/.config/libskk/
# ln -s "$SCRIPTHOME"/.config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml
# ln -s "$SCRIPTHOME"/.config/almel/almel.yaml ~/.config/almel/almel.yml
