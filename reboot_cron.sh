#!/bin/sh
date
echo "==============================  MOVING TO neovim =============================="
cd ~/ghq/github.com/neovim/neovim
git pull origin master
make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/.neovim" CMAKE_BUILD_TYPE=Release
echo "==============================  MOVING TO neovide =============================="
cd ~/ghq/github.com/Kethku/neovide
git pull
cargo build --release
echo "DONE!"
