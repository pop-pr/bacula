#!/bin/bash

main(){
    local retval=1
    echo 'exit' | bconsole && retval=0
    return $retval
}
main