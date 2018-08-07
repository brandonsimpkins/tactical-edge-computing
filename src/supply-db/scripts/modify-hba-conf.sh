#!/bin/sh

#
# This function prints the script usage
#
function usage {
  echo "Usage: $0 [add|delete] [hba entry]"
  echo "Adds or deletes an entry from the Postgres pg_hba.conf"
  echo
  echo "A typical replication entry in the pg_hba.conf file looks like:"
  echo " > host replication all 18.210.155.145/32 md5"
  exit 1
}

# check options / arguments
if [ "$1" != "add" ] && [ "$1" != "delete" ]; then
  usage
fi

if [ -z "$2" ]; then
  usage
fi

# Set the path to the pg_hba.conf file. This allows for local testing where the
# $PGDATA env variable is not set
if [ "$PGDATA" ]; then
  HBA_CONF="$PGDATA/pg_hba.conf"
else
  HBA_CONF="pg_hba.conf"
fi

# process add command
if [ "$1" == "add" ]; then
  echo "$2" >> $HBA_CONF
  exit 0
fi

# process delete command
if [ "$1" == "delete" ]; then
  grep -v "$2" $HBA_CONF > $HBA_CONF.temp
  mv $HBA_CONF.temp $HBA_CONF
  exit 0
fi

