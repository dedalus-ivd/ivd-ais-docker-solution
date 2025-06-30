#!/bin/bash

# Define variables
SRC_DIR="/opt/dedalus/docker/test"
DEST_DIR="/opt/dedalus/backups/configuration"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="backup_$TIMESTAMP.tar.gz"

# Create backup directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Create a compressed archive, excluding specific folders
tar --exclude="$SRC_DIR/data" --exclude="$SRC_DIR/backups" -czf "$DEST_DIR/$BACKUP_NAME" -C "$SRC_DIR" .

# Delete backups older than 7 days
find "$DEST_DIR" -name "backup_*.tar.gz" -type f -mtime +7 -exec rm -f {} \;