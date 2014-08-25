#!/bin/bash

# TYPO3 Backup-Script
# Version 1.0 (23.05.2013)

# Autor: Clemens Siebenhaar / 7ITec GmbH / www.7itec.de

# Setzen der Instanz-Variablen aus Übergabe
if [ "$1" = "" ]; then
   echo "Fehler beim Aufruf des Skriptes! Keinen Namen für die neue Instanz angegeben!"

else

# Variablen setzen
BACKUP_DIR=$1
BACKUP_DEST=/var/backups

# Konfigurationsdatei finden: localconf.php oder LocalConfiguration.php

CONFIG_FILE=

# TYPO3-Version < 6.0
if [ -f $BACKUP_DIR/typo3conf/localconf.php ]; then
        echo 'TYPO3-Version < 6.0 : localconf.php wird ausgelesen..'
        CONFIG_FILE=$BACKUP_DIR/typo3conf/localconf.php
        DB_NAME=`cat $CONFIG_FILE | grep '\$typo_db\ ' | cut -d "'" -f 2`
		DB_USER=`cat $CONFIG_FILE | grep '\$typo_db_username\ ' | cut -d "'" -f 2`
		DB_PASSWORD=`cat $CONFIG_FILE | grep '\$typo_db_password\ ' | cut -d "'" -f 2`
		DB_HOST=`cat $CONFIG_FILE | grep '\$typo_db_host\ ' | cut -d "'" -f 2`
fi

# TYPO3-Version >= 6.0
if [ -f $BACKUP_DIR/typo3conf/LocalConfiguration.php ]; then
        echo 'TYPO3-Version >= 6.0 : LocalConfiguration.php wird ausgelesen..'
        CONFIG_FILE=$BACKUP_DIR/typo3conf/LocalConfiguration.php
		DB_NAME=`cat $CONFIG_FILE | grep \'database\'\ =\> | cut -d "'" -f 4`
		DB_USER=`cat $CONFIG_FILE | grep \'username\'\ =\> | cut -d "'" -f 4`
		DB_PASSWORD=`cat $CONFIG_FILE | grep \'password\'\ =\> | cut -d "'" -f 4`
		DB_HOST=`cat $CONFIG_FILE | grep \'host\'\ =\> | cut -d "'" -f 4`
fi

if [ -z $CONFIG_FILE ]; then
        echo "TYPO3-Konfiguration nicht gefunden"
fi

echo "Backup $BACKUP_DIR"
echo "Database: $DB_NAME"

echo "Erstelle Sicherungsverzeichnis"
mkdir -p  $BACKUP_DEST/$DB_NAME

echo "Erstelle Sicherung der Datenbank..."
mysqldump -u $DB_USER -p$DB_PASSWORD -h $DB_HOST $DB_NAME > $BACKUP_DEST/$DB_NAME/database_`date +"%Y%m%d-%H%M"`.sql

echo "Sichere Dateien..."
tar czf $BACKUP_DEST/$DB_NAME/files_`date +"%Y%m%d-%H%M"`.tar.gz -C $BACKUP_DIR .

fi
