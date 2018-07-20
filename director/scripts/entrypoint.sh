#!/bin/bash


LOCK="entrypoint.lock"
SRC_DIR="/usr/src/bacula"
BACULA_DIR="/etc/bacula"

if [ -f "$BACULA_DIR$LOCK" ]; then
    echo "Entrypoint Script already runned"
    exit 0
fi

if [ -d $SRC_DIR ]; then
    cp -rf $SRC_DIR $BACULA_DIR
    if [ -t $? ]; then
        touch $BACULA_DIR$LOCK
    fi
    echo "Entrypoint Finished"
fi