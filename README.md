docker-moodle
=============

This **Dockerfile** is a [trusted build](https://registry.hub.docker.com/u/parana/jessie-moodle/) of [Docker Registry](https://registry.hub.docker.com/).

## Indice
- [Instruções resumidas](#instrucoes-resumidas)
- [Outros Detalhes](#outros-detalhes)
    - [Diretórios importantes](#diretorios-importantes)

Este Dockerfile instala a ultima versão do Moodle.

## Instruções resumidas

### Criando a imagem

```
git clone https://github.com/parana/jessie-moodle.git
cd jessie-moodle
curl -O https://download.moodle.org/download.php/direct/stable29/moodle-2.9.2.tgz
docker build -t HUB-USER-NAME/jessie-moodle .
```
Substitua o token `HUB-USER-NAME` pelo seu login em [http://hub.docker.com](http://hub.docker.com)

### Usando a imagem

Para iniciar o Moodle use:

```
docker run --name moodle-web -e VIRTUAL_HOST=moodle.meu-domino.com.br -d -t -p 80:80 -p 22:22 parana/jessie-moodle
```

### Testando o contêiner

Para abrir a aplicação:

```
open http://moodle.meu-domino.com.br/moodle
```

## Outros Detalhes 

> Esta imagem herda funcionalidades de outra imagem Docker que provê 
> **Stack LAMP** usando Debian Jessie (version 8), Apache WebServer, 
> o MySQL 5.6.26 e o PHP versão 5.6 (A versão 7 ainda não foi liberada)

Este projeto foi testado com a **versão 1.8.2** do Docker

Este Dockerfile foi preparado para minha apresentação na 
[Semana do Linux](http://www.semanadolinux.com.br)

Mais detalhes sobre Docker podem ser obtidos no curso
[http://joao-parana.com.br/blog/curso-docker/](http://joao-parana.com.br/blog/curso-docker/) 
que criei para a Escola Linux.

Usaremos aqui o nome `moodle-web` para o Contêiner.
Caso exista algum conteiner com o mesmo nome rodando, 
podemos pará-lo assim:

    docker stop moodle-web

> Pode demorar alguns segundos para parar e isto é normal.

Em seguida podemos removê-lo

    docker rm moodle-web

Podemos executar o Contêiner iterativamente para obter um help assim:

    docker run --rm -i -t --name moodle-web HUB-USER-NAME/jessie-moodle --help

Podemos tambem executar iterativamente assim:

    docker run --rm -i -t --name moodle-web \
           -p 80:80 -p 2285:22            \
           -e ROOT_PASSWORD=xyz             \
           HUB-USER-NAME/jessie-moodle start-moodle

Ou preferencialmente no modo Daemon assim:

    docker run -d --name moodle-web         \
           -p 80:80 -p 2285:22            \
           -e ROOT_PASSWORD=xyz             \
           HUB-USER-NAME/jessie-moodle start-moodle

Observe o mapeamento da porta 80 do Apache dentro do contêiner 
para uso externo em 80. O valor 80 da esquerda pode ser alterado a 
seu critério. Mas para usar a porta 80 no host como mostrado, é preciso 
ter direitos para isso e ela não pode estar ocupada por outro processo.

Você pode verificar como ficou o arquivo `/etc/hosts` assim:

    docker exec moodle-web cat /etc/hosts

Você verá algo parecido com a listagem abaixo:

    172.17.0.140  moodle.example.com moodle
    127.0.0.1 localhost
    ::1 localhost ip6-localhost ip6-loopback
    fe00::0 ip6-localnet
    ff00::0 ip6-mcastprefix
    ff02::1 ip6-allnodes
    ff02::2 ip6-allrouters
    172.17.0.140  moodle-web
    172.17.0.140  moodle-web.bridge


A porta 22 do SSH também foi mapeada e neste caso para 2285.

Verificando o Log

    docker logs moodle-web

Para ver apenas a password do usuário root que foi definida para 
uso via SSH use o comando abaixo:

    docker logs moodle-web 2> /dev/null | grep  "senha de root"

Podemos então abrir uma sessão SSH com o contêiner. No caso de 
usar o Docker num Host com **MAC OSX** podemos fazer:

    ssh -p 2285 root@$(docker-ip)

docker-ip é uma função criado no `.bash_profile` por conveniência. 
Veja o fonte abaixo:

    docker-ip() {
      boot2docker ip 2> /dev/null
    }

Para abrir uma sessão SSH com o contêiner quando
usar o Docker num Host **Linux**, Ubuntu por exemplo, 
podemos fazer:

    ssh -p 2285 root@localhost

Para testar a conexão com o Banco de Dados podemos usar:

    docker exec moodle-web php /var/www/html/testecli.php

Após executar o sistema por um tempo, podemos parar o contêiner 
novamente para manutenção

    docker stop moodle-web

e depois iniciá-lo novamente e observar o log

    docker start moodle-web && sleep 10 && docker logs moodle-web

Observe que **o LOG é acumulativo** e que agora não é executado o 
processo de Inicialização do Database, criação de usuários no MySQL, 
criação do nosso database, ajustes do PHP.INI, do HTTPD.CONF, etc. 

Você poderá ver o conteúdo do diretório /tmp executando o comando abaixo:

    docker exec moodle-web ls -lat /tmp

Se você estiver usando o **MAC OSX** com Boot2Docker 
poderá executar o comando abaixo para abrir uma sessão como 
root no MySQL:

    open http://$(docker-ip):8085/moodle/

No Linux (Ubuntu por exemplo) use assim:

    open http://localhost:8085/moodle/

A senha do MySQL para ser usada no programa PHP 
está Hard-coded no arquivo run.sh, mas apenas 
por motivos didáticos. 
Veja a variável `MYSQL_ROOT_PASSWORD` na shell run.sh

### Diretórios importantes:

    Documentos do site - /var/www/html/moodle
    Diretório de dados - /var/moodle-data
    PHP.INI            - /usr/local/etc/php e /usr/local/etc/php/conf.d
    Extensões PHP      - /usr/src/php/ext
    Logs do Apache     - /var/log/apache2
    Logs do MySQL      - /var/log/mysql
    Logs do PHP        - /var/log  (configurado em config/php.ini)

Exemplo de uso do comando `docker exec` para ver o Log do MySQL

    docker exec moodle-web cat /var/log/mysql/error.log

Da mesma forma, para verificar a configuração do PHP use:

    docker exec moodle-web cat /usr/local/etc/php/php.ini

Para corrigir algum erro eventual no Setup do Moodle 
você pode precisar da senha do user `root` do MySQL gerado 
pela imagem `parana/jessie-lamp` que origina esta.

Para isso use o comando:

    docker exec moodle-web grep  "IDENTIFIED BY" /tmp/mysql-first-time-only.sql | grep root

Para avaliar se o database foi criado corretamente na 
primeira vez que iniciamos o Contêiner podemos executar:

    ssh -p 2285 root@$(docker-ip)
    mysql -u moodle -p moodle

### Verificando o ambiente Moodle

Exibindo dados relevantes do config.php do Moodle:

    docker exec moodle-web cat /var/www/html/moodle/config.php | grep -v "^//"

Tipicamente o arquivo `config.php` fica parecido com este listado abaixo:

    <?php
      unset($CFG);  // Ignore this line
      global $CFG;  // This is necessary here for PHPUnit execution
      $CFG = new stdClass();
      $CFG->dbtype    = 'mysqli';     // 'pgsql', 'mariadb', 'mysqli', 'mssql', 'sqlsrv' or 'oci'
      $CFG->dblibrary = 'native';     // 'native' only at the moment
      $CFG->dbhost    = '127.0.0.1';  // eg 'localhost' or 'db.isp.com' or IP
      $CFG->dbname    = 'moodle';     // database name, eg moodle
      $CFG->dbuser    = 'moodle';     // your database username
      $CFG->dbpass    = 'eeJ89hai';   // your database password
      $CFG->prefix    = 'mdl_';       // prefix to use for all table names
      $CFG->dboptions = array(
          'dbpersist' => false,       // should persistent database connections be
                                      //  used? set to 'false' for the most stable
                                      //  setting, 'true' can improve performance
                                      //  sometimes
          'dbsocket'  => true,       // should connection via UNIX socket be used?
                                      //  if you set it to 'true' or custom path
                                      //  here set dbhost to 'localhost',
                                      //  (please note mysql is always using socket
                                      //  if dbhost is 'localhost' - if you need
                                      //  local port connection use '127.0.0.1')
          'dbport'    => '3306',      // the TCP port number to use when connecting
                                      //  to the server. keep empty string for the
                                      //  default port
      );
      $CFG->wwwroot   = 'http://moodle.example.com/moodle';
      $CFG->dataroot  = '/var/moodle-data';
      $CFG->directorypermissions = 02777;
      $CFG->admin = 'admin';
      require_once(dirname(__FILE__) . '/lib/setup.php'); // Do not edit
    ?>

#### Mais detalhes sobre Docker no meu Blog: [http://joao-parana.com.br/blog/](http://joao-parana.com.br/blog/)

