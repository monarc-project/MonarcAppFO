Skeleton Monarc Project
=======================

Introduction
------------
Skeleton Monarc Project.

Installation
------------

Using Composer (recommended)
----------------------------
The recommended way to get a working copy of this project is to clone the repository
and use `composer` to install dependencies using the `create-project` command:

    curl -s https://getcomposer.org/installer | php --
    php composer.phar create-project -sdev --repository-url="https://rhea.netlor.fr:3000/CASES/skeleton.git" monarc/skeleton-application path/to/install

Alternately, clone the repository and manually invoke `composer` using the shipped
`composer.phar`:

    cd my/project/dir
    git clone ssh://gogs@rhea.netlor.fr:2222/CASES/skeleton.git
    cd ZendSkeletonApplication
    php composer.phar self-update
    php composer.phar install -o

(The `self-update` directive is to ensure you have an up-to-date `composer.phar`
available.)

Web Server Setup
----------------

### PHP CLI Server

The simplest way to get started if you are using PHP 5.4 or above is to start the internal PHP cli-server in the root directory:

    php -S 0.0.0.0:8080 -t public/ public/index.php

This will start the cli-server on port 8080, and bind it to all network
interfaces.

**Note: ** The built-in CLI server is *for development only*.

### Apache Setup

To setup apache, setup a virtual host to point to the public/ directory of the
project and you should be ready to go! It should look something like below:

    <VirtualHost *:80>
        ServerName monarc.localhost
        DocumentRoot /path/to/monarc/public
        SetEnv APPLICATION_ENV "development"
        <Directory /path/to/monarc/public>
            DirectoryIndex index.php
            AllowOverride All
            Order allow,deny
            Allow from all
        </Directory>
    </VirtualHost>
