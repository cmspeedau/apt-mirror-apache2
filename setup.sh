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

echo "hacking www-data to become PUID=$PUID PGID=$PGID"
SEDEX="s/www-data:x:[0-9]+:[0-9]+:/www-data:x:${PUID}:${PGID}:/g"
echo "sed /etc/passwd with [$SEDEX]"
cat /etc/passwd | \
sed -E $SEDEX > /tmp/passy
cp /tmp/passy /etc/passwd
rm /tmp/passy

echo "starting apache server"
service apache2 start
echo "apache started..."

echo "TIMEOUT is ${TIMEOUT}"
while true; do
    echo "[$(date)] Starting apt-mirror"
    apt-mirror
    echo "[$(date)] Completed"
    echo "[$(date)] Sleeping $TIMEOUT to execute apt-mirror again ======"
    sleep "$TIMEOUT"
done
