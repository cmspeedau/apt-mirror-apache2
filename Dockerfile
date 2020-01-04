FROM ubuntu:18.04

RUN \
  apt update && \
  apt install -y apt-mirror apache2 && \
  apt autoremove -y && apt clean

ENV DEBIAN_FRONTEND noninteractive
ENV TIMEOUT 12h
ENV MIRROR_URL http://archive.ubuntu.com/ubuntu
ENV NTHREADS 10
ENV PUID 1000
ENV PGID 1000

RUN mkdir -p /var/www/html/ubuntu

RUN rm -f /var/run/apache2/apache2.pid
EXPOSE 80

COPY setup.sh /setup.sh

VOLUME ["/var/www/html/"]
CMD ["/bin/bash", "setup.sh"]
