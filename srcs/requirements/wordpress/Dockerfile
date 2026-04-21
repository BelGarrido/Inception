FROM debian:bookworm

# Prepare directories used by runtime setup.
RUN mkdir -p /var/www/html && mkdir -p /tmp

# Copy container entrypoint script that performs runtime WordPress bootstrap.
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Install PHP-FPM runtime and tools required for WordPress setup.
RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    curl \
    unzip \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*
    
# Download WordPress source archive and extract it under /tmp.
RUN curl https://wordpress.org/latest.zip -o /tmp/wordpress.zip \
    && unzip /tmp/wordpress.zip -d /tmp/

# Install WP-CLI in PATH for setup.sh usage.
RUN curl -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp
RUN chmod +x /usr/local/bin/wp

# Copy PHP-FPM pool and global configuration.
COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY ./conf/php-fpm.conf /etc/php/8.2/fpm/php-fpm.conf

EXPOSE 9000

# Keep php-fpm in foreground so container stays alive.
CMD ["/usr/sbin/php-fpm8.2",  "--nodaemonize", "--fpm-config", "/etc/php/8.2/fpm/php-fpm.conf"]

# Runtime initialization is handled here before php-fpm starts.
ENTRYPOINT ["/usr/local/bin/setup.sh"]

# -----------------------------------------------------------------------------
# Tips for Dockerfile workflow:
# -----------------------------------------------------------------------------
# - The Dockerfile should install packages and prepare image files only.
# - Runtime initialization with environment variables belongs in entrypoint scripts.
#
# Why use `-y` with apt:
# - It automatically answers "yes" to install prompts so builds do not block.
#
# About DEBIAN_FRONTEND=noninteractive:
# - Some packages open interactive configuration dialogs (debconf).
# - Setting this variable avoids interactive prompts in automated builds.
#
# Why `sudo` and `systemctl` are usually wrong in Dockerfiles:
# - Build steps run as root by default, so `sudo` is unnecessary.
# - Containers do not run a full init system during image build.
# - Service lifecycle is handled by CMD/ENTRYPOINT when the container starts.

# -----------------------------------------------------------------------------
# WordPress Dockerfile summary:
# -----------------------------------------------------------------------------
# Purpose:
# - Build a PHP-FPM image for WordPress runtime.
# - Install PHP, DB client tools, WordPress source, and WP-CLI.
# - Load project-specific PHP-FPM configuration.
#
# Startup model:
# - ENTRYPOINT runs setup.sh for runtime initialization.
# - CMD starts php-fpm in foreground mode as the main container process.
#
# Related files:
# - Runtime bootstrap: tools/setup.sh
# - Pool config: conf/www.conf
# - Global FPM config: conf/php-fpm.conf




