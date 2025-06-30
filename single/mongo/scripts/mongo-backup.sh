#!/bin/bash

# Rotate backups older than 7 days inside the container
docker exec 2b find /tmp -maxdepth 1 -type d -name 'mongodump-*' -mtime +7 -exec rm -rf {} \;

# Load environment variables from .env file
source /opt/dedalus/docker/test/mongo/env/mongo.env

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/tmp/mongodump-$TIMESTAMP"

docker exec 2b mongodump --host ivd-ais-docker-env-1-0-ais-poc.awsnet.ivdarch.cloud --port 27017 -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --out /tmp/mongodump-$TIMESTAMP

################################################################################################

# Edit the crontab with:
crontab -e

# Then add the following line:
0 17 * * * /opt/dedalus/docker/test/mongo_backup.sh >> /tmp/mongo_backup.log 2>&1