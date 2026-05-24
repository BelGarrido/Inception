# Base image used to build the Nginx container.
FROM debian:bookworm

# Install required runtime packages.
# - nginx: web server and reverse proxy.
# - openssl: generates self-signed TLS certificates at startup.
# - sed: replaces domain placeholder in Nginx config.
# - ca-certificates: ensures trusted CA bundle exists in the container.
# Clean apt lists after install to keep image size smaller.
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    openssl \
    sed \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy project server block configuration into Nginx conf.d.
COPY conf/default.conf /etc/nginx/conf.d/default.conf
# Copy startup script used by ENTRYPOINT.
COPY tools/setup.sh /usr/local/bin/setup.sh
# Make startup script executable.
# Remove default Debian site files to avoid config conflicts.
RUN chmod +x /usr/local/bin/setup.sh \
    && rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default

# Document container ports used by Nginx:
# - 80 for HTTP to HTTPS redirect.
# - 443 for HTTPS traffic.
EXPOSE 80 443

# Keep Nginx in foreground as PID 1.
CMD ["nginx", "-g", "daemon off;"]

# Run setup script first (certificate + domain injection), then exec CMD.
ENTRYPOINT ["/usr/local/bin/setup.sh"]

# -----------------------------------------------------------------------------
# Nginx Dockerfile summary:
# -----------------------------------------------------------------------------
# Purpose:
# - Build an Nginx image for web server functionality.
# - Install Nginx and required dependencies.
# - Load project-specific Nginx configuration.
#
# Startup model:
# - ENTRYPOINT runs setup.sh to generate TLS certs and inject domain into config.
# - CMD starts Nginx in foreground to keep container alive.

#
# Related files:
# - Runtime initialization: tools/setup.sh
# - Pool config: conf/default.conf
# 