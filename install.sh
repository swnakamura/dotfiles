SCRIPTHOME="$( cd "$(dirname "$0")" ; pwd -P )"
ln -fs $SCRIPTHOME/.w3m ~/.w3m
ln -fs $SCRIPTHOME/.tmux.conf ~/.tmux.conf
ln -fs $SCRIPTHOME/.gitconfig ~/.gitconfig
ln -fs $SCRIPTHOME/.latexmkrc ~/.latexmkrc
ln -fs $SCRIPTHOME/.zshrc ~/.zshrc
ln -fs $SCRIPTHOME/.fzf.bash ~/.fzf.bash
ln -fs $SCRIPTHOME/.fzf.zsh ~/.fzf.zsh
ln -sf $SCRIPTHOME/.config/libskk ~/.config/libskk/
ln -sf $SCRIPTHOME/.config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml
ln -sf $SCRIPTHOME/.config/almel/almel.yaml ~/.config/almel/almel.yml
ln -sf $SCRIPTHOME/.config/fontconfig/conf.d ~/.config/fontconfig/conf.d
