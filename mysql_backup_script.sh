#!/usr/bin/env bash

DBUSER="mysqlbackup"
DBPASS="password"
DONTBACKUP=( "mysql" "information_schema" "performance_schema" "test" )
BACKUPROOT="/data/mysqlbackup"

DATEFORMAT=`date +%F`
BACKUPDIR="${BACKUPROOT}/${DATEFORMAT}"
KEEP_BACKUPS_FOR=14 #days

DBS="$(mysql -u $DBUSER -p$DBPASS -Bse 'show databases')"

containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

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

for DBNAME in $DBS
do
  if ! containsElement "$DBNAME" "${DONTBACKUP[@]}"; then
    mysqldump -u $DBUSER -p$DBPASS $DBNAME | gzip > $BACKUPDIR/$DATEFORMAT-$DBNAME.sql.gz
    echo "Database $DBNAME backed up."
  else
    echo "Skipping $DBNAME..."
  fi
done
