FROM debian:bookworm

# Use a neutral working directory for startup scripts.
# Avoid using /var/lib/mysql as WORKDIR because it is MariaDB data storage.
WORKDIR /usr/local/bin/

# Copy container startup script.
COPY tools/setup.sh .

# Ensure the entrypoint script can be executed.
RUN chmod +x /usr/local/bin/setup.sh

# Install MariaDB server packages in non-interactive mode.
# Keep only required packages and clear apt lists to reduce image size.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# Copy custom MariaDB server config after package installation.
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Create MariaDB runtime and log directories with proper ownership.
RUN mkdir -p /run/mysqld /var/run/mysqld /var/log/mysql \
    && chown -R mysql:mysql /run/mysqld /var/run/mysqld \
    && chmod 755 /run/mysqld /var/run/mysqld

EXPOSE 3306

# Default database process launched after setup.sh finishes bootstrap.
CMD ["mysqld_safe", "--init-file=/tmp/mariadb-init.sql"]

# Run initialization/bootstrap logic before launching MariaDB.
ENTRYPOINT ["./setup.sh"]

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

# -----------------------------------------------------------------------------
# MariaDB Dockerfile summary:
# -----------------------------------------------------------------------------
# Purpose:
# - Build a MariaDB image with project-specific server configuration.
# - Install MariaDB server and prepare runtime directories.
# - Delegate DB bootstrap and runtime initialization to setup.sh.
#
# Startup model:
# - ENTRYPOINT runs setup.sh for first-run database initialization.
# - CMD launches mysqld_safe as the main database process.
#
# Related files:
# - Runtime bootstrap: tools/setup.sh
# - Server config: conf/50-server.cnf
# - Service wiring and volumes: srcs/docker-compose.yml

