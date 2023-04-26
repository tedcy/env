set -x
set -e

#./install_go.sh

envPath='/root/env'
buildPath=$envPath/'build'

rm -rf $buildPath
mkdir -pv $buildPath

sudo chmod 1777 /tmp

#git updated to newest to support git pull update submodule
sudo add-apt-repository ppa:git-core/ppa -y
sudo apt update
sudo apt install git -y
sudo git config --global submodule.recurse true
sudo git config --global submodule.ignore dirty
sudo git config --global diff.ignoreSubmodules dirty
# git免http用户名密码
# echo -n 'https://<user>:<pass>@github.com' >> ~/.git-credentials
# git config --global credential.helper store

if [ ! `which wget` ];then
    apt-get install -y wget --allow-unauthenticated
fi

if [ ! `which gcc` ];then
    apt-get install -y build-essential cmake --allow-unauthenticated
fi

rm -rf ~/.vim/bundle/*
mkdir -pv ~/.vim/bundle

cp -r vimrcs $buildPath
if [ -f "vim_download.tar.gz" ];then
    if ! grep -q "file:///" $buildPath/vimrcs/final.vimrc;then
        sed -i "s:Plugin.*/:Plugin 'file\:///root/.vim/bundle/:" `find $buildPath/vimrcs -name "*.vimrc"`
    fi
    if [ ! -d "vim_download" ];then
        tar xzf vim_download.tar.gz
    fi
    cp -r vim_download/* ~/.vim/bundle/
fi

git config --global http.sslVerify false
#git config --global url."https://".insteadOf git://

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

if [ ! -d "vim_download" ];then
    wget https://www.openssl.org/source/openssl-1.1.1d.tar.gz
    tar xzf openssl-1.1.1d.tar.gz
    rm -rf openssl-1.1.1d.tar.gz
else
    cp -r vim_download/openssl-1.1.1d $buildPath
fi
cd $buildPath/openssl-1.1.1d
./config --prefix=$buildPath/openssl --openssldir=$buildPath/openssl
make -j 20
make install
cd $envPath
echo $buildPath"/openssl/lib/" >> /etc/ld.so.conf
ldconfig

apt-get install -y libffi-dev zlib1g-dev libbz2-dev --allow-unauthenticated
if [ ! -d "vim_download" ];then
    wget https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tar.xz
    tar xzf Python-3.8.12.tar.xz
    rm -rf Python-3.8.12.tar.xz
else
    cp -r vim_download/Python-3.8.12 $buildPath
fi
cd $buildPath/Python-3.8.12
./configure --prefix=/usr/local --with-openssl=$buildPath/openssl --enable-shared
make -j 20
make install
cd $envPath
update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.8 2
if [ -f "/usr/bin/python3.5" ];then
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1
fi
#rm -f /usr/bin/lsb_release

#vim
#apt-get install -y libncurses5-dev libgnome2-dev libgnomeui-dev libgtk2.0-dev libatk1.0-dev \
#    libbonoboui2-dev libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev python3-dev ruby-dev lua5.1 liblua5.1-dev libperl-dev --allow-unauthenticated
apt-get install -y libncurses5-dev libbonoboui2-dev --allow-unauthenticated
if [ ! -d "vim_download" ];then
    git clone https://github.com/vim/vim.git $buildPath/vim
else
    cp -r vim_download/vim $buildPath/vim
fi
cd $buildPath/vim
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
cd $envPath

#vundle
if [ ! -d "vim_download" ];then
    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    cp $buildPath/vimrcs/vundle.vimrc ~/.vimrc
    vim +PluginInstall -c quitall
fi

#vim-go
cp $buildPath/vimrcs/vim-go.vimrc ~/.vimrc
if [ ! -d "vim_download" ];then
    vim +PluginInstall -c quitall
fi
vim +GoInstallBinaries -c quitall

#ycm clone

#YCMVersion="default"
#YCMVersion="2022_8_18"
YCMVersion="c++11_last"

apt-get install -y software-properties-common lsb-core --allow-unauthenticated
if [ -f "/usr/bin/python3.5" ];then
    if ! grep -q "python3.5" /usr/bin/add-apt-repository;then
        sed -i "s:python3:python3.5:" /usr/bin/add-apt-repository
        sed -i "s:python3:python3.5:" /usr/bin/lsb_release
    fi
else
    if [ -f "/usr/bin/python3.8" ];then
        if ! grep -q "python3.8" /usr/bin/add-apt-repository;then
            sed -i "s:python3:python3.8:" /usr/bin/add-apt-repository
            sed -i "s:python3:python3.8:" /usr/bin/lsb_release
        fi
    fi
fi
for i in {1...10}
do
    pip3 install future | true
done
cp -r ~/.vim/bundle/YouCompleteMe_$YCMVersion ~/.vim/bundle/YouCompleteMe
cp $buildPath/vimrcs/ycm.vimrc ~/.vimrc
if [ ! -d "vim_download" ];then
    vim +PluginInstall -c quitall
    cd ~/.vim/bundle/YouCompleteMe
    git submodule update --init --recursive
    cd $envPath
fi

#ycm install
cd ~/.vim/bundle/YouCompleteMe
if [ `which go` ];then
    #go_completer="--gocode-completer"
    go_completer=""
fi
if [ "$YCMVersion" == "default" ];then
    if [ -d "vim_download" ];then
        mkdir -pv ~/.vim/bundle/YouCompleteMe/third_party/ycmd/clang_archives
        cp vim_download/YouCompleteMe_$YCMVersion/libclang* ~/.vim/bundle/YouCompleteMe/third_party/ycmd/clang_archives/
    fi
    python3 install.py --clang-completer $go_completer
    echo "/root/.vim/bundle/YouCompleteMe/third_party/ycmd/third_party/clang/lib" >> /etc/ld.so.conf
    ldconfig
fi
if [ "$YCMVersion" == "c++11_last" ];then
    add-apt-repository -y ppa:ubuntu-toolchain-r/test | true
    apt-get update | true
    apt-get install -y g++-8
    cd $envPath/vim_download
    tar xzf cmake-3.16.8-Linux-x86_64.tar.gz
    cd -

    CXX=g++-8 EXTRA_CMAKE_ARGS='-DPATH_TO_LLVM_ROOT=/root/.vim/bundle/YouCompleteMe/clang+llvm-10.0.0-x86_64-unknown-linux-gnu' python3 install.py \
        --clang-completer --system-libclang --cmake-path=$envPath'/vim_download/cmake-3.16.8-Linux-x86_64/bin/cmake' $go_completer
    echo "/root/.vim/bundle/YouCompleteMe/clang+llvm-10.0.0-x86_64-unknown-linux-gnu/lib" >> /etc/ld.so.conf
    ldconfig
fi
if [ "$YCMVersion" == "2022_8_18" ];then
    #经过测试，2022_8_18无法在ubuntu16.04上使用
    #如果在ubuntu20.04使用的话用clangd，并设置ycm_clangd_binary_path，可以解锁GoToSymbol

    #mkdir -pv ~/.vim/bundle/YouCompleteMe/third_party/ycmd/clang_archives
    #cp vim_download/YouCompleteMe_$YCMVersion/libclang* ~/.vim/bundle/YouCompleteMe/third_party/ycmd/clang_archives/
    #CXX=g++-8 python3 install.py --clang-completer --force-sudo --verbose $go_completer
    #echo "/root/.vim/bundle/YouCompleteMe/third_party/ycmd/third_party/clang/lib" >> /etc/ld.so.conf
    #ldconfig
    mkdir -pv /root/.vim/bundle/YouCompleteMe/third_party/ycmd/third_party/clangd/cache
    cp clangd/clangd-14.0.0-x86_64-unknown-linux-gnu.tar.bz2 /root/.vim/bundle/YouCompleteMe/third_party/ycmd/third_party/clangd/cache/
    python3 install.py --clangd-completer --force-sudo --verbose --cmake-path=$envPath'/vim_download/cmake-3.16.8-Linux-x86_64/bin/cmake' $go_completer
    #echo "let ycm_clangd_binary_path = '/root/.vim/bundle/YouCompleteMe/clang+llvm-14.0.0-x86_64-unknown-linux-gnu/bin/clangd'" >> $buildPath/vimrcs/final.vimrc
    mkdir -pv /root/.config/clangd/
    echo 'CompileFlags:
      Remove: [-Werror]' > /root/.config/clangd/config.yaml
fi
cd $envPath

#for taglist
apt-get install -y ctags --allow-unauthenticated

#for leetcode.vim
pip3 install pynvim | true

#other install
if [ ! -d "vim_download" ];then
    cp $buildPath/vimrcs/other.vimrc ~/.vimrc                  
    vim +PluginInstall -c quitall                   
fi

#cp .ycm_extra_conf.py
cp ycm_extra_conf.py ~/.ycm_extra_conf.py       
       
#final vimrc
cp $buildPath/vimrcs/final.vimrc ~/.vimrc
            
#for cmake completion
#https://github.com/Sarcasm/compdb#generate-a-compilation-database-with-header-files
#compdb -p build/ list > compile_commands.json  
pip3 install compdb | true
            
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

#for gperftools
apt-get install -y google-perftools google-perftools-devel libunwind8 libunwind-dev --allow-unauthenticated
if [ ! -d "~/FlameGraph" ];then
    if [ ! -d "vim_download" ];then
        git clone https://github.com/brendangregg/FlameGraph -o ~/FlameGraph
    else
        cp -r vim_download/FlameGraph ~/
    fi
fi

#for perf
apt-get install -y linux-tools-$(uname -r) linux-tools-generic --allow-unauthenticated

echo "记得bash/set_shell.sh来设置shell"
