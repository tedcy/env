apt-get install -y language-pack-zh-hans
echo 'LANG="zh_CN.UTF-8"
LANGUAGE="zh_CN:zh:en_US:en"' >> /etc/environment

echo 'en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8
zh_CN.GBK GBK
zh_CN GB2312' >> /var/lib/locales/supported.d/local

echo 'set meta-flag on
set convert-meta off
set input-meta on
set output-meta on' >> ~/.inputrc

echo 'if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi' >> ~/.profile

locale-gen
