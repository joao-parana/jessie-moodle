#!/bin/bash
set -e

echo "Iniciando no usuário: `whoami`"
    
echo ". . . . Contêiner JessieLAMP com Moodle e SSH . . . ."
echo "Você invocou com os seguintes parâmetros: $@"
if [ "$1" = 'modules' ]; then
    echo "Veja abaixo a lista de Módulos PHP instalados"
    find /usr/src/php/ext -mindepth 2 -maxdepth 2 -type f -name 'config.m4' | cut -d/ -f6 | sort
    exit 0
fi

if [ "$1" = 'start-moodle' ]; then
    echo "Iniciando Apache (com PHP), MySQL, Servidor SSH e Moodle"
    /start.sh
    echo "••• `date` - Apache terminou juntamente com toda a Stack LAMP e o Moodle"
    exit 0
fi

if [ "$1" = '--help' ]; then
    echo " "
    echo " "
    echo "Você pode invocar este Contêiner em 4 modos diferentes:"
    echo " "
    echo "docker run --rm -i-t NOME-IMAGEM --help"
    echo "       Para ver esta mensagem"
    echo "docker run --rm -i-t NOME-IMAGEM modules"
    echo "       Para ver a lista de módulos PHP disponíveis em runtime"
    echo "docker run --rm -i-t NOME-IMAGEM start-moodle"
    echo "       Para iniciar o Apache WEB Server, o MySQL Server e o Servidor SSH"
    echo "docker run --rm -i-t NOME-IMAGEM /bin/bash"
    echo "       Para iniciar apenas uma shell bash - isto serve para investigar problemas"
    echo " "
    echo "Observação:"
    echo "  Você poderá substituir as opções '--rm -i-t' pela opção '-d' "
    echo "  Isso fará com que o conteiner rode como Daemon. "
    echo "  Mas isso só faz sentido para o caso da opção  "
    echo "  • start-moodle"
    echo " "
    exit 0
fi

echo ". . . . . . . . . . . . . . . . . . ."
exec "$@"
