set -x
set -e

dircolors -p > ~/.dir_colors
echo "alias ls='ls -F --show-control-chars --color=auto'
eval \`dircolors -b ~/.dir_colors\`" >> ~/.bashrc

echo "export PS1='\[\e]0;\u@\h: \w\a\]\${debian_chroot:+(\$debian_chroot)}\u@\h:\w\\$ '" >> ~/.bashrc
echo "alias gg='g++ -std=c++11 -o out.exe -g -pthread'" >> ~/.bashrc
echo "alias ggd='g++ -std=c++11 -o out.exe -g -pthread -D LOG_TAG'" >> ~/.bashrc
echo "alias gpush='git add -u && git commit -m '1' && git pull -r && git push'" >> ~/.bashrc
echo "需要手动调用'hostname 机器ip'，来指定显示名称"
