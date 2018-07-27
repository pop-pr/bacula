#!/bin/bash

main(){
    echo "Reloading bacula_dir config files..."
    local retval=1
    echo 'reload' | bconsole && retval=0
    echo "done!"
    return $retval
}
main