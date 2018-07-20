#!/bin/bash


LOCK="entrypoint.lock"
SRC_DIR="/usr/src/bacula"
BACULA_DIR="/etc/bacula"

start_process()
{
    echo "Starting processes"
    /etc/init.d/bacula-director start 
    /etc/init.d/bacula-fd start 
    /etc/init.d/bacula-sd start 
    /etc/init.d/ssh start 
    /etc/init.d/apache2 start 
    bconsole
}

if [ -f "$BACULA_DIR/$LOCK" ]; then
    echo "Entrypoint Script already runned"
    start_process    
    exit 0
fi

if [ -d $SRC_DIR ]; then
    cp -rf "$SRC_DIR/" "$BACULA_DIR/"
    if [ -t $? ]; then
        echo "creating lock_file"
        touch "$BACULA_DIR/$LOCK"
        echo "$BACULA_DIR/$LOCK"
    fi    
    start_process
fi
echo "Entrypoint Finished"
exit 0