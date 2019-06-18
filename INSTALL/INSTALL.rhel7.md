<aside class="warning">
The core MONARC team cannot certify if this guide is working or not. Please help us in keeping it up to date and accurate.
</aside>

# Software repositories & packages

Install Apache (httpd), MariaDB, mod_ssl & dependencies from the standard Red Hat repositories.

Install Remi's rpm repository for Red Hat 7.

    yum install https://rpms.remirepo.net/enterprise/remi-release-7.rpm

Install the epel repo - extra packages for enterprise Linux 7

    yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

Install php7.2, required modules & dependencies from Remi's repository:

    php72.x86_64 php72-php.x86_64 php72-php-gd.x86_64 php72-php-mysqlnd.x86_64 php72-php-mbstring.x86_64 php72-php-pear.noarch php72-php-pecl-apcu.x86_64 php72-php-xml.x86_64 php72-php-intl.x86_64 php72-php-pecl-imagick.x86_64 php72-php-pecl-zip.x86_64

Install npm, nodejs-grunt-cli & dependencies

# Database configuration

Add the following line to server.cnf (/etc/my.cnf.d/server.cnf) otherwise you
may get an error when initializing the database

    [mariadb]
    max_allowed_packet=8M

Start the server and create the databases (in the interpreter)

    CREATE DATABASE monarc_cli DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
    CREATE DATABASE monarc_common DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

Initialize the database

    mysql -u root -p monarc_common < db-bootstrap/monarc_structure.sql
    mysql -u root -p monarc_common < db-bootstrap/monarc_data.sql

Create a database user for monarc (in the interpreter)

    create user 'monarc'@'localhost' identified by 'password';
    grant create, delete, insert, select, update, drop, alter on monarc_common.* to 'monarc'@'localhost';
    grant create, delete, insert, select, update, drop, alter on monarc_cli.* to 'monarc'@'localhost';

# Installation of MONARC

Create the subdirectory __monarc__ under Apache documentroot (/var/www/html/) and cd to it

If you're behind an explicit proxy, set the env variables and configure git to use the proxy:

    $ export HTTP_PROXY=proxy:port
    $ export HTTPS_PROXY=proxy:port
    $ export HTTP_PROXY_REQUEST_FULLURI=0
    $ export HTTPS_PROXY_REQUEST_FULLURI=0
    $ git config --global http.proxy http://proxy:port

Add php to $PATH

    $ export PATH=$PATH:/opt/remi/php72/root/usr/bin:/opt/remi/php72/root/usr/sbin

Clone the repository and invoke composer

    $ git clone https://github.com/monarc-project/MonarcAppFO.git fo
    $ cd fo
    (as root) /opt/remi/php72/root/usr/bin/php ./composer.phar self-update
    $ /opt/remi/php72/root/usr/bin/php ./composer.phar install -o

Backend

    $ mkdir module
    $ cd module/
    $ ln -s ./../vendor/monarc/core MonarcCore
    $ ln -s ./../vendor/monarc/frontoffice MonarcFO

Frontend

    $ mkdir node_modules
    $ cd node_modules
    $ git clone https://github.com/monarc-project/ng-client.git ng_client
    $ git clone https://github.com/monarc-project/ng-anr.git ng_anr

Set up the database connection:

    $ cd /var/www/html/monarc/fo/config/autoload/
    $ cp local.php.dist local.php

Edit local.php and change the installation path (/var/www/html/monarc/fo) and the database credentials.

Update MONARC (including npm config for explicit proxy)

    $ npm config set proxy http://proxy:port
    $ npm config set https-proxy http://proxy:port
    $ cd /var/www/html/monarc/fo
    $ ./scripts/update-all.sh

Create initial user

    $ php ./vendor/robmorgan/phinx/bin/phinx seed:run -c ./module/MonarcFO/migrations/phinx.php

# Configure apache (as root)

Set file ownership for monarc installation

    cd /var/www/html/
    chown -R apache:apache monarc

## Configure virtual host

    cd /etc/httpd/conf.d/
    vim virtualhost.conf

    <VirtualHost *:80>
    ServerName monarc.
    DocumentRoot /var/www/html/monarc/fo/public

    <Directory /var/www/html/monarc/fo/public>
        DirectoryIndex index.php
        AllowOverride All
        Require all granted
    </Directory>

    <IfModule mod_headers.c>
       Header always set X-Content-Type-Options nosniff
       Header always set X-XSS-Protection "1; mode=block"
       Header always set X-Robots-Tag none
       Header always set X-Frame-Options SAMEORIGIN
    </IfModule>

    SetEnv APPLICATION_ENV "development"
