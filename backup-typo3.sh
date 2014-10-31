#!/bin/bash

##########################################################################
# (c) 2014 Henrik Ziegenhain <henrik@ziegenhain.me>
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

clear

# Setzen der Instanz-Variablen aus Übergabe
if [ "$1" = "" ]; then
   echo "Fehler beim Aufruf des Skriptes! Keinen Namen fuer die neue Instanz angegeben! Bitte im ersten Argument das Quellverzeichnis relativ vom aktuellen working directory angeben!"

else

# Variablen setzen
BACKUP_DIR=$1
BACKUP_DEST=${PWD}"/backups"
TIMESTAMP=`date +"%Y%m%d-%H%M"`

# Konfigurationsdatei finden: localconf.php oder LocalConfiguration.php

CONFIG_FILE=

# TYPO3-Version < 6.0
if [ -f ${PWD}/$BACKUP_DIR/typo3conf/localconf.php ]; then
        echo 'TYPO3-Version < 6.0 : localconf.php wird ausgelesen..'
        CONFIG_FILE=${PWD}/$BACKUP_DIR/typo3conf/localconf.php
        DB_NAME=`cat $CONFIG_FILE | grep '\$typo_db\ ' | cut -d "'" -f 2`
		DB_USER=`cat $CONFIG_FILE | grep '\$typo_db_username\ ' | cut -d "'" -f 2`
		DB_PASSWORD=`cat $CONFIG_FILE | grep '\$typo_db_password\ ' | cut -d "'" -f 2`
		DB_HOST=`cat $CONFIG_FILE | grep '\$typo_db_host\ ' | cut -d "'" -f 2`
fi

# TYPO3-Version >= 6.0
if [ -f ${PWD}/$BACKUP_DIR/typo3conf/LocalConfiguration.php ]; then
        echo 'TYPO3-Version >= 6.0 : LocalConfiguration.php wird ausgelesen..'
        CONFIG_FILE=${PWD}/$BACKUP_DIR/typo3conf/LocalConfiguration.php
		DB_NAME=`cat $CONFIG_FILE | grep \'database\'\ =\> | cut -d "'" -f 4`
		DB_USER=`cat $CONFIG_FILE | grep \'username\'\ =\> | cut -d "'" -f 4`
		DB_PASSWORD=`cat $CONFIG_FILE | grep \'password\'\ =\> | cut -d "'" -f 4`
		DB_HOST=`cat $CONFIG_FILE | grep \'host\'\ =\> | cut -d "'" -f 4`
fi

if [ -z $CONFIG_FILE ]; then
        echo "TYPO3-Konfiguration nicht gefunden"
fi

echo "Backup ${PWD}/$BACKUP_DIR"
echo "Database: $DB_NAME"

echo "Erstelle Sicherungsverzeichnis $BACKUP_DEST/$TIMESTAMP"
mkdir -p  $BACKUP_DEST/$TIMESTAMP

echo "Erstelle Sicherung der Datenbank..."
mysqldump --add-drop-table --create-options --default-character-set=utf8 -K -e -n -q --set-charset -u $DB_USER -p$DB_PASSWORD -r $BACKUP_DEST/$TIMESTAMP/database_$DB_NAME.sql $DB_NAME -h $DB_HOST

echo "Sichere Dateien..."
tar czf $BACKUP_DEST/$TIMESTAMP/files_$DB_NAME.tar.gz -C ${PWD}/$BACKUP_DIR .

#
# Optional: Backup Installation
#
echo -n "Should I install your recently made Backup? (yes/no)"
read MAKE_BACKUP
echo ""

if [ $MAKE_BACKUP != "yes" ]
then
	# create .htaccess file with basic acess protection
	touch $BACKUP_DEST/$TIMESTAMP/.htaccess
	printf '# Basic security checks\n# - Restrict access to sql dumps and tar-ball\nRewriteRule ^fileadmin/templates/.*(\.sql|\.tar\.gz)$ - [F]' >> $BACKUP_DEST/$TIMESTAMP/.htaccess
	# exit script
	exit
fi

#Extract Backupfiles
echo "Entpacke Dateien in Sicherungsverzeichnis..."
mkdir $BACKUP_DEST/$TIMESTAMP/$BACKUP_DIR
tar -xzf $BACKUP_DEST/$TIMESTAMP/files_$DB_NAME.tar.gz -C $BACKUP_DEST/$TIMESTAMP/$BACKUP_DIR
touch $BACKUP_DEST/$TIMESTAMP/$BACKUP_DIR/typo3conf/ENABLE_INSTALL_TOOL

#Read mysql login credentials
echo -n "Type new mysql db user: "
read NEW_DB_USER
echo ""

echo -n "Type new mysql db name: "
read NEW_DB_NAME
echo ""

echo -n "Type new mysql db password: "
read -s NEW_DB_PASSWORD
echo ""

echo "Importing DB: $NEW_DB_NAME from $BACKUP_DEST/$TIMESTAMP/database_$DB_NAME.sql"
mysql -u $NEW_DB_USER -p$NEW_DB_PASSWORD -h $DB_HOST $NEW_DB_NAME < $BACKUP_DEST/$TIMESTAMP/database_$DB_NAME.sql

#Delete backup-tarball and sqldump to cleanup directory
rm -f $BACKUP_DEST/$TIMESTAMP/database_$DB_NAME.sql
rm -f $BACKUP_DEST/$TIMESTAMP/files_$DB_NAME.tar.gz

fi
