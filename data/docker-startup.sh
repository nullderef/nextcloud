#!/bin/bash

chown -R www-data:www-data /nextcloud/config && chmod -R 777 /nextcloud/config

export HTTP_PORT=80
if [[ ! -z $HTTP_WEB_PORT ]]; then
    export HTTP_PORT=$HTTP_WEB_PORT
fi

export ALIAS_STRING=
if [[ ! -z $HTTP_ALIAS ]]; then
    export ALIAS_STRING="Alias $HTTP_ALIAS /nextcloud/nextcloud"
fi

sed -i "s/HTTP_PORT/$HTTP_PORT/g" "/etc/apache2/sites-available/default.conf"
sed -i "s:ALIAS_STRING:$ALIAS_STRING:g" "/etc/apache2/sites-available/default.conf"

service apache2 start

