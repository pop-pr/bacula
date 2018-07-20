#!/bin/bash

ENTRYPOINT_D="/docker-entrypoint.d/"
LOCK="entrypoint.lock"
SRC_DIR="/usr/src/bacula"
BACULA_DIR="/etc/bacula"

if [ -f "$ENTRYPOINT_D$LOCK" ]; then
    echo "Entrypoint Script already runned"
    exit 0
fi

if [ -d $SRC_DIR ]; then
    cp -rf $SRC_DIR $BACULA_DIR
    if [ -t $? ]; then
        touch $ENTRYPOINT_D$LOCK
    fi
    echo "Entrypoint Finished"
fi