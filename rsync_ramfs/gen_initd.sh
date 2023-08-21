#!/bin/bash

# Check script arguments
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <source_path> <target_path>"
    exit 1
fi

source_path=$1
backup_path=$2

# Get the directory of the current script
script_dir=$(readlink -f $(dirname $0))

# Get the last ID from the existing service files
last_id=$(ls /etc/init.d/rsync_ramfs*.sh 2>/dev/null | awk -F '[_\.]' '{print $(NF-1)}' | sort -n | tail -n1)

# If no existing service files, start from 1, otherwise increment the last ID
if [[ -z $last_id ]]; then
    id=1
else
    id=$((last_id + 1))
fi

# Service file path
service_file="/etc/init.d/rsync_ramfs$id.sh"

# Create the service file
cat > $service_file <<EOF
start() {
    echo "Starting rsync_ramfs$id..."
    nohup $script_dir/rsync_ramfs.sh $source_path $backup_path start 2>&1 >> /dev/null &
}

stop() {
    echo "Stopping rsync_ramfs$id..."
    pkill -f "$script_dir/rsync_ramfs.sh $source_path $backup_path"
}

status() {
    if pgrep -f "$script_dir/rsync_ramfs.sh $source_path $backup_path" > /dev/null
    then
        echo "rsync_ramfs$id is running."
    else
        echo "rsync_ramfs$id is not running."
    fi
}

restart() {
    echo "Restarting rsync_ramfs$id..."
    stop
    start
}

delete() {
    echo "Enable deleting rsync to rsync_ramfs$id..."
    $script_dir/rsync_ramfs.sh $source_path $backup_path delete
}

EOF
cat >> $service_file <<'EOF'
case "$1" in
EOF
cat >> $service_file <<EOF
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        status
        ;;
    delete)
        delete
        ;;
    *)
        echo "Usage: /etc/init.d/rsync_ramfs$id.sh {start|stop|restart|status|delete}"
        exit 1
        ;;
esac

exit 0
EOF

chmod +x $service_file

update-rc.d rsync_ramfs$id.sh defaults 90
