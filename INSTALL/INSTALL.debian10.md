Installation on Debian 10
=========================

# 1. Install LAMP & dependencies

## 1.1. Install system dependencies

    # apt-get install zip unzip git gettext curl gsfonts software-properties-common

Some might already be installed.

## 1.2. Install MariaDB

    # apt-get install mariadb-server

### Secure the MariaDB installation

    # mysql_secure_installation

Especially by setting a strong root password.

## 1.3. Install Apache2

    # apt-get install apache2

### Enable modules, settings, and default of SSL in Apache

    # a2dismod status
    # a2enmod ssl
    # a2enmod rewrite
    # a2enmod headers

### Apache Virtual Host

    <VirtualHost _default_:80>
        ServerAdmin admin@localhost.lu
        ServerName monarc.local
        DocumentRoot /var/lib/monarc/fo/public

        <Directory /var/lib/monarc/fo/public>
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

        SetEnv APP_ENV "production"
    </VirtualHost>


## 1.4. Install PHP and dependencies (It's recommended to install php8 or php8.1 and all the modules of the version).

    # apt-get install php7.3 libapache2-mod-php7.3 php7.3-curl php7.3-gd php7.3-mysql php-apcu php7.3-xml php7.3-mbstring php7.3-intl php-imagick php7.3-zip

    $ curl -sS https://getcomposer.org/installer -o composer-setup.php
    # php composer-setup.php --install-dir=/usr/bin --filename=composer
    
    
## Apply PHP configuration settings in your php.ini

https://github.com/monarc-project/MonarcAppFO/blob/master/vagrant/bootstrap.sh#L22-L26


## 1.5 Apply all changes

    # systemctl restart apache2.service



# 2. Installation of MONARC

## 2.1. MONARC source code

    $ mkdir -p /var/lib/monarc/fo
    $ git clone https://github.com/monarc-project/MonarcAppFO.git /var/lib/monarc/fo
    $ cd /var/lib/monarc/fo
    $ mkdir -p data/cache
    $ mkdir -p data/LazyServices/Proxy
    $ composer install -o
    # chown -R www-data:www-data data/
    # chmod -R 700 data/


### Back-end

The back-end is using [Laminas](https://getlaminas.org).

Create two symbolic links:

    $ mkdir -p module/Monarc
    $ cd module/Monarc
    $ ln -s ./../../vendor/monarc/core Core
    $ ln -s ./../../vendor/monarc/frontoffice FrontOffice
    $ cd ../..

There are 2 parts:

* Monarc\FrontOffice is only for MONARC;
* Monarc\Core is common to MONARC and to the back office of MONARC.


### Front-end

The frontend is an AngularJS application.

    $ mkdir node_modules
    $ cd node_modules
    $ git clone https://github.com/monarc-project/ng-client.git ng_client
    $ git clone https://github.com/monarc-project/ng-anr.git ng_anr

There are 2 parts:

* one only for MONARC: ng_client;
* one common for MONARC and the back office of MONARC: ng_anr.


## 2.2. Databases

### Create a MariaDB user for MONARC

With the root MariaDB user create a new user for MONARC:

    MariaDB [(none)]> CREATE USER 'monarc'@'%' IDENTIFIED BY 'password';
    MariaDB [(none)]> GRANT ALL PRIVILEGES ON * . * TO 'monarc'@'%';
    MariaDB [(none)]> FLUSH PRIVILEGES;

### Create 2 databases

In your MariaDB interpreter:

    MariaDB [(none)]> CREATE DATABASE monarc_cli DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
    MariaDB [(none)]> CREATE DATABASE monarc_common DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

* monarc_common contains models and data created by CASES;
* monarc_cli contains all client risk analyses. Each analysis is based on CASES
  model of monarc_common.

### Initializes the database

    $ mysql -u monarc -ppassword monarc_common < db-bootstrap/monarc_structure.sql
    $ mysql -u monarc -ppassword monarc_common < db-bootstrap/monarc_data.sql

### Database connection

Create the configuration file:

    $ cp ./config/autoload/local.php.dist ./config/autoload/local.php

And configure the database connection:

    return [
        'doctrine' => [
            'connection' => [
                'orm_default' => [
                    'params' => [
                        'host' => 'localhost',
                        'user' => 'monarc',
                        'password' => 'password',
                        'dbname' => 'monarc_common',
                    ],
                ],
                'orm_cli' => [
                    'params' => [
                        'host' => 'localhost',
                        'user' => 'monarc',
                        'password' => 'password',
                        'dbname' => 'monarc_cli',
                    ],
                ],
            ],
        ],
    ];


# 3. Update MONARC

Install Grunt:

    $ curl -sL https://deb.nodesource.com/setup_13.x | sudo bash -
    # apt-get install nodejs
    # npm install -g grunt-cli

then update MONARC:

    $ ./scripts/update-all.sh -c


# 4. Create initial user

    $ php ./vendor/robmorgan/phinx/bin/phinx seed:run -c ./module/Monarc/FrontOffice/migrations/phinx.php


The username is *admin@admin.localhost* and the password is *admin*.


# 5. Statistics for Global Dashboard

If you would like to use the global dashboard stats feature, you need to configure a StatsService on your server.
The architecture, installation instructions and GitHub project can be found here:

    https://monarc-stats-service.readthedocs.io/en/latest/architecture.html
    https://monarc-stats-service.readthedocs.io/en/latest/installation.html
    https://github.com/monarc-project/stats-service

The communication of access to the StatsService is performed on each instance of FrontOffice.
This includes the following lines change in your local.php file: 

    https://github.com/monarc-project/MonarcAppFO/blob/master/config/autoload/local.php.dist#L99-L102
