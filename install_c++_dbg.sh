
rm -rf /etc/apt/sources.list.d/ddebs.list

#https://wiki.ubuntu.com/Debug%20Symbol%20Packages
echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse
deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse
deb http://ddebs.ubuntu.com $(lsb_release -cs)-proposed main restricted universe multiverse" | \
tee -a /etc/apt/sources.list.d/ddebs.list
apt install ubuntu-dbgsym-keyring
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F2EDC64DC5AEE1F6B9C621F0C8CAB6595FDFF622
apt-get update

#https://stackoverflow.com/questions/64893723/how-to-install-libstdc6-debug-symbols-on-ubuntu-20-04
echo "如何选择std++和c++ dbg版本
~# dpkg --list | grep libstdc++
libstdc++6:amd64 10.3.0-1ubuntu1~20.04 amd64 GNU Standard C++ Library v3
是libstdc++6，所以install libstdc++6-dbgsym
同样的
~# dpkg --list | grep libc++
libc++1-10:amd64 1:10.0.0-4ubuntu1 amd64 LLVM C++ Standard library
是libc++1-10，所以install libc++1-10-dbgsym"

apt-get install libc++1-10-dbgsym
apt-get install libstdc++6-dbgsym

echo "如果想要安装什么包但是因为最新版依赖冲突装不上
apt list --all-versions package_name
apt install package_name=package_version
例如:
~# apt list --all-versions openssh-server-dbgsym
Listing... Done
openssh-server-dbgsym/focal-proposed 1:8.2p1-4ubuntu0.6 amd64
openssh-server-dbgsym/focal-updates 1:8.2p1-4ubuntu0.5 amd64
openssh-server-dbgsym/focal 1:8.2p1-4 amd64
~# apt install openssh-server-dbgsym=1:8.2p1-4ubuntu0.5"
