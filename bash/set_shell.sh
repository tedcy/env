set -x
set -e

dircolors -p > ~/.dir_colors
cat bash/bashrc >> ~/.bashrc

locale-gen en_US.UTF-8

echo 'if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi' >> ~/.profile

echo 'set meta-flag on
set convert-meta off
set input-meta on
set output-meta on' >> ~/.inputrc

echo "需要手动调用'hostname 机器ip'，来指定显示名称"
echo "如果xshell没有设置，需要添加配色（工具-配色方案-导入-solarized.dark.xcs），打开真彩色（选项-高级-使用本色）"
