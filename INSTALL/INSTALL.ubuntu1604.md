Installation on Ubuntu 16.04
============================

# 1. Install LAMP & dependencies

## Install the dependencies

    $ sudo apt-get install vim zip unzip git gettext curl net-tools gsfonts curl

Some might already be installed.

## Install MariaDB

    $ sudo apt-get install mariadb-client mariadb-server

# Secure the MariaDB installation

    $ sudo mysql_secure_installation

Especially by setting a strong root password.

## Install Apache2

    $ sudo apt-get install apache2 apache2-doc apache2-utils

## Enable modules, settings, and default of SSL in Apache

    $ sudo a2dismod status
    $ sudo a2enmod ssl
    $ sudo a2enmod rewrite
    $ sudo a2enmod headers

## Apache Virtual Host

    <VirtualHost *:80>
        ServerName monarc.localhost
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

        SetEnv APP_ENV "development"
    </VirtualHost>


## Install PHP and dependencies

    $ sudo apt-get install php apache2 libapache2-mod-php php-curl php-gd php-mcrypt php-mysql php-pear php-apcu php-xml php-mbstring php-intl php-imagick php-zip

## Apply all changes

    $ sudo systemctl restart apache2.service



# 2. Installation of MONARC

## MONARC code

Clone the repository and invoke `composer` using the shipped `composer.phar`:

    $ cd /var/lib/monarc/
    $ git clone https://github.com/monarc-project/MonarcAppFO.git fo
    $ cd fo/
    $ chown -R www-data data
    $ chmod -R g+w data
    $ php composer.phar self-update
    $ php composer.phar install -o

The `self-update` directive is to ensure you have an up-to-date `composer.phar`
available.


### Backend

The backend is not directly modules of the project but libraries.
You must create modules with symbolic links to libraries.

Create two symbolic links:

    $ cd module/Monarc
    $ ln -s ./../../vendor/monarc/core Core
    $ ln -s ./../../vendor/monarc/frontoffice FrontOffice
    $ cd ../..

There are 2 parts:

* Monarc\FrontOffice is only for front office;
* Monarc\Core is common to the front office and to the back office.


### Frontend

The frontend is an AngularJS application.

    $ mkdir node_modules
    $ cd node_modules
    $ git clone https://github.com/monarc-project/ng-client.git ng_client
    $ git clone https://github.com/monarc-project/ng-anr.git ng_anr

There are 2 parts:

* one only for front office: ng_client;
* one common for front office and back office: ng_anr.


## Databases

### Change SQL Mode in my.cnf

    [mysqld]
    sql-mode = MYSQL40

### Create 2 databases

    CREATE DATABASE monarc_cli DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
    CREATE DATABASE monarc_common DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

* monarc_common contains models and data created by CASES;
* monarc_cli contains all client risk analyses. Each analysis is based on CASES
  model of monarc_common.

### Initializes the database

    $ mysql -u user monarc_common < db-bootstrap/monarc_structure.sql
    $ mysql -u user monarc_common < db-bootstrap/monarc_data.sql

### Database connection

Create the configuration file:

    $ sudo cp ./config/autoload/local.php.dist ./config/autoload/local.php

And configure the database connection:

    return array(
        'doctrine' => array(
            'connection' => array(
                'orm_default' => array(
                    'params' => array(
                        'host' => 'host',
                        'user' => 'user',
                        'password' => 'password',
                        'dbname' => 'monarc_common',
                    ),
                ),
                'orm_cli' => array(
                    'params' => array(
                        'host' => 'host',
                        'user' => 'user',
                        'password' => 'password',
                        'dbname' => 'monarc_cli',
                    ),
                ),
            ),
        ),
    );



# Update MONARC

## Install Grunt

    $ sudo apt-get install nodejs
    $ sudo apt-get install npm
    $ sudo npm install -g grunt-cli
    $ sudo ln -s /usr/bin/nodejs /usr/bin/node


Update MONARC:

    $ ./scripts/update-all.sh

This script will retrieve the updates from the last stable release of MONARC,
execute the database migration scripts and compile the translations.


# Create initial user

    $ php ./vendor/robmorgan/phinx/bin/phinx seed:run -c ./module/Monarc/FrontOffice/migrations/phinx.php


The username is *admin@admin.localhost* and the password is *admin*.
