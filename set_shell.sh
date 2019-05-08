set -x
set -e

dircolors -p > ~/.dir_colors
echo "alias ls='ls -F --show-control-chars --color=auto'
eval \`dircolors -b ~/.dir_colors\`" >> ~/.bashrc
