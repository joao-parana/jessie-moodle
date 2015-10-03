FROM parana/jessie-lamp
#
# A imagem parana/jessie-lamp implementa uma Stack LAMP com servidor SSH.
# Para isso ela usa a imagem oficial php:5.6-apache fornecida pela Docker inc.
# que por sua vez usa a versão 8 do Debian de codinome Jessie
#
MAINTAINER João Antonio Ferreira "joao.parana@gmail.com"

ENV REFRESHED_AT 2015-10-03

# RUN dpkg-divert --local --rename --add /sbin/initctl
# RUN ln -sf /bin/true /sbin/initctl

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
# RUN apt-get -y upgrade

# Instalando os pacotes básicos e os requeridos pelo Moodle
RUN apt-get -y install python-setuptools curl git unzip && \
    apt-get -y install postfix wget libcurl3-dev
# tirei esses: php5-curl php5-xmlrpc php5-intl php5-mysql

ENV REFRESHED_AT 2015-10-02.200

# ADD https://download.moodle.org/moodle/moodle-latest.tgz /var/www/moodle-latest.tgz
# ADD https://download.moodle.org/download.php/direct/stable29/moodle-2.9.2.tgz /var/www/moodle-2.9.2.tgz
COPY ./moodle-2.9.2.tgz /var/www/moodle-2.9.2.tgz
ADD https://raw.githubusercontent.com/joao-parana/jessie-moodle/master/list-directories.sh /list-directories.sh
RUN chmod a+rx /list-directories.sh
WORKDIR /var/www/html

ENV VIRTUAL_HOST    moodle.example.com

EXPOSE 22
EXPOSE 80

COPY ./setup-moodle-db.sh /setup-moodle-db.sh
COPY ./start.sh /start.sh
COPY ./check-db.sh /check-db.sh
RUN chmod 755 /setup-moodle-db.sh /start.sh /check-db.sh

# Usaremos uma shell específica no Entrypoint
# sobreescrevendo a versão existente vinda do
# Dockerfle parana/jessie-lamp
COPY ./docker-entrypoint.sh /
RUN chmod a+rx /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

# Flag Default fornecida via comando CMD
CMD ["--help"]
