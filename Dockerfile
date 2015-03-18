FROM ubuntu:14.04.2

MAINTAINER Thierry Corbin <thierry.corbin@kauden.fr>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y upgrade

RUN apt-get -y install supervisor \
    nginx \
    php5 \
    php5-fpm \
    php5-gd \
    php5-cli \
    php5-mcrypt \
    php5-mysql \
    php5-imap \
    php5-curl \
    php-pear \
    libapr1 \
    libaprutil1

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

ADD asset/pydio /etc/nginx/sites-enabled/pydio
ADD asset/pydio-core-6.0.5.tar.gz /usr/share/nginx/
ADD asset/supervisord.conf /opt/supervisord.conf

RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
    rm -f /etc/nginx/sites-enabled/default && \
    rm -rf /usr/share/nginx/html && \
    mv /usr/share/nginx/pydio-core-6.0.5 /usr/share/nginx/html && \
    chown www-data:www-data /usr/share/nginx/html -R && \
    mkdir /data /data/files /data/personal && \
    chown www-data:www-data /data -R

RUN php5enmod mcrypt \
    php5enmod imap

RUN sed -i '/^file_uploads = /c file_uploads = On' /etc/php5/fpm/php.ini && \
    sed -i '/^post_max_size = /c post_max_size = 20G' /etc/php5/fpm/php.ini && \
    sed -i '/^upload_max_filesize = /c upload_max_filesize = 20G' /etc/php5/fpm/php.ini && \
    sed -i '/^max_file_uploads = /c max_file_uploads = 20000' /etc/php5/fpm/php.ini && \
    sed -i '/^output_buffering = /c output_buffering = Off' /etc/php5/fpm/php.ini && \
    sed -i '/daemonize /c daemonize = no' /etc/php5/fpm/php-fpm.conf && \
    sed -i 's/AJXP_DATA_PATH/\/data/g' /usr/share/nginx/html/conf/bootstrap_repositories.php && \
    echo 'define("AJXP_LOCALE", "fr_FR.UTF-8");' >> /usr/share/nginx/html/conf/bootstrap_conf.php

RUN pear install Mail_mimeDecode \
    pear install HTTP_WebDAV_Client \
    pear install VersionControl_Git-0.4.4 \
    pear install HTTP_OAuth-0.3.1

VOLUME /data

EXPOSE 80

CMD /usr/bin/supervisord -c /opt/supervisord.conf
