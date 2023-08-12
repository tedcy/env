Path=$1
backup_Path=$2

set -x

/usr/bin/inotifywait -mrq --format '%w%f' -e create,close_write,MODIFY,MOVED_FROM,MOVED_TO $Path  | while read line  
do
    if [ -f $line ];then
        # Get relative path of the file from the source directory
        relative_path=${line#$Path}

        # Create the directories in the target location
        mkdir -p "$backup_Path/$(dirname "$relative_path")"

        rsync -avz $line --exclude-from=/ramfs/ServerLess/.gitignore \
        --include='*.sh' --include='*.cpp' --include='*.h' --include='*.hpp' \
        --include='*.c' --include='*/' --exclude='*' "$backup_Path/$relative_path"
    else
        cd $Path
        rsync -avz ./ --exclude-from=/ramfs/ServerLess/.gitignore \
        --include='*.sh' --include='*.cpp' --include='*.h' --include='*.hpp' \
        --include='*.c' --include='*/' --exclude='*' $backup_Path
    fi
done
