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
last_id=$(ls /usr/lib/systemd/system/rsync_ramfs*.service 2>/dev/null | awk -F '[_\.]' '{print $(NF-1)}' | sort -n | tail -n1)

# If no existing service files, start from 1, otherwise increment the last ID
if [[ -z $last_id ]]; then
    id=1
else
    id=$((last_id + 1))
fi

# Service file path
service_file="/usr/lib/systemd/system/rsync_ramfs$id.service"

# Create the service file
cat > $service_file <<EOF
[Unit]
Description=rsync_ramfs$id

[Service]
ExecStart=bash -c '$script_dir/rsync_ramfs.sh $source_path $backup_path'
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd manager configuration
systemctl daemon-reload
# Start the new service
service rsync_ramfs$id restart
