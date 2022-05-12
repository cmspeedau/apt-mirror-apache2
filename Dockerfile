FROM ubuntu:20.04

RUN \
  apt update && \
  apt install -y apt-mirror apache2 rsync && \
  apt autoremove -y && apt clean

ENV DEBIAN_FRONTEND noninteractive
ENV TIMEOUT 12h
ENV WEB_ROOT /
ENV MIRROR_URL http://archive.ubuntu.com/ubuntu
ENV DIST1 focal
ENV DIST2 ""
ENV DIST3 ""
ENV NTHREADS 10
ENV ARCH deb
ENV PUID 1000
ENV PGID 1000

RUN rm -f /var/run/apache2/apache2.pid

EXPOSE 80

COPY setup.sh /setup.sh

VOLUME ["/var/www/html/"]

CMD ["/bin/bash", "setup.sh"]
