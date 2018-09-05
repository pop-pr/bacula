#!/bin/bash

main(){
    echo "Reloading bacula-sd service..."
    local retval=1
    bacula-sd -t 
    service bacula-sd restart && retval=0    
    echo "done!"
    return $retval
}
main