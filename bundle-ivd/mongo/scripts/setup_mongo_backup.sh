#!/bin/bash

# Define the backup script content
BACKUP_SCRIPT="/opt/dedalus/docker/bundles/mongo/scripts/mongo_backup.sh"
BACKUP_SCRIPT_CONTENT='#!/bin/bash

HOST_BACKUP_DIR="/opt/dedalus/docker/backups"
CONTAINER_NAME="stage-mongo-1"
HOST_NAME="ivd-ais-docker-env-1-0-deployment-test.awsnet.ivdarch.cloud"

# Rotate backups older than 7 days inside the container
docker exec "$CONTAINER_NAME" find /tmp -maxdepth 1 -type d -name "mongodump-*" -mtime +7 -exec rm -rf {} \;

# Load environment variables from .env file
source /opt/dedalus/docker/bundles/mongo/environments/stage/env/compose.env

# Generate timestamped backup directory name
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/tmp/mongodump-$TIMESTAMP"

# Run mongodump inside the container
docker exec "$CONTAINER_NAME" mongodump --host "$HOST_NAME" --port 27017 -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --out "$BACKUP_DIR"

# Copy the backup from the container to the host
docker cp "$CONTAINER_NAME":"$BACKUP_DIR" "$HOST_BACKUP_DIR/"

# Remove the temporary backup directory from the container
docker exec "$CONTAINER_NAME" rm -rf "$BACKUP_DIR"
'

# Create the backup script
echo "$BACKUP_SCRIPT_CONTENT" > "$BACKUP_SCRIPT"

# Make the backup script executable
chmod +x "$BACKUP_SCRIPT"

# Define the cron job
CRON_JOB="0 17 * * * /opt/dedalus/docker/bundles/mongo/scripts/mongo_backup.sh >> /tmp/mongo_backup.log 2>&1"

# Append the cron job to the crontab (avoiding duplicates)
(crontab -l 2>/dev/null | grep -v "$BACKUP_SCRIPT" ; echo "$CRON_JOB") | crontab -

echo "Mongo backup script created, made executable, and cron job scheduled."