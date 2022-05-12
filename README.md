# apt-mirror-apache2

Using Docker to construct your APT(Advanced Packaging Tools) mirror HTTP server.

## Usage
### Basic command:

```
docker run -d --restart always \
           -e TIMEOUT=4h -e PUID=1000 -e PGID=100 \
           -e MIRROR_URL=http://archive.ubuntu.com/ubuntu \
           -e EXTRA1="deb http://ppa.launchpad.net/jonathonf/zfs/ubuntu bionic main" \
           -e EXTRA2="deb http://ppa.launchpad.net/wireguard/wireguard/ubuntu bionic main" \
           -v /path/data:/var/www/html/ \
           --name apt-mirror \
           -p 81:80 kongkrit/apt-mirror-apache2
```

* `-v /path/data`: the path which you want to store data

### postmirror.sh and clean.sh
clean.sh is now automatically created by apt-mirror based on the MIRROR_URL (see below)
postmirror.sh - if not already existing, will be set to run clean.sh after the mirror update

### More options with docker command

* `-e MIRROR_URL=url`: to replace default URL (http://archive.ubuntu.com/ubuntu) - See [Ubuntu Mirrors](https://launchpad.net/ubuntu/+archivemirrors)
* `-e DIST1=bionic`: the release you want to mirror.
  *Default for `DIST1` is `bionic` (Ubuntu 18.04)*
* `-e DIST2=focal`: additional release you want to mirror. Set to blank ("") to skip.
  *Default for `DIST2` is `focal` (Ubuntu 20.04)*
* `-e DIST3=""`: additional release you want to mirror. Set to blank ("") to skip.
* `-e EXTRA1=text`: to add more repo to mirror - for example:
```
  -e EXTRA1="deb http://ppa.launchpad.net/jonathonf/zfs/ubuntu bionic main"
   will add this extra line to the mirror.list file
* `-e EXTRA2, EXTRA3, EXTRA4, EXTRA5`: same as EXTRA1
* `-e ARCH=deb`: can be changed to deb-amd64 or deb-i386 to narrow down the architecture of download
* `-e WEB_ROOT=/`: the apache2 server can be set to have a deeper web root like `/mirror/<mirror-web-address>/pub/` - end it with a slash 
* `-e TIMEOUT=timeout-value`: to set the resync period, default is 12 hours. See the [TIMEOUT format description](http://www.cyberciti.biz/faq/linux-unix-sleep-bash-scripting/)
* `-e NTHREADS=10`: number of wget threads to use to pull from MIRROR_URL - default to 10
* `-e PUID=userid`: set to a userid that can access the mounted volume (see note below)
* `-e PGID=groupid`: set to a groupid that can access the mounted volume (see note below)

### More on PUID and PGID from [linuxserver.io](https://hub.docker.com/r/linuxserver/duckdns)

When using volumes (-v flags), permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`. To find yours use id user as below:
```
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```
You only need to set the PUID and PGID variables if you are mounting the `/var/www/html` folder

## How to use the repos one you "mirrored" them (following "docker run" example above):
- I use X86_64 (amd64) architecture here, you may need to adjust your architecture, if you use a different CPU architecture.
- surf to `http://repo-server:81` (port is 81 in the docker run example above) and you'll see **Index of /**, click on `ubuntu` and click `mirror`, you will see `mirror.math.princeton.edu` and `ppa.launchpad.net`
- The idea is to add the URL that points all the way down to `ubuntu` where the contents will be `dists` and `pools` folders. And then, follow that with **release_name** **repo_lists** So, if the current `/etc/apt/sources.list` read like this:
```
deb http://mirror.math.princeton.edu/pub/ubuntu bionic main restricted universe multiverse
deb http://mirror.math.princeton.edu/pub/ubuntu bionic-updates main restricted universe multiverse
deb http://mirror.math.princeton.edu/pub/ubuntu bionic-backports main restricted universe multiverse
deb http://mirror.math.princeton.edu/pub/ubuntu bionic-security main restricted universe multiverse
```
  - Then the lines to add at the top of `/etc/apt/sources.list` are:
```
deb [arch=amd64] http://repo-server:81/ubuntu/mirror/mirror.math.princeton.edu/pub/ubuntu bionic main restricted universe multiverse
deb [arch=amd64] http://repo-server:81/ubuntu/mirror/mirror.math.princeton.edu/pub/ubuntu bionic-updates main restricted universe multiverse
deb [arch=amd64] http://repo-server:81/ubuntu/mirror/mirror.math.princeton.edu/pub/ubuntu bionic-backports main restricted universe multiverse
deb [arch=amd64] http://repo-server:81/ubuntu/mirror/mirror.math.princeton.edu/pub/ubuntu bionic-security main restricted universe multiverse
```
  - The current content of `/etc/apt/sources.list.d/jonathonf-ubuntu-zfs-bionic.list` is
```
deb http://ppa.launchpad.net/jonathonf/zfs/ubuntu bionic main
```
  - Then line to add at the top of `/etc/apt/sources.list.d/jonathonf-ubuntu-zfs-bionic.list` is:
```
deb [arch=amd64] http://repo-server:81/ubuntu/mirror/ppa.launchpad.net/jonathonf/zfs/ubuntu bionic main
```
  - repeat this for all the repos in EXTRA1..5

## Changelog
* 2021-05-12
  * Updated to Ubuntu focal
  
* 2020-01-31
  * support DIST1...3 for different releases

* 2020-01-29
  * support EXTRA1...5 parameters

* 2020-01-04
  * support PUID, PGID, and NTHREADS

* 2020-01-01
  * updated ubuntu to 18.04 LTS

* 2017-07-27: version 0.1.2
  * Fix the container started twice: "httpd (pid 13) already running"

* 2017-04-28: version 0.1.1
  * Fix http server doesn't start after the container restarted

* 2017-04-27: version 0.1
  * Update base image to Ubuntu 16.04
  * remove option `MIRROR_URL`
  * rename `TIMEOUT` environment value to `RESYNC_PERIOD`
  * fix issue [#1 https isn't handle correctly in setup.sh](https://github.com/seterrychen/apt-mirror-http-server/issues/1)
