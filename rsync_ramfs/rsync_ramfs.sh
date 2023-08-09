Path=$1
backup_Path=$2

/usr/bin/inotifywait -mrq --format '%w%f' -e create,close_write,delete $Path  | while read line  
do
    if [ -f $line ];then
        rsync -avz $line --exclude-from=/ramfs/ServerLess/.gitignore \
        --include='*.sh' --include='*.cpp' --include='*.h' --include='*.hpp' \
        --include='*.c' --include='*/' --exclude='*' --delete $backup_Path
    else
        cd $Path
        rsync -avz ./ --exclude-from=/ramfs/ServerLess/.gitignore \
        --include='*.sh' --include='*.cpp' --include='*.h' --include='*.hpp' \
        --include='*.c' --include='*/' --exclude='*' --delete $backup_Path
    fi
done
