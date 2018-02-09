#!/bin/bash

if [ -z ${WORKINGDIR+x} ]; then WORKINGDIR="/var/www/html"; export WORKINGDIR; fi
if [ -z ${WORKINGUSER+x} ]; then WORKINGUSER="www-data"; export WORKINGUSER; fi
if [ -z ${WORKINGGROUP+x} ]; then WORKINGGROUP="www-data"; export WORKINGGROUP; fi

if [ -z ${WWW_UID+x} ]; then WWW_UID="$(id -u $WORKINGUSER)"; export WWW_UID; fi
if [ -z ${WWW_GID+x} ]; then WWW_GID="$(id -g $WORKINGGROUP)"; export WWW_GID; fi

if [ ! -z ${SMTP_HOST+x} ] && [ ! -z ${SMTP_FROM+x} ] && [ ! -z ${SMTP_PASS+x} ]; then
    j2 /templates/msmtprc.j2 > /etc/msmtprc
fi

cd $WORKINGDIR
composer global require "fxp/composer-asset-plugin:1.3.1"
composer install --prefer-dist
npm install
npm run build

if [ ! -f $WORKINGDIR/config/config.json ]; then
    touch $WORKINGDIR/config/INSTALLING
fi

chown -R $WORKINGUSER:$WORKINGGROUP $WORKINGDIR
