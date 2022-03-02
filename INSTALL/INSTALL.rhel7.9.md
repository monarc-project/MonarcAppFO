<aside class="warning">
The core MONARC team cannot certify if this guide is working or not. Please help us in keeping it up to date and accurate.
</aside>


# RHEL Installation and preparation

## Install RHEL 7.9

## Register RHEL

```bash
[root@monarc ~]# subscription-manager register --username <un> --password <pw> --auto-attach
```

## Update Yum

```bash
[root@monarc ~]# yum update
```

## Install the epel repo - extra packages for enterprise Linux 7

```bash
[root@monarc ~]# yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
```

## Install Remis Rpm Repo for RH7

```bash
[root@monarc ~]# yum install https://rpms.remirepo.net/enterprise/remi-release-7.rpm
```

## Install php7.4, required modules & dependencies from Remi's repository:

```bash
[root@monarc ~]# yum install php74.x86_64 php74-php.x86_64 \
php74-php-gd.x86_64 php74-php-mysqlnd.x86_64 \
php74-php-mbstring.x86_64 php74-php-pear.noarch \
php74-php-pecl-apcu.x86_64 php74-php-xml.x86_64 php74-php-intl.x86_64 \
php74-php-pecl-imagick.x86_64 php74-php-pecl-zip.x86_64 \
php74-php-bcmath php74-php-mbstring.x86_64 php74-php-cli
```

## Update Git 1.8-2.3

```bash
[root@monarc fo]# yum remove git
[root@monarc fo]# yum -y install https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.9-1.x86_64.rpm
[root@monarc fo]# yum install git
```

## Update OpenSSH

```bash
[root@monarc fo]# wget https://kojipkgs.fedoraproject.org/vol/fedora_koji_archive02/packages/openssh/7.6p1/7.fc28/x86_64/openssh-7.6p1-7.fc28.x86_64.rpm
[root@monarc fo]# yum localinstall openssh-7.6p1-7.fc28.x86_64.rpm
```

## MariaDB

Update MariaDB to V10:

https://mariadb.com/docs/deploy/upgrade-community-server-cs105-rhel7/


```bash
[root@monarc ~]# subscription-manager repos --enable=rhel-7-server-optional-rpms
[root@monarc ~]# yum install php-mbstring php-intl
```

Secure the MariaDB installation:

```bash
[root@monarc ~]# systemctl start mariabdb
[root@monarc ~]# mysql_secure_installation
```

Add the following line to server.cnf (/etc/my.cnf.d/server.cnf)
otherwise you may get an error when initializing the database

```ini
[mariadb]

max_allowed_packet=8M
```

```sql
CREATE DATABASE monarc_cli DEFAULT CHARACTER SET utf8 DEFAULT COLLATE
utf8_general_ci;

CREATE DATABASE monarc_common DEFAULT CHARACTER SET utf8 DEFAULT
COLLATE utf8_general_ci;
```

## Restart Apache

```bash
[root@monarc ~]# systemctl restart httpd
```

# MONARC installation and configuration

## Install MONARC

```bash
[root@monarc ~]# mkdir -p /var/lib/monarc/fo
[root@monarc ~]# yum install git
[root@monarc ~]# git clone https://github.com/monarc-project/MonarcAppFO.git /var/lib/monarc/fo
[root@monarc ~]# cd /var/lib/monarc/fo
[root@monarc fo]# mkdir -p data/cache
[root@monarc fo]# mkdir -p data/LazyServices/Proxy
[root@monarc fo]# chmod -R g+w data
[root@monarc fo]# yum remove php-5.4.16 php-cli-5.4.16 php-common-5.4.16
```

## Install composer

```bash
[root@monarc fo]# curl https://getcomposer.org/installer --output composer-setup.php
[root@monarc fo]# php composer-setup.php --install-dir=/usr/bin/ --filename composer
[root@monarc fo]# rm composer-setup.php
```

## Install PHP 7.4

```bash
[root@monarc fo]# yum install php74-php-cli
```

## Configure path

```bash
[root@monarc fo]# export PATH=$PATH:/opt/remi/php74/root/usr/bin:/opt/remi/php74/root/usr/sbin
[root@monarc fo]# ln -s /usr/bin/php74 /usr/bin/php
```

## Update

```bash
[root@monarc fo]# composer self-update
[root@monarc fo]# composer install -o
```

## Prepare Backend

```bash
[root@monarc fo]# mkdir -p module/Monarc
[root@monarc Monarc]# cd module/Monarc
[root@monarc Monarc]# ln -s ./../../vendor/monarc/core Core
[root@monarc Monarc]# ln -s ./../../vendor/monarc/frontoffice FrontOffice
[root@monarc Monarc]# cd ../..
```

## Prepare Front-end

```bash
[root@monarc fo]# mkdir node_modules
[root@monarc fo]# cd node_modules
[root@monarc node_modules]# git clone https://github.com/monarc-project/ng-client.git ng_client
[root@monarc node_modules]# git clone https://github.com/monarc-project/ng-anr.git ng_anr
```

## Install Database

```bash
mysql -u root --p monarc_common < db-bootstrap/monarc_structure.sql
mysql -u root -p monarc_common < db-bootstrap/monarc_data.sql
```

## Create a database user for MONARC (in the interpreter)

```sql
create user 'monarc'@'localhost' identified by 'password';
grant create, delete, insert, select, update, drop, alter on monarc_common.* to 'monarc'@'localhost';
grant create, delete, insert, select, update, drop, alter on monarc_cli.* to 'monarc'@'localhost';
```

## Set up database connection

```bash
[root@monarc fo]# cd /var/lib/monarc/fo/config/autoload/
[root@monarc autoload]# cp local.php.dist local.php
[root@monarc autoload]# vi local.php
```

## Update database credentials

Reference: <https://github.com/nodesource/distributions>


## Install correct version of nodejs and grunt

```bash
[root@monarc fo]# yum remove -y nodejs npm
[root@monarc fo]# curl -fsSL https://rpm.nodesource.com/setup_16.x | bash -
[root@monarc fo]# yum install -y nodejs
[root@monarc fo]# npm install -g grunt grunt-cli
```

## Set git branch

```bash
[root@monarc fo]# git branch --set-upstream-to=origin/master v2.10.4
```

## Reconfigure SSH

/etc/ssh_config:

```cfg
StrictHostKeyChecking no
```

## Trigger the update script

```bash
[root@monarc fo]# ./scripts/update-all.sh -c
```

## Set permissions on MONARC website folder

```bash
[root@monarc fo]# cd /var/www/html/
[root@monarc html]# chown -R apache:apache monarc
```

## (Re)Start the show

```bash
[root@monarc fo]# cd /etc/httpd/conf.d/
[root@monarc conf.d]# vi monarc.conf
[root@monarc conf.d]# systemctl stop firewalld
[root@monarc conf.d]# systemctl restart httpd.service
```

## Create MONARC Admin User

```bash
[root@monarc fo]# php ./vendor/robmorgan/phinx/bin/phinx seed:run -c ./module/Monarc/FrontOffice/migrations/phinx.php
```

