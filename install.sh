set -x
set -e
#vundle
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cp vimrcs/vundle.vimrc ~/.vimrc
vim +PluginInstall -c quitall

#vim-go
cp vimrcs/vim-go.vimrc ~/.vimrc
vim +PluginInstall -c quitall
vim +GoInstallBinaries -c quitall

#ycm clone
cp vimrcs/ycm.vimrc ~/.vimrc
vim +PluginInstall -c quitall
cd ~/.vim/bundle/YouCompleteMe/third_party/ycmd/third_party
git submodule update --init --recursive
cd -

#ycm install
cd ~/.vim/bundle/YouCompleteMe
python install.py --gocode-completer --clang-completer
cd -

#other install

#cp .ycm_extra_conf.py
cp ycm_extra_conf.py ~/.ycm_extra_conf.py

#final vimrc
cp vimrcs/final.vimrc ~/.vimrc
