#!/bin/bash
SCRIPTHOME="$( cd "$(dirname "$0")" || exit ; pwd -P )"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

ok()     { echo -e "  ${GREEN}✔${RESET}  $*"; }
warn()   { echo -e "  ${YELLOW}⚠${RESET}  $*"; }
info()   { echo -e "  ${CYAN}→${RESET}  $*"; }
err()    { echo -e "  ${RED}✘${RESET}  $*"; }

echo -e "\n${BOLD}dotfiles${RESET} ${DIM}$SCRIPTHOME${RESET}\n"

function link_to_home() {
    local target=~/"$1"
    local source="$SCRIPTHOME/$1"

    # If parent directory doesn't exist, create it
    if [[ ! -e "$target" ]]; then
        mkdir -p "$(dirname "$target")"
    fi

    if [[ -L "$target" ]]; then
        unlink "$target"
        info "${DIM}~/$1${RESET} ${DIM}(replaced old symlink)${RESET}"
    elif [[ -e "$target" ]]; then
        mv "$target" "${target}.old"
        warn "${DIM}~/$1${RESET} backed up as ${YELLOW}~/$1.old${RESET}"
    fi

    if ln -s "$source" "$target"; then
        ok "~/$1"
    else
        err "~/$1  ${RED}(symlink failed — source missing?)${RESET}"
    fi
}

# link_to_home .config/karabiner/karabiner.json # karabiner settings are not portable; connected mouses and keyboards matter
# link_to_home .config/sheldon
# link_to_home .spacemacs
# link_to_home .wezterm.lua
link_to_home .config/nvim
link_to_home .config/fish
link_to_home .config/git
# link_to_home .config/kitty
link_to_home .config/ghostty
link_to_home .config/lsd
link_to_home .config/neovide
link_to_home .config/starship.toml
link_to_home .config/zathura
link_to_home .config/zellij/config.kdl
link_to_home .fzf.bash
link_to_home .fzf.zsh
link_to_home .latexmkrc
link_to_home .pixi/manifests/pixi-global.toml
link_to_home .rsyncignore
link_to_home .tmux.conf
link_to_home .tmux_status_format.sh
link_to_home .zshrc
link_to_home scripts/ssync

# If linux, link fcitx5 hotkey extension
# To use this, you need to run: `yay -S fcitx5-lua`
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo -e "\n${DIM}Linux detected — linking fcitx5${RESET}"
    link_to_home .local/share/fcitx5/addon/hotkey-extension.conf
    link_to_home .local/share/fcitx5/lua/hotkey-extension
fi

echo

