#!/bin/bash

echo "configuring /etc/apt/mirror.list"
echo "#### config ####
set base_path /var/www/html/ubuntu
set nthreads 20
set _tilde 0

deb $MIRROR_URL bionic main restricted universe multiverse
deb $MIRROR_URL bionic-updates main restricted universe multiverse
deb $MIRROR_URL bionic-backports main restricted universe multiverse
deb $MIRROR_URL bionic-security main restricted universe multiverse

clean http://archive.ubuntu.com/ubuntu" \
> /etc/apt/mirror.list
echo "content of /etc/apt/mirror.list is..."
echo "-------------------------------------"
cat /etc/apt/mirror.list
echo "-------------------------------------"

rm -f /var/run/apache2/apache2.pid
echo "starting apache server"
service apache2 start

echo "apache started..."

while true; do
    echo "[$(date)] Starting apt-mirror"
    apt-mirror
    echo "[$(date)] Completed"
    echo "[$(date)] Sleeping $RESYNC_PERIOD to execute apt-mirror again ======"
    sleep "$RESYNC_PERIOD"
done
