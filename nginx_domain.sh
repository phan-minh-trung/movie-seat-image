#!/bin/bash

# How to run
# `sudo ./nginx_domain.sh localhost {pull_request_id}` or without and
# the script will prompt the user for input

#config
web_root='/srv'
config_dir='/etc/nginx'

if [ -z "$1" ]
then
    #user input
    echo -e "Enter domain name:"
    read DOMAIN
    echo "Creating Nginx domain settings for: $DOMAIN"

    if [ -z "$DOMAIN" ]
    then
        echo "Domain required"
        exit 1
    fi
fi

if [ -z "$DOMAIN" ]
then
    DOMAIN=$1
fi

if [ -n "$2" ]
then
    PULL_REQUEST_ID=$2
fi

(
cat <<EOF
server {
    listen   80 default_server; ## listen for ipv4; this line is default and implied
    #listen   [::]:80 default_server ipv6only=on; ## listen for ipv6

    root $web_root/$DOMAIN/public;
    index index.php index.html index.htm;

    # Make site accessible from http://localhost/
    server_name _;

    location / {
        # First attempt to serve request as file, then
        # as directory, then fall back to displaying a 404.
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;

        # With php7.0-cgi alone:
        # fastcgi_pass 127.0.0.1:9000;

        # With php7.0-fpm:
        fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    }
    location ~ /\.ht {
        deny all;
    }

    access_log $web_root/$DOMAIN/log/access_log.txt;
    error_log $web_root/$DOMAIN/log/error_log.txt error;
}
EOF
) >  $config_dir/sites-available/default

echo "############ Making web directories ############"
mkdir -p $web_root/"$DOMAIN"

echo "############ Clone source from github ############"
cd $web_root
git clone https://c6315be5e2fe51fab096c1ebab7d4995867b3d60@github.com/phan-minh-trung/movie-seat.git "$DOMAIN"

# Checkout source from pull request
cd $web_root/"$DOMAIN"
git fetch --tags --progress https://c6315be5e2fe51fab096c1ebab7d4995867b3d60@github.com/phan-minh-trung/movie-seat.git \
    +refs/pull/*:refs/remotes/origin/pr/*
git checkout -b test origin/pr/"$PULL_REQUEST_ID"/merge

echo "############ Run composer install ############"
cd $web_root/"$DOMAIN"

echo "- Copy vendor folder from cache"
cp -r /srv/vendor .

echo "- Composer install"
composer install

echo "- Auto generate cipher key"
php artisan key:generate

echo "- Config environment, database from /srv/.env"
cp /srv/.env .

echo "- Create log files"
mkdir -p $web_root/"$DOMAIN"/log
touch $web_root/"$DOMAIN"/log/access_log.txt
touch $web_root/"$DOMAIN"/log/error_log.txt
echo "############ End - Run composer install ############"

# Back to root folder
cd
# ln -s $config_dir/sites-available/"$DOMAIN".conf $config_dir/sites-enabled/"$DOMAIN".conf
# ln -s $config_dir/sites-available/default.conf $config_dir/sites-enabled/default.conf
/etc/init.d/nginx restart
echo "############ Nginx - restarted ############"

/etc/init.d/mysql start
echo "############ Mysql - started ############"

chown -R www-data:www-data $web_root/"$DOMAIN"
chmod 755 $web_root/"$DOMAIN"/public
echo "Permissions have been set"
echo "$DOMAIN has been setup"
