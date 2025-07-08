#!/bin/bash

# Paths
BACKUP_SCRIPT="/opt/dedalus/docker/bundles/configuration_backup.sh"
BACKUP_DIR="/opt/dedalus/docker/backups"
SOURCE_DIR="/opt/dedalus/docker/bundles"
LOG_FILE="/tmp/configuration_backup.log"

cat << EOF > "$BACKUP_SCRIPT"
#!/bin/bash

TIMESTAMP=\$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="/opt/dedalus/docker/backups/config_backup_\${TIMESTAMP}.tar.gz"

# Create tar.gz excluding 'data' and 'backup'
tar --exclude="data" --exclude="backup" -czf "\$BACKUP_FILE" -C "/opt/dedalus/docker/bundles" .

# Delete backups older than 7 days
find /opt/dedalus/docker/backups -type f -name "config_backup_*.tar.gz" -mtime +7 -exec rm -f {} \;
EOF

# 2. Make the backup script executable
chmod +x "$BACKUP_SCRIPT"

# 3. Define and add the cron job
CRON_JOB="* * * * * $BACKUP_SCRIPT >> $LOG_FILE 2>&1"

# Append the cron job to the crontab (avoiding duplicates)
(crontab -l 2>/dev/null | grep -v "$BACKUP_SCRIPT"; echo "$CRON_JOB") | crontab -

echo "✅ Backup script created and scheduled daily at 5PM."