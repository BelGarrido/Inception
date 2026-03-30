#!/bin/bash

# create the folder is doesnt exist
#mkdir -p /etc/nginx/ssl

if [ ! -f /var/www/html/wp-login.php ]; then
    cp -r /tmp/wordpress/. /var/www/html/
    cp -r /tmp/wp-config.php /var/www/html
fi
chown -R www-data:www-data /var/www/html/
chmod +x /usr/local/bin/setup.sh
#chown -R www-data:www-data /var/log/php8.2-fpm.log

# Execute the main command of nginx
exec "$@"
