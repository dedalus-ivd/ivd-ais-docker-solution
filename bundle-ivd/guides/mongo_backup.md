### Mongo Backup and Restore - Manual

Use the following commands to perform backups and restores on a standalone MongoDB instance running inside a Docker container. These examples assume authentication is enabled and the backup is stored in /tmp.

- Replace CONTAINER_NAME_OR_ID, HOSTNAME, USERNAME, PASSWORD, and the date as needed.
- Use the --drop option during restore if you want to overwrite existing collections.

#### Backup from the host environment
```bash
docker exec CONTAINER_NAME_OR_ID mongodump --host HOSTNAME --port 27017 -u USERNAME -p PASSWORD --authenticationDatabase admin --out /tmp/mongodump-$(date +%Y%m%d_%H%M%S)
```

#### Backup from inside the container environment
```bash
mongodump --host HOSTNAME --port 27017 -u USERNAME -p PASSWORD --authenticationDatabase admin --out /tmp/mongodump-$(date +%Y%m%d_%H%M%S)
```

#### Restore from the host environment
```bash
docker exec CONTAINER_NAME_OR_ID mongorestore --host HOSTNAME --port 27017 -u USERNAME -p PASSWORD --authenticationDatabase admin /tmp/mongodump-TIMESTAMP
```

#### Restore from inside the container environment
```bash
mongorestore --host HOSTNAME --port 27017 -u USERNAME -p PASSWORD --authenticationDatabase admin /tmp/mongodump-TIMESTAMP
```

### Mongo Backup and Restore - Automated

The below steps describes how to automate MongoDB backups inside a Docker container, with automatic deletion of backups older than 7 days.

#### Step 1: Create the Backup Script
Create a file named mongo_backup.sh with the following content:
```bash
#!/bin/bash

# Rotate backups older than 7 days inside the container
docker exec CONTAINER_NAME_OR_ID find /tmp -maxdepth 1 -type d -name 'mongodump-*' -mtime +7 -exec rm -rf {} \;

# Load environment variables from .env file
source /opt/dedalus/docker/test/mongo/env/mongo.env

# Generate timestamped backup directory name
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/tmp/mongodump-$TIMESTAMP"

# Run mongodump inside the container
docker exec CONTAINER_NAME_OR_ID mongodump --host HOSTNAME --port 27017 -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --out "$BACKUP_DIR"
```

#### Step 2: Make the Script Executable
```bash
chmod +x /opt/dedalus/docker/test/mongo_backup.sh
```

#### Step 3: Schedule the Cron Job
Edit the crontab using:
```bash
crontab -e
```
Add the following line to run the backup every day at 5 PM, and log the output to a file:
```bash
0 17 * * * /opt/dedalus/docker/test/mongo_backup.sh >> /tmp/mongo_backup.log 2>&1
```