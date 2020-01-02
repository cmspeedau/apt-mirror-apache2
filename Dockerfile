FROM ubuntu:18.04

RUN \
  apt update && \
  apt install -y apt-mirror apache2 && \
  apt autoremove -y && apt clean

ENV DEBIAN_FRONTEND noninteractive
ENV TIMEOUT 12h
#ENV REFRESH_HOURS 4
ENV MIRROR_URL http://archive.ubuntu.com/ubuntu
#ENV APACHE_RUN_DIR /var/www/html

#  mv /etc/apt/mirror.list / && \
#  rm -rf /var/lib/apt/lists/*

# RUN mkdir -p /var/www/html/ubuntu
RUN mkdir -p /var/www/html/ubuntu

RUN rm -f /var/run/apache2/apache2.pid
EXPOSE 80

COPY setup.sh /setup.sh
#CMD ["service", "apache2", "start"]
#RUN service apache2 start

#EXPOSE 80

#VOLUME ["/etc/apt", "/var/spool/apt-mirror"]
#CMD ["/bin/bash", "setup.sh"]
#CMD ["/bin/bash"]

VOLUME ["/var/www/html/ubuntu"]
CMD ["/bin/bash", "setup.sh"]
