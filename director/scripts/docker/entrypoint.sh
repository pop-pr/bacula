#!/bin/bash

LOCK="entrypoint.lock"
SRC_DIR="/usr/src/bacula"
BACULA_DIR="/etc/bacula"
CP="/bin/cp -Rf"
CHWON="/bin/chown -R"
BACULA_LOG="/var/log/bacula/bacula.log"

test_mysql_conn()
{
    while ! mysqladmin ping -h "catalog" --silent; do
        sleep 1
    done  
    return
}

start_process()
{
    echo "Starting processes..."
    /etc/init.d/bacula-fd start 
    /etc/init.d/bacula-sd start 
    /etc/init.d/bacula-director start              
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

console_log()
{
    echo "Entrypoint Finished"
    echo "Creating log file..."
    touch $BACULA_LOG
    chown bacula:bacula $BACULA_LOG    
    echo "Reading bacula messages"
    echo "LOG START" >> $BACULA_LOG        
}

main()
{
    test_mysql_conn
    test_lock
    local lock=$?        
    if [ $lock -eq 0 ]; then
        start_process
        test_bacula
        console_log                
    else    
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
        console_log
    fi
}
main
exec "$@"