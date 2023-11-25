#!/bin/bash
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# NOTES: 
# Before using Borg, obviously install it, and setup Borg Repos in the paths you want as target location for your Backups.
# Obviously (again): Adjust ALL paths, add/remove what you need or dont, adjust ENVs, commands, etc. Dont be a total idiot and just run code you copy pasted from the web.
# NOTE: YOU HAVE TO FIND ALL BIND MOUNT PATHS MANUALLY!!! THIS IS NOT AUTOMATED, IN CONTRAST TO VOLUMES! AND ONLY BACKUP WHAT YOU WANT, OTHERWISE YOU IDIOT WILL BACKUP YOUR WHOLE NAS WHEN YOU BIND IT TO PLEX!!
# THIS IS THE VERSION I PERSONALLY USE, I WILL UPLOAD A TEMPLATE VERSION LATER.
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# TODO - CHANGELOG:
# -Added Pruning
# -Fixed Pruning
# -Replaces global varibale for date with Borgs own {now} variable
# -Changed naming of Borg archives to DATE at end of name
# -Added important System Paths
# -Added /home/steven/docker bind mounts
# -Added lines for better structure and visibility
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# TODO - WIP:
# -Dump DB - Nextcloud
# -Dump DB - Monica
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# TODO - STILL TO DO:
# TODO - REPLACE PATHS WITH VARIABLES:
# BACKUP_DIR_VOLUMES=/BACKUP/Volumes
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DEFINE VARIABLES:
DATE=$(date +%Y-%m-%d)
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# SET ENVIRONMENT VARIABLES:
env ZSTD_CLEVEL=1
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# TUI:
echo "|----------| Script - Backup - Cosmos Cloud - Volumes & Bind Mounts with BORG to NAS-MAIN - V.0.2 - 2023 11 24 |----------|"
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# EXPORT - Paperless-Office 1:
echo "|----------> 1.1 Step: Exports from running Containers & Backup with BORG - Paperless - Office:"
sudo docker exec Paperless-Office document_exporter ../export -d
sudo borg create --stats --progress /BORG/Cosmos/Exports::{now}-paperless-office /usr/Paperless/Office/export
# EXPORT - Paperless-Office 2:
echo "|----------> 1.2 Step: Exports from running Containers & Backup with BORG - Paperless - Research:"
sudo docker exec Paperless-Research document_exporter ../export -d
sudo borg create --stats --progress /BORG/Cosmos/Exports::{now}-paperless-research /home/steven/paperless/export
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# STOP ALL CONTAINERS:
echo "|----------> 2. Step: Stop all running Docker Containers:"
sudo docker stop $(docker ps -a -q)
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# BORG BACKUP ALL DATA IN DOCKER VOLUMES PATH:
echo "|----------> 3.1 Step: Compress all Volumes LZ4 with BORG and save to NAS-MAIN:"
# NOTE: THIS IS BACKING UP ALL CONTENTS OF THE DOCKER VOLUMES PATH. SO EVERYTHING SHOULD BE INCLUDED WHEN IT COMES TO VOLUMES!
# TEMPLATE COMMAND - BORG: LZ4 COMPRESSION & STATS & PROGRESS & NON-VERBOSE: borg create --stats --progress /REPOPATH::25-11-2021-NAME /SOURCEPATH
# TEMPLATE COMMAND - TAR ZSTD: sudo tar -cvf /TARGETPATH-$DATE.tar /SOURCEPATH
sudo borg create --stats --progress /BORG/Cosmos/Volumes::{now}-Volumes-All /var/lib/docker/volumes
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# BORG BACKUP BIND MOUNT PATHS - Manually:
echo "|----------> 3.2 Step: Compress all Bind Mounts as LZ4 with BORG and save to NAS-MAIN:"
# NOTE: YOU HAVE TO FIND ALL BIND MOUNT PATHS MANUALLY!!! THIS IS NOT AUTOMATED, IN CONTRAST TO VOLUMES! AND ONLY BACKUP WHAT YOU WANT, OTHERWISE YOU IDIOT WILL BACKUP YOUR WHOLE NAS WHEN YOU BIND IT TO PLEX!!
# TEMPLATE COMMAND: tar -czvf /BACKUP/Bind/ARCHIVENAME FILENAME
# TEMPLATE COMMAND - BORG: LZ4 COMPRESSION & STATS & PROGRESS & NON-VERBOSE: borg create --stats --progress /REPOPATH::25-11-2021-NAME /SOURCEPATH
sudo borg create --stats --progress /BORG/Cosmos/Bind::nextcloud-privat-data-{now} /usr/nextcloud/privat/data
sudo borg create --stats --progress /BORG/Cosmos/Bind::nextcloud-data-{now} /usr/nextcloud/nextcloud/data
sudo borg create --stats --progress /BORG/Cosmos/Bind::nextcloud-public-data-{now} /usr/nextcloud/public/data
sudo borg create --stats --progress /BORG/Cosmos/Bind::tautulli-{now} /home/steven/tautulli
sudo borg create --stats --progress /BORG/Cosmos/Bind::docker.sock-{now} /var/run/docker.sock
sudo borg create --stats --progress /BORG/Cosmos/Bind::truecommand-{now} /home/steven/truecommand
sudo borg create --stats --progress /BORG/Cosmos/Bind::homarr-icons-{now} /usr/homarr-icons
sudo borg create --stats --progress /BORG/Cosmos/Bind::plextraktsync-{now} /home/steven/plextraktsync
sudo borg create --stats --progress /BORG/Cosmos/Bind::paperless-office-consume-{now} /usr/Paperless/Office/consume
sudo borg create --stats --progress /BORG/Cosmos/Bind::paperless-office-export-{now} /usr/Paperless/Office/export
sudo borg create --stats --progress /BORG/Cosmos/Bind::paperless-research-consume-{now} /home/steven/paperless/consume
sudo borg create --stats --progress /BORG/Cosmos/Bind::paperless-research-export-{now} /home/steven/paperless/export
sudo borg create --stats --progress /BORG/Cosmos/Bind::vaultwarden-exports-{now} /BACKUP/Exports/Vaultwarden
sudo borg create --stats --progress /BORG/Cosmos/Bind::ladder-form-exports-{now} /usr/handlers/form.html
sudo borg create --stats --progress /BORG/Cosmos/Bind::ladder-ruleset-{now} /usr/ruleset.yaml
sudo borg create --stats --progress /BORG/Cosmos/Bind::archivebox-data-{now} /home/steven/docker/bind/archivebox
sudo borg create --stats --progress /BORG/Cosmos/Bind::tautulli-{now} /home/steven/docker/bind/tautulli
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# BORG BACKUP BIND MOUNT PATHS - home/steven/docker:
echo "|----------> 3.3 Step: Compress all Bind Mounts in /home/steven/docker as LZ4 with BORG and save to NAS-MAIN:"
sudo borg create --stats --progress /BORG/Cosmos/System::{now}-steven-docker /home/steven/docker
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# OPTIONAL: DUMP DBS:
echo "|----------> 5. Step - Optional: Dump all Databases:"
# TEMPLATE COMMAND - MARIA DB: docker exec CONTAINERNAME /usr/bin/mariadb-dump -u root --password=ROOTPASSWORD DATABASE > backup.sql
# TEMPLATE COMMAND - MYSQL: docker exec CONTAINERNAME /usr/bin/mysqldump -u root --password=ROOTPASSWORD DATABASE > backup.sql
# TEMPLATE COMMAND - PostgreSQL - All - Uncompressed: docker exec CONTAINERNAME pg_dumpall -c -U POSTGRESUSER > backup.sql 
# TEMPLATE COMMAND - PostgreSQL - Specific DB - Uncompressed: docker exec CONTAINERNAME pg_dumpall -c -U POSTGRESUSER -d DATABASENAME > backup.sql 
echo "|----------> 5.1 Step - Optional: Dump all Databases - Nextcloud - Office:"
#docker exec CONTAINERNAME /usr/bin/mariadb-dump -u root --password=ROOTPASSWORD DATABASE > backup.sql
echo "|----------> 5.1 Step - Optional: Dump all Databases - Nextcloud - Public:"
#docker exec CONTAINERNAME /usr/bin/mariadb-dump -u root --password=ROOTPASSWORD DATABASE > backup.sql
echo "|----------> 5.1 Step - Optional: Dump all Databases - Nextcloud - No Name:"
#docker exec CONTAINERNAME /usr/bin/mariadb-dump -u root --password=ROOTPASSWORD DATABASE > backup.sql
echo "|----------> 5.2 Step - Optional: Dump all Databases - Monica:"
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Backup other paths with Borg:
#echo "|----------> 6.1 Step - Backup other paths with Borg - /etc"
sudo borg create --stats --progress /BORG/Cosmos/System::etc-{now} /etc
# Backup other paths with Borg:
echo "|----------> 6.2 Step - Backup other paths with Borg - /home"
sudo borg create --stats --progress /BORG/Cosmos/System::home-{now} /home
# Backup other paths with Borg:
echo "|----------> 6.3 Step - Backup other paths with Borg - /root"
sudo borg create --stats --progress /BORG/Cosmos/System::root-{now} /root
# Backup other paths with Borg:
echo "|----------> 6.4 Step - Backup other paths with Borg - /var"
sudo borg create --stats --progress /BORG/Cosmos/System::var-{now} /var
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# OPTIONAL: Borg Prune:
echo "|----------> 7.1 Step: Prune Borg Repos:"
#NOTE: This will delete all but the listed number of backups. With -p=progress --force=force deletion --list=Print summary
# This will keep all backups in the last 24H, for every last 30 days, 4 weekly, 12 monthly and up to 100 years of yearly backups.. ;)
sudo borg -p prune --keep-within 24H --force --list --keep-daily 30 --keep-weekly 4 --keep-monthly 12 --keep-yearly 100 --stats /BORG/Cosmos/Bind
sudo borg -p prune --keep-within 24H --force --list --keep-daily 30 --keep-weekly 4 --keep-monthly 12 --keep-yearly 100 --stats /BORG/Cosmos/Exports
sudo borg -p prune --keep-within 24H --force --list --keep-daily 30 --keep-weekly 4 --keep-monthly 12 --keep-yearly 100 --stats /BORG/Cosmos/Volumes
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# FREE SPACE WITH BORG COMPACT:
echo "|----------> 7.2 Step: Compact (Free Disk Space) Borg Repos:"
sudo borg --progress compact /BORG/Cosmos/Bind
sudo borg --progress compact /BORG/Cosmos/Volumes
sudo borg --progress compact /BORG/Cosmos/Exports
sudo borg --progress compact /BORG/Cosmos/System
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# CODE NOT NEEDED RIGHT NOW - START ------------------------------------------------------------------------------------------------------------------------------------------------------------------
#echo "|----------> 3. Step: Compress all Volumes in /var/lib/docker/volumes as TAR with no compression and save to NAS-MAIN:"
#sudo tar -cvf /BACKUP/Volumes/$DATE/var-lib-docker-volumes-$DATE.tar /var/lib/docker/volumes
# TEMPLATE COMMAND: tar -czvf /BACKUP/Volumes/ARCHIVENAME FILENAME (v=VERBOSE) (c=CREATE) (f=define file) (--ZSTD=Define ZSTD as algo) (-T0=All threads used) 
#START VAULTWARDEN BACKUP CONTAINER AND START BACKUP:
#echo "|----------> 6. Step - Optional: Start Vaultwarden-Backup Container: NOT NEEDED - SHOULD ALREADY RUN:"
#sudo docker run -d --restart=always --name vaultwarden-backup --volumes-from=Vaultwarden -e BACKUP_ON_STARTUP=true -e CRON_TIME="0 * * * *" -e BACKUP_DIR=/data/backup -e TIMESTAMP=true -v /BACKUP/Exports/Vaultwarden:/data/backup bruceforce/vaultwarden-backup
# CODE NOT NEEDED RIGHT NOW - END --------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# START ALL CONTAINERS:
echo "|----------> 8. Step: Restart all Containers:"
sudo docker start $(docker ps -a -q)
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# THE END:
echo "|----------| ALL DONE! LETS HOPE THIS SHITTY SCRIPT DID NOT FUCK UP THE SYSTEM... ;) |----------|"
