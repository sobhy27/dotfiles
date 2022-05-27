# alacritty
rm -rf ${XDG_CONFIG_HOME:-$HOME/.config}/alacritty
ln -s $PWD/alacritty ${XDG_CONFIG_HOME:-$HOME/.config}/alacritty

# i3-wm
rm -rf ${XDG_CONFIG_HOME:-$HOME/.config}/i3
ln -s $PWD/i3 ${XDG_CONFIG_HOME:-$HOME/.config}/i3

# neovim
rm -rf ${XDG_CONFIG_HOME:-$HOME/.config}/nvim
ln -s $PWD/nvim ${XDG_CONFIG_HOME:-$HOME/.config}/nvim

# tmux
rm -f $HOME/.tmux.conf
ln -s $PWD/.tmux.conf $HOME/.tmux.conf

# vimrc
rm -f $HOME/.vimrc
ln -s $PWD/.vimrc $HOME/.vimrc

# xinit
rm -f $HOME/.xinitrc
ln -s $PWD/.xinitrc $HOME/.xinitrc

# zshrc
rm -f $HOME/.zshrc
ln -s $PWD/.zshrc $HOME/.zshrc
