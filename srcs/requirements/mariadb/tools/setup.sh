#!/bin/bash

# Create required runtime and data directories.
mkdir -p /run/mysqld /var/lib/mysql
# Ensure MariaDB owns its runtime and data paths.
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Initialize system tables only on first container start.
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Installing database."
    # Prepare MariaDB internal system database.
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Generate SQL that MariaDB will execute at startup.
cat > /tmp/mariadb-init.sql <<EOF
CREATE DATABASE IF NOT EXISTS \`$MARIADB_DATABASE\`;
CREATE OR REPLACE USER '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASSWORD';
GRANT ALL PRIVILEGES ON \`$MARIADB_DATABASE\`.* TO '$MARIADB_USER'@'%';
FLUSH PRIVILEGES;
EOF

# Replace shell with final container command (PID 1).
exec "$@"

# -----------------------------------------------------------------------------
# MariaDB setup script summary:
# -----------------------------------------------------------------------------
# Purpose:
# - Initialize MariaDB data directory on first startup.
# - Create WordPress database and application user from environment variables.
# - Hand off to the final container command as PID 1.
#
# Why bootstrap in background first:
# - SQL initialization requires a running MariaDB instance.
# - Starting temporarily allows CREATE DATABASE/USER/GRANT before final launch.
#
# Related files:
# - Server runtime configuration lives in conf/50-server.cnf.
# - Container startup command is defined in the MariaDB Dockerfile.