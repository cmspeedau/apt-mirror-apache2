#!/bin/bash

TARGETFILE="/etc/apt/mirror.list"

echo "configuring [$TARGETFILE] MIRROR_URL=[$MIRROR_URL]"
echo "  DIST1=[$DIST1] DIST2=[$DIST2] DIST3=[$DIST3]"

echo "#### config ####
set base_path /var/www/html/
set nthreads $NTHREADS
set _tilde 0" \
> "$TARGETFILE"

if [[ ! -z "$DIST1" ]]; then
echo "# for release $DIST1
$ARCH $MIRROR_URL $DIST1 main restricted universe multiverse
$ARCH $MIRROR_URL $DIST1-updates main restricted universe multiverse
$ARCH $MIRROR_URL $DIST1-backports main restricted universe multiverse
$ARCH $MIRROR_URL $DIST1-security main restricted universe multiverse
$ARCH $MIRROR_URL $DIST1-proposed main restricted universe multiverse" >> "$TARGETFILE"
fi

if [[ ! -z "$DIST2" ]]; then
echo "# for release $DIST2
$ARCH $MIRROR_URL $DIST2 main restricted universe multiverse
$ARCH $MIRROR_URL $DIST2-updates main restricted universe multiverse
$ARCH $MIRROR_URL $DIST2-backports main restricted universe multiverse
$ARCH $MIRROR_URL $DIST2-security main restricted universe multiverse
$ARCH $MIRROR_URL $DIST2-proposed main restricted universe multiverse" >> "$TARGETFILE"
fi

if [[ ! -z "$DIST3" ]]; then
echo "# for release $DIST3
$ARCH $MIRROR_URL $DIST3 main restricted universe multiverse
$ARCH $MIRROR_URL $DIST3-updates main restricted universe multiverse
$ARCH $MIRROR_URL $DIST3-backports main restricted universe multiverse
$ARCH $MIRROR_URL $DIST3-security main restricted universe multiverse
$ARCH $MIRROR_URL $DIST3-proposed main restricted universe multiverse" >> "$TARGETFILE"
fi

echo "# for EXTRAS
$EXTRA1
$EXTRA2
$EXTRA3
$EXTRA4
$EXTRA5

clean $MIRROR_URL" >> "$TARGETFILE"

echo "content of [$TARGETFILE] is..."
echo "-------------------------------------"
cat "$TARGETFILE" |sed -E "s~^(.*)$~>>> \1~g"
echo "-------------------------------------"

echo

rm -f /var/run/apache2/apache2.pid

echo "hacking www-data and apt-mirror to become PUID=$PUID PGID=$PGID"
SEDEX="s~(www-data|apt-mirror):x:[0-9]+:[0-9]+:~\1:x:${PUID}:${PGID}:~g"
sed -Ei "$SEDEX" /etc/passwd
echo "regex: $SEDEX"
echo "-------------------------------------"
grep -E '(www-data|apt-mirror)' /etc/passwd |sed -E "s~^(.*)$~>>> \1~g"
echo "-------------------------------------"

echo

echo "adding server name"
echo $'\nServerName apt-mirror' >> /etc/apache2/apache2.conf
echo "-------------------------------------"
grep -E 'ServerName' /etc/apache2/apache2.conf |sed -E "s~^(.*)$~>>> \1~g"
echo "-------------------------------------"

echo

echo "changing default site document root to $WEB_ROOT"
SEDEX="s~DocumentRoot\s+\/var\/www\/html\s*$~DocumentRoot \/var\/www\/html${WEB_ROOT}~"
sed -Ei "$SEDEX" /etc/apache2/sites-available/000-default.conf
echo "regex: $SEDEX"
echo "-------------------------------------"
grep -E 'DocumentRoot' /etc/apache2/sites-available/000-default.conf |sed -E "s~^(.*)$~>>> \1~g"
echo "-------------------------------------"

echo

echo "if no postmirror.sh then create and set to call clean.sh"
mkdir -p /var/www/html/var;
if [[ ! -f /var/www/html/var/postmirror.sh ]]; then
  echo $'#!/bin/bash\ncd "${0%/*}"\necho "$(pwd)/clean.sh"\nsleep 5\n$(pwd)/clean.sh\n' > /var/www/html/var/postmirror.sh; fi
echo "-------------------------------------"
cat /var/www/html/var/postmirror.sh |sed -E "s~^(.*)$~>>> \1~g"
echo "-------------------------------------"

echo

echo "Changing ownership of all files on /var/www/html to apt-mirror"
chown -R apt-mirror:apt-mirror /var/www/html

echo

echo "starting apache server"
service apache2 start
echo "apache started..."

echo "TIMEOUT is ${TIMEOUT}"
while true; do
    echo "[$(date)] Starting apt-mirror"
    apt-mirror
    #sleep 60
    echo "[$(date)] Completed"
    echo "[$(date)] Sleeping $TIMEOUT to execute apt-mirror again ======"
    sleep "$TIMEOUT"
done
