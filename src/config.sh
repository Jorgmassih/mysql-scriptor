#!/bin/bash

if [ ! -e $MYSQL_CLIENT_CONFIG ]; then
    echo "Creating Mysql client config..."
    echo "[client]" >> $MYSQL_CLIENT_CONFIG
    echo "user=${MYSQL_USER:-root}" >> $MYSQL_CLIENT_CONFIG
    if [ ${PROMPT_PASSWORDS:-no} == 'yes' ]; then
        echo -n "Insert password: "
        read -s password
        echo "password=$password" >> $MYSQL_CLIENT_CONFIG
    else
        echo "password=$MYSQL_PASSWORD" >> $MYSQL_CLIENT_CONFIG
    fi
    echo "host=${MYSQL_HOST:-mysql}" >> $MYSQL_CLIENT_CONFIG
    echo "port=${MYSQL_PORT:-3306}" >> $MYSQL_CLIENT_CONFIG
    echo "protocol=${MYSQL_PROTOCOL:-TCP}" >> $MYSQL_CLIENT_CONFIG
    echo "connect_timeout=5" >> $MYSQL_CLIENT_CONFIG	# 5 seconds
else
    echo "Mysql client config already exists. Skiping..."
fi