set -x
set -e

dircolors -p > ~/.dir_colors
echo "alias ls='ls -F --show-control-chars --color=auto'
eval \`dircolors -b ~/.dir_colors\`" >> ~/.bashrc

echo "export PS1='\[\e]0;\u@\h: \w\a\]\${debian_chroot:+(\$debian_chroot)}\u@\h:\w\\$ '" >> ~/.bashrc
echo "需要手动调用'hostname 机器ip'，来指定显示名称"