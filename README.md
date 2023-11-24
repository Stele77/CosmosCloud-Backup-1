# Cosmos Cloud - Backup Script:
Low IQ and low effort version of a shell script, that uses Borg to backup your volumes and exported Data from Containers.
Not only for the AMAZING Self Hosting project cosmoscloud.io, but for anyone wanting to backup Docker Volumes, Bind Mounts and other files.

## NEEDED SOFTWARE - BASICS:
```bash 
sudo apt install borgbackup 
```

## NEEDED SOFTWARE - OPTIONAL:
```bash 
sudo apt install rsync cifs-utils samba rclone 
```

## TODO LIST - MUST:
- Better Comments

## TODO LIST - MAYBE:
- Exporting Databases
- RCLONE backup to remote Cloud FS 
- SSHFS backup to remote FS over SSH

## WARNINGS:
- While the containers are all stopped and restared after the backup, this is NOT a best practice with Docker containers involving databases like MariaDB etc.
Exporting those DBs can be added to the script; I will maybe update it myself later on.
Normally most people wont experience any dataloss with stopped containers, but I note again: 
THIS IS NOT A BEST PRACTICE, AND AT YOUR OWN RISK JUST LIKE THE USE OF THIS WHOLE SCRIPT!
- I am in no way qualified as a programmer beyond basic and abyssmal knowledge of Linux and BASH and a high school level BASIC course decades ago.
If you trust this code with your data without serious review and adaptation, you are an even bigger fool than myself. :)
- I am not promising any support for your own usecase.
