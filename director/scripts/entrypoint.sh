#!/bin/bash

LOCK="entrypoint.lock"
SRC_DIR="/usr/src/bacula"
BACULA_DIR="/etc/bacula"
CP="cp --preserve --recursive --force --verbose"

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

test_lock()
{
    if [ -f "$BACULA_DIR/$LOCK" ]; then
        echo "Entrypoint Script already runned"
        start_process    
        exit 0
    fi  
}

main()
{
    test_lock
    if [ -d $SRC_DIR ]; then
        $CP "$SRC_DIR/*" "$BACULA_DIR/"
        if [ -t $? ]; then
            echo "creating lock_file"
            touch "$BACULA_DIR/$LOCK"
            echo "$BACULA_DIR/$LOCK"
        fi    
        start_process
    fi
    echo "Entrypoint Finished"
    exit 0
}
main
