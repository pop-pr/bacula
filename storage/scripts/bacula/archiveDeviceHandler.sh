#!/bin/bash

#### Creates Bacula archive device directory, expects to be called by Ansible, but can be callled manually

test_arg()
{   
    local retval=1
    if [ -d $1 ]; then
        echo "Path is already a directory"        
    else 
        retval=0
    fi
    return $retval    
}

create_dir()
{   
    mkdir -p $arg     
}

assure_perms()
{
    chown bacula:bacula $arg
}

main()
{   local passed=0
    for arg in $@; do
        test_arg $arg
        passed=$?
        if [ $passed -eq 0 ]; then
            create_dir $arg
            assure_perms $arg
        fi
        shift 1 
    done 
    exit 0 
}
main $@