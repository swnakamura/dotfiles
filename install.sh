SCRIPTHOME="$( cd "$(dirname "$0")" ; pwd -P )"
echo $SCRIPTHOME
ln -s $SCRIPTHOME/.tmux.conf ~/.tmux.conf
ln -s $SCRIPTHOME/.gitconfig ~/.gitconfig
ln -s $SCRIPTHOME/.latexmkrc ~/.latexmkrc
ln -s $SCRIPTHOME/.zshrc     ~/.zshrc
ln -s $SCRIPTHOME/.fzf.bash  ~/.fzf.bash
ln -s $SCRIPTHOME/.fzf.zsh   ~/.fzf.zsh
ln -s $SCRIPTHOME/.config/kitty/kitty.conf   ~/.config/kitty/kitty.conf
ln -s $SCRIPTHOME/.config/starship.toml   ~/.config/starship.toml
ln -s $SCRIPTHOME/.config/fontconfig/conf.d ~/.config/fontconfig/conf.d

# ln -s $SCRIPTHOME/.w3m ~/.w3m
# ln -s $SCRIPTHOME/.config/libskk ~/.config/libskk/
# ln -s $SCRIPTHOME/.config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml
# ln -s $SCRIPTHOME/.config/almel/almel.yaml ~/.config/almel/almel.yml
