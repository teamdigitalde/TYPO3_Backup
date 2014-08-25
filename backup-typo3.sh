#!/bin/bash

##########################################################################
# (c) 2014 Henrik Ziegenhain <cerdanyohann@yahoo.fr>
# All rights reserved
#
# This program is free software : you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# The GNU General Public License can be found at
# http://www.gnu.org/copyleft/gpl.html.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# The basic backup script was written by Clemens Siebenhaar
# Version 1.0 (23.05.2013)
# Autor: Clemens Siebenhaar / 7ITec GmbH / www.7itec.de
##########################################################################

# Setzen der Instanz-Variablen aus Übergabe
if [ "$1" = "" ]; then
   echo "Fehler beim Aufruf des Skriptes! Keinen Namen für die neue Instanz angegeben! Bitte im ersten Argument das Quellverzeichnis relativ vom aktuellen working directory angeben!

else

# Variablen setzen
BACKUP_DIR=${PWD}"/"$1
BACKUP_DEST=${PWD}"/backups"
TIMESTAMP = `date +"%Y%m%d-%H%M"`

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
mysqldump -u $DB_USER -p$DB_PASSWORD -h $DB_HOST $DB_NAME > $BACKUP_DEST/$TIMESTAMP/database_$DB_NAME.sql

echo "Sichere Dateien..."
tar czf $BACKUP_DEST/$TIMESTAMP/files_$DB_NAME.tar.gz -C $BACKUP_DIR .

fi
