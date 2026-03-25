#!/bin/bash

# create the folder is doesnt exist
mkdir -p /etc/nginx/ssl

#<sed -i "s/SERVER_NAME_PLACEHOLDER/${USER}.42.fr/g" /etc/nginx/conf.d/default.conf

# creates a certificate only if there's none
# if [ ! -f /etc/nginx/ssl/inception.crt ]; then
#     openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
#         -keyout /etc/nginx/ssl/inception.key \
#         -out /etc/nginx/ssl/inception.crt \
#         -subj "/C=ES/ST=Malaga/L=Malaga/O=42School/OU=Inception/CN=anagarri.42.fr"
# fi

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=ES/ST=Malaga/L=Malaga/O=42School/OU=Inception/CN=anagarri.42.fr"


# Execute the main command of nginx
exec "$@"
