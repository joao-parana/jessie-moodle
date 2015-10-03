#!/bin/bash

set -e

if [ "${AUTHORIZED_KEYS}" != "**None**" ]; then
  echo "=> Found authorized keys"
  mkdir -p /root/.ssh
  chmod 700 /root/.ssh
  touch /root/.ssh/authorized_keys
  chmod 600 /root/.ssh/authorized_keys
  IFS=$'\n'
  arr=$(echo ${AUTHORIZED_KEYS} | tr "," "\n")
  for x in $arr
  do
    x=$(echo $x |sed -e 's/^ *//' -e 's/ *$//')
    cat /root/.ssh/authorized_keys | grep "$x" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo "••• `date` - => Adding public key to /root/.ssh/authorized_keys: $x"
      echo "$x" >> /root/.ssh/authorized_keys
    fi
  done
fi

if [ ! -f /.root_pw_set ]; then
  echo "••• `date` - Estabelecendo a senha de root para o SSH "
  /set_root_pw.sh "$ROOT_PASSWORD"
fi

if [ -f /.root_pw_set ]; then
  echo "••• `date` - Senha de root para o SSH já foi definida"
fi

echo "••• `date` - - - - - - Iniciando o SSH Server - - - - - - - - - "
/usr/sbin/sshd -D &
echo "••• `date` - - - - - - SSH Server Iniciado  - - - - - - - - "

echo "••• `date` - MySQL vai iniciar. Executarei /run-mysql.bash da imagem pai "
/run-mysql.bash

echo "MYSQL_ROOT_PASSWORD = $MYSQL_ROOT_PASSWORD"

if [ ! -f /var/www/html/moodle/config.php ]; then
  echo "••• `date` - Configurando o Moodle (Na primeira vez)"
  # ls -la /var/www/html
  echo "••• `date` - Volume montado em : /var/www/html"
  echo "••• `date` - Diretório corrente: `pwd`"
  chmod a+r /var/www/moodle-2.9.2.tgz && \
      tar zxf /var/www/moodle-2.9.2.tgz && \
      chown -R www-data:www-data /var/www/html && \
      mkdir /var/moodle-data && \
      chown -R www-data:www-data /var/moodle-data && \
      chmod 777 /var/moodle-data

  /list-directories.sh # Para Debug do processo de Build

  sleep 10s
  echo "••• `date` - Primeira vez: Configurando o Moodle "
  # Here we generate random passwords (thank you pwgen!).
  #
  MOODLE_DB="moodle"
  MOODLE_DB_USER="moodle"
  MOODLE_PASSWORD=`pwgen -c -n -1 12`
  #This is so the passwords show up in logs.
  echo "••• `date` - senha moodle: $MOODLE_PASSWORD"
  echo $MOODLE_PASSWORD > /moodle-db-pw.txt

  # Criando o database e o user para o Moodle
  /setup-moodle-db.sh $MOODLE_DB $MOODLE_DB_USER $MOODLE_PASSWORD
  echo "••• `date` - Usando config-dist.php para criar nosso config.php"
  # ls -la /var/www/html/moodle
  sed -e "s/pgsql/mysqli/
  s/dbhost    = 'localhost';/dbhost    = '127.0.0.1';/
  s/username';/$MOODLE_DB_USER';  /
  s/password/$MOODLE_PASSWORD/
  s/example.com/$VIRTUAL_HOST/
  s/'dbsocket'  => false/'dbsocket'  => true /
  s/'dbport'    => '',    /'dbport'    => '3306',/
  s/\/home\/example\/moodledata/\/var\/moodle-data/" \
  /var/www/html/moodle/config-dist.php > /var/www/html/moodle/config.php

  chown www-data:www-data /var/www/html/moodle/config.php
  echo "••• `date` - Exibindo config.php"
  cat /var/www/html/moodle/config.php | grep -v "^//"
fi
#
echo "••• `date` - Iniciando o Moodle "
echo "••• `date` - Apache vai iniciar no modo FOREGROUND"
echo "••• `date` - Para parar o Apache execute: apachectl stop"
# O Apache não se comporta muito bem com arquivos PID de sessões anteriores
rm -f /var/run/apache2/apache2.pid
/usr/local/bin/apache2-foreground
