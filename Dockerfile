FROM phusion/baseimage:0.9.22

LABEL org.label-schema.vcs-url="https://github.com/nullderef/nextcloud"

ENV NEXTCLOUD_FILE=nextcloud-13.0.0.zip

# Use baseimage-docker's init system.
CMD [ "/sbin/my_init" ]

RUN apt-get update -y

RUN apt-get install -y apache2 mariadb-server libapache2-mod-php7.0 \
    php7.0-gd php7.0-json php7.0-mysql php7.0-curl \
    php7.0-intl php7.0-mcrypt php-imagick \
    php7.0-zip php7.0-xml php7.0-mbstring \ 
    php-apcu php-redis redis-server \ 
    php7.0-ldap php-smbclient unzip \
    wget bzip2

COPY data/default.conf /etc/apache2/sites-available/

RUN a2dissite 000-default && a2enmod rewrite && a2ensite default

RUN echo "ServerName nextcloud" > /etc/apache2/conf-available/servername.conf && \
    a2enconf servername

RUN mkdir -p /nextcloud/nextcloud && \
    mkdir -p /nextcloud/logs && \ 
    mkdir -p /nextcloud/data && \ 
    mkdir -p /nextcloud/config

RUN wget --no-check-certificate https://download.nextcloud.com/server/releases/$NEXTCLOUD_FILE -P /root && \ 
    unzip /root/$NEXTCLOUD_FILE -d /nextcloud 

RUN rm -rf /nextcloud/nextcloud/config

RUN ln -s /nextcloud/config /nextcloud/nextcloud/config

RUN chown -R www-data:www-data /nextcloud && \ 
    chmod 777 /nextcloud/config

USER www-data

VOLUME [ "/nextcloud/config" ]

VOLUME [ "/nextcloud/data" ]

VOLUME [ "/nextcloud/logs" ]

USER root

RUN mkdir -p /etc/my_init.d
COPY data/docker-startup.sh /etc/my_init.d/docker-startup.sh
RUN chmod +x /etc/my_init.d/docker-startup.sh

EXPOSE 80/tcp

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/*
