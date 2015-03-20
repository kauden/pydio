FROM centos:centos6

MAINTAINER Thierry Corbin <thierry.corbin@kauden.fr>

RUN yum install -y wget && \
    rpm -Uvh http://dl.ajaxplorer.info/repos/pydio-release-1-1.noarch.rpm && \
    wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && \
    wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm

RUN wget -q -O – http://www.atomicorp.com/installers/atomic | sh

RUN rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm && \
    yum -y update && \
    yum -y install httpd \
    php-mcrypt* \
    ImageMagick \
    ImageMagick-devel \
    ImageMagick-perl \
    gcc \
    cc \
    php-pecl-apc \
    php \
    php-mysql \
    php-cli \
    php-devel \
    php-gd \
    php-pecl-memcache \
    php-pspell \
    php-snmp \
    php-xmlrpc \
    php-xml \
    mysql \
    php-ioncube-loader \
    python-pip

ADD asset/bootstrap.json /etc/bootstrap.json
ADD asset/configure_php_modules.sh /etc/configure_php_modules.sh
ADD asset/pre_conf_pydio.sh /etc/pre_conf_pydio.sh
ADD asset/public.htaccess /etc/public.htaccess
ADD asset/pydio.conf /etc/pydio.conf
ADD asset/root.htaccess /etc/root.htaccess
ADD asset/supervisord.conf /etc/

RUN chmod +x /etc/pre_conf_pydio.sh && \
    chmod +x /etc/configure_php_modules.sh


# install some php modules
RUN /etc/configure_php_modules.sh

# fix lack of network file for mysql
RUN echo -e "NETWORKING=yes" > /etc/sysconfig/network

# install pydio
RUN yum install -y --disablerepo=pydio-testing pydio

# install supervisord
RUN pip install "pip>=1.4,<1.5" --upgrade && \
    pip install supervisor

# pre-configure pydio
RUN /etc/pre_conf_pydio.sh

RUN yum clean all

VOLUME ["/var/lib/pydio", "/var/cache/pydio"]

EXPOSE 80

CMD ["supervisord", "-n"]