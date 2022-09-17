set -x
set -e

dircolors -p > ~/.dir_colors
cat bash/bashrc >> ~/.bashrc
echo "需要手动调用'hostname 机器ip'，来指定显示名称"
echo "如果xshell没有设置，需要添加配色（工具-配色方案-导入-solarized.dark.xcs），打开真彩色（选项-高级-使用本色）"
echo "如果不能输入中文，需要调用set_locale.sh"
