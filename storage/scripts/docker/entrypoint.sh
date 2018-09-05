#!/bin/bash

LOCK="entrypoint.lock"
SRC_DIR="/usr/src/bacula"
BACULA_DIR="/etc/bacula"
CP="/bin/cp -Rf"
CHWON="/bin/chown -R"
BACULA_LOG="/var/log/bacula/bacula.log"

test_bacula_conf()
{   local retval=1
    bacula-sd -t && retval=0
    return $retval
}

start_process()
{
    local retval=test_bacula_conf
    if [ $retval -eq 0 ]; then
        echo "Starting processes..."    
        /etc/init.d/bacula-sd start     
        echo "Done!"    
    else
        echo "There is a problem with bacula configuration, please review bacula-sd.conf file or run the ansible storage recipe"
    fi
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

console_log()
{
    echo "Entrypoint Finished"
    echo "Creating log file..."
    touch $BACULA_LOG
    chown bacula:bacula $BACULA_LOG    
    echo "Reading bacula messages"    
}

main()
{    
    test_lock
    local lock=$?        
    if [ $lock -eq 0 ]; then
        start_process    
        console_log                
    else    
        copy_files    
        local result=$?    
        create_lock $result            
        change_perms
        start_process    
        local test=$?    
        if [ $test -eq 1 ]; then        
            echo 'Failed'
            exit 1
        fi            
        console_log
    fi
}
main
exec "$@"