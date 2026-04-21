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

# Start MariaDB temporarily in background to run bootstrap SQL.
mysqld_safe --datadir='/var/lib/mysql' &

# Wait until MariaDB accepts connections.
while ! mariadb-admin ping --silent; do
    sleep 1
done

# Create application database from environment variable.
mariadb -u root -e "CREATE DATABASE $MARIADB_DATABASE;"

# Create application user (if missing) and grant DB privileges.
mariadb -u root -e "CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';"
mariadb -u root -e "GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%';"
mariadb -u root -e "FLUSH PRIVILEGES;"

# Exit client session and stop temporary bootstrap server.
mariadb -e EXIT;

mariadb-admin -u root shutdown

echo "MariaDB ready to execute final process"
# Wait until background MariaDB fully stops before final exec.
while [ -f /var/run/mysqld/mysqld.pid ]; do
   sleep 1
done

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