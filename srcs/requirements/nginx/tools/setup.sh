#!/bin/bash

# Create SSL directory if it does not already exist.
mkdir -p /etc/nginx/ssl

# Build a domain value from USER, with a safe fallback when USER is missing.
DOMAIN="$DOMAIN_NAME"

# Replace domain placeholder in Nginx config using USER from environment.
sed -i "s/SERVER_NAME_PLACEHOLDER/${DOMAIN}/g" /etc/nginx/conf.d/default.conf

# Generate a self-signed certificate and private key for HTTPS.
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=ES/ST=Malaga/L=Malaga/O=42School/OU=Inception/CN=${DOMAIN}"

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
# - Injects the computed DOMAIN into default.conf.
# - Creates a self-signed cert/key pair for local HTTPS.
# - Launches the final container command with exec "$@" as PID 1.
#
# Notes:
# - Certificate CN now matches the same DOMAIN used in server_name.
# - Fallback domain is inception.42.fr when USER is not defined.
