#!/bin/bash

set -e

# Parameters: MOODLE_DB, MOODLE_DB_USER e MOODLE_PASSWORD
DB=$1
DB_USER=$2
PASSWD=$3
ROOT_DB_PASSWD=$MYSQL_ROOT_PASSWORD

if [ -z "$ROOT_DB_PASSWD" ]; then
    ROOT_DB_PASSWD='xpto'
fi

tempSqlFile='/tmp/mysql-first-time-only-for-moodle.sql'

# Comandos SQL devem ficar em linhas individuais
# terminadas por ponto-e-virgula sem quebras de linha

cat > "$tempSqlFile" <<-EOSQL
  CREATE DATABASE IF NOT EXISTS \`$DB\` ;
  CREATE USER '$DB_USER'@'%' IDENTIFIED BY '${PASSWD}' ;
  GRANT ALL ON \`$DB\`.* TO '$DB_USER'@'%' WITH GRANT OPTION ;
  FLUSH PRIVILEGES ;
  USE  \`$DB\` ;
EOSQL

cat $tempSqlFile
mysql -u root -p$ROOT_DB_PASSWD < $tempSqlFile
