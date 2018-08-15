#!/bin/bash

# Installs WEBACULA WEB SERVICE

DASHBOARD_DIR="bdashborad"
WEB_DIR="/var/www/html/"
BACULA_SCRIPT_DIR="/usr/src/bacula/scripts/"
APACHE_SITES='/etc/apache2/sites-available/'
DASHBOARD_GZ="dashboard.gz"
TEMPLATES="dashboard_files"


if [ -d $WEB_DIR$WEBACULA_DIR ]; then
    echo "Dashboard already installed"
    exit 0
fi

cd "$BACULA_SCRIPT_DIR"

if [ ! -d "bdashboard" ]; then
    tar xvzf $TEMPLATES/$DASHBOARD_GZ
    # mv webacula-7.5.3 $DASHBOARD_DIR
    chown -R www-data.www-data $DASHBOARD_DIR
    chmod 775 "/etc/bacula"
    chmod 7777 "$DASHBOARD_DIR/data/cache"
    # cp "$TEMPLATES/php.ini" /etc/php/7.0/apache2/
    cp "$TEMPLATES/config.php" "$DASHBOARD_DIR/application/config/"
    # cp "$TEMPLATES/webacula.conf" $APACHE_SITES
    a2enmod rewrite
    cd $APACHE_SITES && a2ensite webacula.conf
    adduser www-data bacula    
    mv "$BACULA_SCRIPT_DIR$DASHBOARD_DIR" $WEB_DIR
    service apache2 restart
    echo "Done"
fi