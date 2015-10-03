#!/bin/bash

set -e

# Parameters: MOODLE_DB, MOODLE_DB_USER e MOODLE_PASSWORD
DB=$1
DB_USER=$2
PASSWD=$3

RET=`echo "show tables;" | mysql -u $DB_USER -p$PASSWD  $DB `
echo "$RET"
