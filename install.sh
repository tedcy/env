set -x
set -e

#./install_go.sh

git config --global http.sslVerify false

chmod 1777 /tmp
cp sources.list /etc/apt/sources.list
apt update
apt-get install -y software-properties-common
add-apt-repository -y ppa:deadsnakes/ppa | true
apt update
apt-get install -y python3.8 python3-pip

python3 -m pip install --upgrade pip #python-dev-tools

pip3 install pynvim --user
pip3 install keyring browser-cookie3 --user

#see here https://github.com/Valloric/YouCompleteMe#linux-64-bit
apt-get install -y build-essential cmake libpython3.8-dev --allow-unauthenticated 

rm -rf ~/.vim/bundle/*

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
python3 install.py --gocode-completer --clang-completer
cd -

#for taglist
apt-get install -y ctags --allow-unauthenticated

#other install
cp vimrcs/other.vimrc ~/.vimrc                  
vim +PluginInstall -c quitall                   
       
#cp .ycm_extra_conf.py
cp ycm_extra_conf.py ~/.ycm_extra_conf.py       
       
#final vimrc
cp vimrcs/final.vimrc ~/.vimrc
            
#for cmake completion
#https://github.com/Sarcasm/compdb#generate-a-compilation-database-with-header-files
#compdb -p build/ list > compile_commands.json  
#wget https://bootstrap.pypa.io/pip/3.5/get-pip.py -O get-pip.py
#python3 get-pip.py
pip install compdb
#rm -rf get-pip.py
            
#for make completion
#git clone https://github.com/rizsotto/Bear /root/Bear
#cd /root/Bear     
#git checkout 2.3.13
#cmake .
#make all    
#make install
#make package
#cd -        
#rm -rf /root/Bear
apt-get install -y bear

#for snippets
mkdir -pv ~/.vim/UltiSnips
cp snippets/all.snippets ~/.vim/UltiSnips/
