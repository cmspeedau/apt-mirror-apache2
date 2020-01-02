# apt-mirror-http-server

Using Docker to construct your APT(Advanced Packaging Tools) mirror HTTP server.

## Usage
### Basic command:

```
docker run -d \
           -v /path/data:/var/www/html/ubuntu \
           -p 8080:80 kongkrit/apt-mirror-http-server
```

* `-v /path/data`: the path which you want to store data


### More options with docker command

* `-e MIRROR_URL=url`: to replace default URL (http://archive.ubuntu.com/ubuntu) - See [Ubuntu Mirrors](https://launchpad.net/ubuntu/+archivemirrors)
* `-e RESYNC_PERIOD=timeout-value`: to set the resync period, default is 12 hours. To set the [TIMEOUT format description](http://www.cyberciti.biz/faq/linux-unix-sleep-bash-scripting/)

## Changelog

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
