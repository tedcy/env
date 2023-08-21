#!/bin/bash

set -e
set -x

# 检查cron是否已安装
if ! dpkg -s cron >/dev/null 2>&1; then
    echo "Cron is not installed. Installing..."
    apt-get install cron --allow-unauthenticated -y
fi

# 把规则添加到crontab
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/bin/find /tmp -type f -mtime +7 -delete") | crontab -