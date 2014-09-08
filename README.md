TYPO3_Backup
==============

Simple script to backup TYPO3 instances.
Works both with versions 4 and 6 (localconf.php versus LocalConfiguration.php)

Simply download the latest version of the backup script from Githup
`wget https://raw.github.com/teamdigitalde/TYPO3_Backup/master/backup-typo3.sh`

Make it executable:
`chmod +x backup-typo3.sh`

Run the script:
`./backup-typo3.sh dirname`

After running the script, the backup is made into /backups/<timestamp>. Optionally you can now reinstall it. Done :-)