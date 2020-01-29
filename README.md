# apt-mirror-apache2

Using Docker to construct your APT(Advanced Packaging Tools) mirror HTTP server.

## Usage
### Basic command:

```
docker run -d \
           -v /path/data:/var/www/html/ \
           -p 8080:80 kongkrit/apt-mirror-apache2
```

* `-v /path/data`: the path which you want to store data

### More options with docker command

* `-e MIRROR_URL=url`: to replace default URL (http://archive.ubuntu.com/ubuntu) - See [Ubuntu Mirrors](https://launchpad.net/ubuntu/+archivemirrors)
* `-e EXTRA1=text`: to add more repo to mirror - for example:
  ```-e EXTRA1="deb http://ppa.launchpad.net/jonathonf/zfs/ubuntu bionic main"``` will add this extra line to the list file
* `-e EXTRA2, EXTRA3, EXTRA4, EXTRA5`: same as EXTRA1
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

## Changelog
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
