#!/bin/bash

# Wait for MariaDB to be ready before running any WP-CLI setup.
while ! mysqladmin -h$WORDPRESS_DB_HOST -u$WORDPRESS_DB_USER -p$WORDPRESS_DB_PASSWORD ping ; do
    sleep 1
done

# Run initialization only on first startup.
if [ ! -f /var/www/html/wp-config.php ]; then

    # Copy WordPress source files into the shared web root.
    cp -r /tmp/wordpress/. /var/www/html/

    # Generate wp-config.php with DB values from environment variables.
    cd /var/www/html
    wp config create --dbname=$WORDPRESS_DB_NAME --dbhost=$WORDPRESS_DB_HOST --dbuser=$WORDPRESS_DB_USER --dbpass=$WORDPRESS_DB_PASSWORD --extra-php --allow-root <<PHP
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
PHP

    # Install WordPress core and create the regular application user.
    wp core install --url=$DOMAIN_NAME --title=$WORDPRESS_TITLE --admin_user=$WORDPRESS_ADMIN_USER --admin_password=$WORDPRESS_ADMIN_PASSWORD --admin_email=$WORDPRESS_ADMIN_EMAIL --allow-root
    wp user create $WORDPRESS_USER $WORDPRESS_USER_EMAIL --user_pass=$WORDPRESS_USER_PASSWORD --allow-root --path=/var/www/html
    #wp theme install astra --lente --allow-root --path=/var/www/html || true
fi

# Hand off to the container's final command (php-fpm).
exec "$@"

# -----------------------------------------------------------------------------
# WordPress setup script summary:
# -----------------------------------------------------------------------------
# Purpose:
# - Wait for MariaDB availability before WordPress bootstrap.
# - Perform one-time WordPress installation using WP-CLI.
# - Execute the final container command as the main process.
#
# Why conditional install:
# - Existing wp-config.php indicates the site is already initialized.
# - Prevents overwriting an existing WordPress installation on restart.
#
# Related files:
# - Runtime WordPress constants are defined in conf/wp-config.php.
# - PHP-FPM pool/runtime behavior is configured in conf/www.conf and conf/php-fpm.conf.
