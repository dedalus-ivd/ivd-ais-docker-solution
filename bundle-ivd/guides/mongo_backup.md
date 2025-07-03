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

#### Step 1
Execute the file(setup_mongo_backup.sh) located in /opt/dedalus/docker/bundles/mongo/scripts:
```bash
chmod +x /opt/dedalus/docker/bundles/mongo/scripts/setup_mongo_backup.sh
```

#### Step 2
Run the script:
```bash
./opt/dedalus/docker/bundles/mongo/scripts/setup_mongo_backup.sh
```