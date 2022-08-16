set -x
set -e

#./install_go.sh

#see here https://github.com/Valloric/YouCompleteMe#linux-64-bit
if [ ! `which gcc` ];then
    apt-get install -y build-essential cmake --allow-unauthenticated
fi

rm -rf ~/.vim/bundle/*
mkdir -pv ~/.vim/bundle

if [ -f "vim_download.tar.gz" ];then
    if [ ! -d "vim_download" ];then
        tar xzf vim_download.tar.gz
    fi
    cp -r vim_download/* ~/.vim/bundle/
fi

git config --global http.sslVerify false

#python3.8
#chmod 1777 /tmp
#cp sources.list /etc/apt/sources.list
#apt update
#apt-get install -y software-properties-common --allow-unauthenticated
#add-apt-repository -y ppa:deadsnakes/ppa | true
#apt update
#apt-get install -y python3.8 libpython3.8-dev --allow-unauthenticated
#update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2
#update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1
#if [ ! -f "get-pip.py" ];then
#    wget https://bootstrap.pypa.io/get-pip.py
#fi
##python3.5
##if [ ! -f "get-pip.py" ];then
##    wget https://bootstrap.pypa.io/pip/3.5/get-pip.py
##fi
#python3 get-pip.py

rm -rf openssl-1.1.1d
rm -rf /root/openssl
if [ ! -d "vim_download" ];then
    wget https://www.openssl.org/source/openssl-1.1.1d.tar.gz
    tar xvf openssl-1.1.1d.tar.gz
    rm -rf openssl-1.1.1d.tar.gz
else
    cp -r vim_download/openssl-1.1.1d .
fi
cd openssl-1.1.1d
./config --prefix=/root/openssl --openssldir=/root/openssl
make -j 20
make install
cd -

apt-get install -y libffi-dev --allow-unauthenticated
rm -rf Python-3.8.12
if [ ! -d "vim_download" ];then
    wget https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tar.xz
    tar xvf Python-3.8.12.tar.xz
    rm -rf Python-3.8.12.tar.xz
else
    cp -r vim_download/Python-3.8.12 .
fi
cd Python-3.8.12
./configure --prefix=/usr/local --with-openssl=/root/openssl --enable-shared
make -j 20
make install
cd -
update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.8 2
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1
rm /usr/bin/lsb_release

#vim
rm -rf vim
#apt-get install -y libncurses5-dev libgnome2-dev libgnomeui-dev libgtk2.0-dev libatk1.0-dev \
#    libbonoboui2-dev libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev python3-dev ruby-dev lua5.1 liblua5.1-dev libperl-dev --allow-unauthenticated
apt-get install -y libncurses5-dev libbonoboui2-dev --allow-unauthenticated
if [ ! -d "vim_download" ];then
    git clone https://github.com/vim/vim.git
else
    cp -r vim_download/vim .
fi
cd vim
git checkout v8.2.4897
./configure --with-features=huge \
	--enable-multibyte \
	--enable-rubyinterp=yes \
	--enable-python3interp=yes \
	--enable-perlinterp=yes \
	--enable-luainterp=yes \
	--prefix=/usr/local
make -j 20
make install
cd -

#vundle
if [ ! -d "vim_download" ];then
    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
cp vimrcs/vundle.vimrc ~/.vimrc
vim +PluginInstall -c quitall

#vim-go
cp vimrcs/vim-go.vimrc ~/.vimrc
vim +PluginInstall -c quitall
vim +GoInstallBinaries -c quitall

#ycm clone
pip3 install future
cp vimrcs/ycm.vimrc ~/.vimrc
vim +PluginInstall -c quitall
if [ ! -d "vim_download" ];then
    cd ~/.vim/bundle/YouCompleteMe
    git submodule update --init --recursive
    cd -
else
    mkdir -pv ~/.vim/bundle/YouCompleteMe/third_party/ycmd/clang_archives
    cp vim_download/libclang-8.0.0-x86_64-unknown-linux-gnu.tar.bz2 ~/.vim/bundle/YouCompleteMe/third_party/ycmd/clang_archives/libclang-8.0.0-x86_64-unknown-linux-gnu.tar.bz2
fi

#ycm install
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --gocode-completer --clang-completer
cd -

#for taglist
apt-get install -y ctags --allow-unauthenticated

#for leetcode.vim
pip3 install pynvim

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
pip install compdb
            
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
apt-get install -y bear --allow-unauthenticated

#for snippets
mkdir -pv ~/.vim/UltiSnips
cp snippets/all.snippets ~/.vim/UltiSnips/
