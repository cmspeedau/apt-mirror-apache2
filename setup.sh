#!/bin/bash

TARGETFILE="/etc/apt/mirror.list"

echo "configuring [$TARGETFILE] MIRROR_URL=[$MIRROR_URL]"
echo "  DIST1=[$DIST1] DIST2=[$DIST2]"

echo "#### config ####
set base_path /var/www/html/ubuntu
set nthreads $NTHREADS
set _tilde 0" \
> "$TARGETFILE"

if [[ ! -z "$DIST1" ]]; then
echo "# for release $DIST1
deb $MIRROR_URL $DIST1 main restricted universe multiverse
deb $MIRROR_URL $DIST1-updates main restricted universe multiverse
deb $MIRROR_URL $DIST1-backports main restricted universe multiverse
deb $MIRROR_URL $DIST1-security main restricted universe multiverse
deb $MIRROR_URL $DIST1-proposed main restricted universe multiverse" >> "$TARGETFILE"
fi

if [[ ! -z "$DIST2" ]]; then
echo "# for release $DIST2
deb $MIRROR_URL $DIST2 main restricted universe multiverse
deb $MIRROR_URL $DIST2-updates main restricted universe multiverse
deb $MIRROR_URL $DIST2-backports main restricted universe multiverse
deb $MIRROR_URL $DIST2-security main restricted universe multiverse
deb $MIRROR_URL $DIST2-proposed main restricted universe multiverse" >> "$TARGETFILE"
fi

if [[ ! -z "$DIST3" ]]; then
echo "# for release $DIST3
deb $MIRROR_URL $DIST3 main restricted universe multiverse
deb $MIRROR_URL $DIST3-updates main restricted universe multiverse
deb $MIRROR_URL $DIST3-backports main restricted universe multiverse
deb $MIRROR_URL $DIST3-security main restricted universe multiverse
deb $MIRROR_URL $DIST3-proposed main restricted universe multiverse" >> "$TARGETFILE"
fi

echo "# for EXTRAS
$EXTRA1
$EXTRA2
$EXTRA3
$EXTRA4
$EXTRA5

#clean http://archive.ubuntu.com/ubuntu" >> "$TARGETFILE"

echo "content of [$TARGETFILE] is..."
echo "-------------------------------------"
cat "$TARGETFILE"
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
