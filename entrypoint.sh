#!/bin/bash

# Exit on any error
set -e

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting Squid proxy with authentication..."

# Check if username and password are provided
if [ -z "$SQUID_USERNAME" ] || [ -z "$SQUID_PASSWORD" ]; then
    log "ERROR: Both SQUID_USERNAME and SQUID_PASSWORD environment variables must be set"
    log "Example: docker run -e SQUID_USERNAME=myuser -e SQUID_PASSWORD=mypass squid-proxy"
    exit 1
fi

log "Setting up authentication for user: $SQUID_USERNAME"

# Create htpasswd file with the provided credentials
if ! htpasswd -cb /etc/squid/auth/htpasswd "$SQUID_USERNAME" "$SQUID_PASSWORD"; then
    log "ERROR: Failed to create htpasswd file"
    exit 1
fi

# Set proper permissions
chmod 640 /etc/squid/auth/htpasswd
chown squid:squid /etc/squid/auth/htpasswd

log "Authentication file created successfully"

# Initialize squid cache if it doesn't exist
if [ ! -d "/var/cache/squid/00" ]; then
    log "Initializing Squid cache directory..."
    squid -z
fi

# Ensure proper ownership of cache and log directories
chown -R squid:squid /var/cache/squid /var/log/squid

log "Testing Squid configuration..."
if ! squid -k parse; then
    log "ERROR: Squid configuration is invalid"
    exit 1
fi

log "Configuration is valid. Starting Squid..."

# Start squid in foreground mode
exec squid -N