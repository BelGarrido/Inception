#!/bin/bash

# create the folder is doesnt exist
#mkdir -p /etc/nginx/ssl

# 1. Wait for MariaDB to be ready
while ! mysqladmin -h$WORDPRESS_DB_HOST -u$WORDPRESS_DB_USER -p$WORDPRESS_DB_PASSWORD ping ; do
    sleep 1
done

# 2. Only run setup if WordPress is not already installed
if [ ! -f /var/www/html/wp-config.php ]; then

    # 3. Copy WordPress files to the web root
    cp -r /tmp/wordpress/. /var/www/html/

    # 4. Create wp-config.php using WP-CLI
    cd /var/www/html
    wp config create --dbname=$WORDPRESS_DB_NAME --dbhost=$WORDPRESS_DB_HOST --dbuser=$WORDPRESS_DB_USER --dbpass=$WORDPRESS_DB_PASSWORD --extra-php --allow-root <<PHP
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
PHP
    # 5. Install WordPress core using WP-CLI
    wp core install --url=$DOMAIN_NAME --title=$WORDPRESS_TITLE --admin_user=$WORDPRESS_ADMIN_USER --admin_password=$WORDPRESS_ADMIN_PASSWORD --admin_email=$WORDPRESS_ADMIN_EMAIL --allow-root
    wp user create $WORDPRESS_USER $WORDPRESS_USER_EMAIL --user_pass=$WORDPRESS_USER_PASSWORD --allow-root --path=/var/www/html
    #wp theme install astra --lente --allow-root --path=/var/www/html || true
fi


# Execute the main command of wp
exec "$@"
