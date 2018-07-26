#!/bin/bash

# Installs WEBACULA WEB SERVICE

WEBACULA_DIR="webacula"
WEB_DIR="/var/www/"
BACULA_SCRIPT_DIR="/etc/bacula/scripts/"
APACHE_SITES='/etc/apache2/sites-available/'
WEBACULA_GZ="7.5.3.tar.gz"
TEMPLATES="webacula_files"


if [ -d $WEB_DIR$WEBACULA_DIR ]; then
    echo "Webacula already installed"
    exit 0
fi

cd "$BACULA_SCRIPT_DIR"

if [ ! -d $WEBACULA_GZ ] && [ ! -d "webacula" ]; then
    tar xvzf $TEMPLATES/7.5.3.tar.gz
    mv webacula-7.5.3 $WEBACULA_DIR
    chown -R www-data.www-data $WEBACULA_DIR
    chmod 775 "/etc/bacula"
    chmod 7777 "$WEBACULA_DIR/data/cache"
    cp "$TEMPLATES/php.ini" /etc/php/7.0/apache2/
    cp "$TEMPLATES/config.ini" "$WEBACULA_DIR/application/"
    cp "$TEMPLATES/webacula.conf" $APACHE_SITES
    a2enmod rewrite
    cd $APACHE_SITES && a2ensite webacula.conf
    adduser www-data bacula    
    mv "$BACULA_SCRIPT_DIR$WEBACULA_DIR" $WEB_DIR
    service apache2 restart
    echo "Done"
fi