FROM ubuntu:14.04.2
MAINTAINER Thierry Corbin <thierry.corbin@kauden.fr>

RUN echo 'deb http://download.videolan.org/pub/debian/stable/ /' >> /etc/apt/sources.list
RUN echo 'deb-src http://download.videolan.org/pub/debian/stable/ /' >> /etc/apt/sources.list
RUN echo 'deb http://archive.ubuntu.com/ubuntu trusty main multiverse' >> /etc/apt/sources.list

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && apt-get -y upgrade && apt-get -y install wget \
    supervisor

RUN wget -O - http://download.videolan.org/pub/debian/videolan-apt.asc|sudo apt-key add -

RUN apt-get update && apt-get -y install apache2 \
    php5 \
    php5-json \
    php5-curl \
    php5-mysqlnd \
    pwgen \
    lame \
    libvorbis-dev \
    vorbis-tools \
    flac \
    libmp3lame-dev \
    libavcodec-extra* \
    libfaac-dev \
    libtheora-dev \
    libvpx-dev \
    libav-tools

ADD https://github.com/ampache/ampache/archive/master.tar.gz /opt/master.tar.gz

# extraction / installation
RUN rm -rf /var/www/* && \
    tar -C /var/www -xf /opt/master.tar.gz ampache-master --strip=1 && \
    chown -R www-data /var/www

ADD asset/supervisord.conf /opt/supervisord.conf

# setup apache with default ampache vhost
ADD asset/001-ampache.conf /etc/apache2/sites-available/

RUN rm -rf /etc/apache2/sites-enabled/* && \
    ln -s /etc/apache2/sites-available/001-ampache.conf /etc/apache2/sites-enabled/ && \
    a2enmod rewrite

VOLUME ["/media", "/var/www/config", "/var/www/themes"]

EXPOSE 80

CMD /usr/bin/supervisord -c /opt/supervisord.conf