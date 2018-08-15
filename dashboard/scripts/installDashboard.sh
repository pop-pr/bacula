#!/bin/bash

# Installs BACULA WEB DASHBOARD SERVICE

DASHBOARD_DIR="bdashboard"
WEB_DIR="/var/www/html/"
BACULA_SCRIPT_DIR="/usr/src/bacula/scripts/"
APACHE_SITES='/etc/apache2/sites-available/'
DASHBOARD_GZ="dashboard.gz"
TEMPLATES="dashboard_files"


if [ -d $WEB_DIR$DASHBOARD_DIR ]; then
    echo "Dashboard already installed"
    exit 0
fi

cd "$BACULA_SCRIPT_DIR"

if [ ! -d "bdashboard" ]; then
    tar xvzf $TEMPLATES/$DASHBOARD_GZ    
    chown -R www-data.www-data $DASHBOARD_DIR
    chmod 775 "/etc/bacula"        
    cp "$TEMPLATES/config.php" "$DASHBOARD_DIR/application/config/"    
    a2enmod rewrite  
    adduser www-data bacula
    mv "$BACULA_SCRIPT_DIR$DASHBOARD_DIR" $WEB_DIR
    service apache2 restart
    echo "Done"
fi