FROM ubuntu
MAINTAINER phan-minh-trung@dmm.com

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV DEBIAN_FRONTEND noninteractive

# PHP 7
RUN apt-get update && apt-get install -y python-software-properties software-properties-common \
  && apt-add-repository ppa:ondrej/php && apt-get purge -y software-properties-common \
  && apt-get update \
  && apt-get install -y nginx php7.0 php7.0-fpm php7.0-cli php7.0-common libapache2-mod-php7.0 \
                        php7.0 php7.0-mysql php7.0-fpm php7.0-curl php7.0-gd php7.0-bz2 php7.0-mbstring php-xml supervisor \
  && echo "mysql-server mysql-server/root_password password" | debconf-set-selections \
  && echo "mysql-server mysql-server/root_password_again password" | debconf-set-selections \
  && apt install -y mysql-server \
  && apt-get clean

# Install Packages
RUN apt-get install -y curl sudo nano git zip

RUN mkdir -p /run/php
RUN mkdir -p /srv
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/7.0/fpm/php.ini
RUN echo 'fastcgi_read_timeout 7200s;' >> /etc/nginx/fastcgi_params
COPY php.ini /etc/php/7.0/fpm/php.ini
COPY xdebug.ini /etc/php/mods-available/xdebug.ini

# Nginx
# When add daemon off; can't restart,start nginx by service command
# Not need add daemon off;
# RUN { echo 'daemon off;'; cat /etc/nginx/nginx.conf; } > /tmp/nginx.conf && mv /tmp/nginx.conf /etc/nginx/nginx.conf

# Template vhost
# https://www.howtoforge.com/tutorial/installing-nginx-with-php7-fpm-and-mysql-on-ubuntu-16.04-lts-lemp/
COPY nginx-site.conf /etc/nginx/sites-available/default
COPY nginx_domain.sh /srv/nginx_domain.sh
RUN chmod +x /srv/nginx_domain.sh
COPY .env /srv/.env
ADD vendor /srv/vendor

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Composer
RUN php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/local/bin --filename=composer

#
EXPOSE 80
WORKDIR /srv
CMD ["/usr/bin/supervisord"]
