#!/bin/bash

LOCK="entrypoint.lock"
SRC_DIR="/usr/src/bacula"
BACULA_DIR="/etc/bacula"
CP="/bin/cp -Rf"
CHWON="/bin/chown -R"

start_process()
{
    echo "Starting processes..."
    /etc/init.d/bacula-fd start 
    /etc/init.d/bacula-sd start 
    /etc/init.d/bacula-director start     
    /etc/init.d/ssh start 
    /etc/init.d/apache2 start    
    echo "Done!"
}

test_bacula()
{
    local result=1
    local retval=1
    echo 'reload' | bconsole && result=0
    if [ $result -eq 0 ]; then
        retval=0    
    fi
    return $retval
}

test_lock()
{
    local retval=1
    if [ -f "$BACULA_DIR/$LOCK" ]; then
        echo "Entrypoint Script already runned"
        retval=0
    fi
    return $retval   
}

create_lock()
{
    # $1 == result from copy_file function
    local result=1
    if [ $1 -eq 0 ]; then              
        echo "Creating lock file.."
        touch "$BACULA_DIR/$LOCK" && result=0
        if [ $result -eq 0 ]; then
            echo "Done!"
        else
            echo "Something went wrong while creating lock file"
            exit 1
        fi        
    fi    
}

change_perms()
{
    $CHWON bacula:bacula $BACULA_DIR
}

copy_files()
{
    local result=1
    if [ -d $SRC_DIR ]; then                
        $CP $SRC_DIR/* $BACULA_DIR/ && result=0
    fi    
    return $result 
}

main()
{
    test_lock
    local lock=$?    
    if [ $lock -eq 0 ]; then
        start_process
        test_bacula    
        exit 0
    fi
    copy_files    
    local result=$?    
    create_lock $result            
    change_perms
    start_process
    test_bacula
    local test=$?    
    if [ $test -eq 1 ]; then        
        echo 'Failed'
        exit 1
    fi
    echo "Entrypoint Finished"    
    exit 0
}
main