#!/bin/bash

# Create SSL directory if it does not already exist.
mkdir -p /etc/nginx/ssl

# Replace domain placeholder in Nginx config using USER from environment.
sed -i "s/SERVER_NAME_PLACEHOLDER/${USER}.42.fr/g" /etc/nginx/conf.d/default.conf

# Generate a self-signed certificate and private key for HTTPS.
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=ES/ST=Malaga/L=Malaga/O=42School/OU=Inception/CN=anagarri.42.fr"

# Replace the current shell with the container main process (usually nginx).
exec "$@"

# -----------------------------------------------------------------------------
# Nginx setup script 
# -----------------------------------------------------------------------------
# Purpose:
# - Prepare TLS assets and dynamic server name before Nginx starts.
#
# What this script does:
# - Ensures /etc/nginx/ssl exists.
# - Injects ${USER}.42.fr into default.conf.
# - Creates a self-signed cert/key pair for local HTTPS.
# - Launches the final container command with exec "$@" as PID 1.
#
# Notes:
# - The certificate CN is currently hardcoded to anagarri.42.fr.
# - If you want per-user CN, make the -subj CN use ${USER}.42.fr as well.
