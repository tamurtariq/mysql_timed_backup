#!/usr/bin/env bash

DBUSER="mysqlbackup"
DBPASS="password"
DBNAME="DB_Name"
BACKUPROOT="/data/mysqlbackup"

DATEFORMAT=`date +%F`
BACKUPDIR="${BACKUPROOT}/${DATEFORMAT}"
KEEP_BACKUPS_FOR=14 #days


echo "Cleaning up backup directory..."
find $BACKUPROOT -type d -ctime +$KEEP_BACKUPS_FOR -exec rm -rf {} +
echo "Cleaning done."

if [ ! -d ${BACKUPDIR} ]; then
  echo "Attempting to create backup directory ${BACKUPDIR} ..."
  if ! mkdir -p ${BACKUPDIR}; then
    echo "Backup directory ${BACKUPDIR} could not be created by this user: ${USER}" 1>&2
    echo "Aborting..." 1>&2
    exit 1
  else
    echo "Directory ${BACKUPDIR} successfully created."
  fi
elif [ ! -w ${BACKUPDIR} ]; then
  echo "Backup directory ${BACKUPDIR} is not writeable by this user: ${USER}" 1>&2
  echo "Aborting..." 1>&2
  exit 1
fi

    mysqldump -u $DBUSER -p$DBPASS $DBNAME | gzip > $BACKUPDIR/$DATEFORMAT_$DBNAME.sql.gz
    echo "Database $DBNAME backed up."
 
# S3 upload process
aws s3 cp $BACKUPDIR/$DATEFORMAT_$DBNAME.sql.gz s3://revage-mysql-backups/
