#!/bin/bash
# NOTES: 
# Before using Borg, obviously install it, and setup Borg Repos in the paths you want as target location for your Backups.
# Obviously (again): Adjust ALL paths, add/remove what you need or dont, adjust ENVs, commands, etc. Dont be a total idiot and just run code you copy pasted from the web.
# NOTE: YOU HAVE TO FIND ALL BIND MOUNT PATHS MANUALLY!!! THIS IS NOT AUTOMATED, IN CONTRAST TO VOLUMES! AND ONLY BACKUP WHAT YOU WANT, OTHERWISE YOU IDIOT WILL BACKUP YOUR WHOLE NAS WHEN YOU BIND IT TO PLEX!!
# THIS IS THE VERSION I PERSONALLY USE, I WILL UPLOAD A TEMPLATE VERSION LATER.
# DEFINE VARIABLES:
DATE=$(date +%Y-%m-%d)
# SET ENVIRONMENT VARIABLES:
env ZSTD_CLEVEL=1
# TODO - REPLACE PATHS WITH VARIABLES:
# BACKUP_DIR_VOLUMES=/BACKUP/Volumes
# TUI:
echo "|----------| Script - Backup - Cosmos Cloud - Volumes & Bind Mounts with BORG to NAS-MAIN - V.0.2 - 2023 11 24 |----------|"
# EXPORT - Paperless-Office 1:
echo "|----------> 1.1 Step: Exports from running Containers & Backup with BORG - Paperless - Office:"
sudo docker exec Paperless-Office document_exporter ../export -d
sudo borg create --stats --progress /BORG/Cosmos/Exports::$DATE-paperless-office /usr/Paperless/Office/export
# EXPORT - Paperless-Office 2:
echo "|----------> 1.2 Step: Exports from running Containers & Backup with BORG - Paperless - Research:"
sudo docker exec Paperless-Research document_exporter ../export -d
sudo borg create --stats --progress /BORG/Cosmos/Exports::$DATE-paperless-research /home/steven/paperless/export
# STOP ALL CONTAINERS:
echo "|----------> 2. Step: Stop all running Docker Containers:"
sudo docker stop $(docker ps -a -q)
# BORG BACKUP ALL DATA IN DOCKER VOLUMES PATH:
echo "|----------> 3. Step: Compress all Volumes LZ4 with BORG and save to NAS-MAIN:"
# NOTE: THIS IS BACKING UP ALL CONTENTS OF THE DOCKER VOLUMES PATH. SO EVERYTHING SHOULD BE INCLUDED WHEN IT COMES TO VOLUMES!
# TEMPLATE COMMAND - BORG: LZ4 COMPRESSION & STATS & PROGRESS & NON-VERBOSE: borg create --stats --progress /REPOPATH::25-11-2021-NAME /SOURCEPATH
# TEMPLATE COMMAND - TAR ZSTD: sudo tar -cvf /TARGETPATH-$DATE.tar /SOURCEPATH
sudo borg create --stats --progress /BORG/Cosmos/Volumes::$DATE-Volumes-All /var/lib/docker/volumes
# BORG BACKUP BIND MOUNT PATHS:
echo "|----------> 4. Step: Compress all Bind Mounts as LZ4 with BORG and save to NAS-MAIN:"
# NOTE: YOU HAVE TO FIND ALL BIND MOUNT PATHS MANUALLY!!! THIS IS NOT AUTOMATED, IN CONTRAST TO VOLUMES! AND ONLY BACKUP WHAT YOU WANT, OTHERWISE YOU IDIOT WILL BACKUP YOUR WHOLE NAS WHEN YOU BIND IT TO PLEX!!
# TEMPLATE COMMAND: tar -czvf /BACKUP/Bind/ARCHIVENAME FILENAME
# TEMPLATE COMMAND - BORG: LZ4 COMPRESSION & STATS & PROGRESS & NON-VERBOSE: borg create --stats --progress /REPOPATH::25-11-2021-NAME /SOURCEPATH
sudo borg create --stats --progress /BORG/Cosmos/Bind::$DATE-nextcloud-privat-data /usr/nextcloud/privat/data
sudo borg create --stats --progress /BORG/Cosmos/Bind::$DATE-nextcloud-data /usr/nextcloud/nextcloud/data
sudo borg create --stats --progress /BORG/Cosmos/Bind::$DATE-nextcloud-public-data /usr/nextcloud/public/data
sudo borg create --stats --progress /BORG/Cosmos/Bind::$DATE-tautulli /home/steven/tautulli
sudo borg create --stats --progress /BORG/Cosmos/Bind::$DATE-docker.sock /var/run/docker.sock
sudo borg create --stats --progress /BORG/Cosmos/Bind::$DATE-truecommand /home/steven/truecommand
sudo borg create --stats --progress /BORG/Cosmos/Bind::$DATE-homarr-icons /usr/homarr-icons
sudo borg create --stats --progress /BORG/Cosmos/Bind::$DATE-plextraktsync /home/steven/plextraktsync
sudo borg create --stats --progress /BORG/Cosmos/Bind::$DATE-paperless-office-consume /usr/Paperless/Office/consume
sudo borg create --stats --progress /BORG/Cosmos/Bind::$DATE-paperless-office-export /usr/Paperless/Office/export
sudo borg create --stats --progress /BORG/Cosmos/Bind::$DATE-paperless-research-consume /home/steven/paperless/consume
sudo borg create --stats --progress /BORG/Cosmos/Bind::$DATE-paperless-research-export /home/steven/paperless/export
sudo borg create --stats --progress /BORG/Cosmos/Bind::$DATE-vaultwarden-exports /BACKUP/Exports/Vaultwarden
# OPTIONAL: DUMP DBS:
echo "|----------> 5. Step - Optional: Dump all Databases: Not Yet Implemented!"
# OPTIONAL: Borg Prune:
echo "|----------> 6. Step: Prune Borg Repos:"
#NOTE: This will delete all but the listed number of backups. With -p=progress --force=force deletion --list=Print summary
sudo borg -p prune --force --list --keep-daily 30 --keep-weekly 4 --keep-monthly 12 --keep-yearly 100 --stats /BORG/Cosmos/Bind
sudo borg -p prune --force --list --keep-daily 30 --keep-weekly 4 --keep-monthly 12 --keep-yearly 100 --stats /BORG/Cosmos/Exports
sudo borg -p prune --force --list --keep-daily 30 --keep-weekly 4 --keep-monthly 12 --keep-yearly 100 --stats /BORG/Cosmos/Volumes
# CODE NOT NEEDED RIGHT NOW - START ------------------------------------------------------------------------------------------------------------------:
#echo "|----------> 3. Step: Compress all Volumes in /var/lib/docker/volumes as TAR with no compression and save to NAS-MAIN:"
#sudo tar -cvf /BACKUP/Volumes/$DATE/var-lib-docker-volumes-$DATE.tar /var/lib/docker/volumes
# TEMPLATE COMMAND: tar -czvf /BACKUP/Volumes/ARCHIVENAME FILENAME (v=VERBOSE) (c=CREATE) (f=define file) (--ZSTD=Define ZSTD as algo) (-T0=All threads used) 
#START VAULTWARDEN BACKUP CONTAINER AND START BACKUP:
#echo "|----------> 6. Step - Optional: Start Vaultwarden-Backup Container: NOT NEEDED - SHOULD ALREADY RUN:"
#sudo docker run -d --restart=always --name vaultwarden-backup --volumes-from=Vaultwarden -e BACKUP_ON_STARTUP=true -e CRON_TIME="0 * * * *" -e BACKUP_DIR=/data/backup -e TIMESTAMP=true -v /BACKUP/Exports/Vaultwarden:/data/backup bruceforce/vaultwarden-backup
# CODE NOT NEEDED RIGHT NOW - END --------------------------------------------------------------------------------------------------------------------:
# START ALL CONTAINERS:
echo "|----------> 7. Step: Restart all Containers:"
sudo docker start $(docker ps -a -q)
echo "|----------| ALL DONE! LETS HOPE THIS SHITTY SCRIPT DID NOT FUCK UP THE SYSTEM... ;) |----------|"
