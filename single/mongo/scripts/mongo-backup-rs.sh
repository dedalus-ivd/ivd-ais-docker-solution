



################################################################################################

# Edit the crontab with:
crontab -e

# Then add the following line:
* 17 * * * docker exec pbm-agent pbm backup
* 18 * * * find /opt/dedalus/docker/test/mongo/backups -mindepth 1 -mtime +7 -exec rm -rf {} \;