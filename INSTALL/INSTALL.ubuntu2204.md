Installation on Ubuntu 22.04
============================

# 1. Install LAMP & dependencies

## 1.1. Install system dependencies

```bash
sudo apt-get install zip unzip git gettext curl jq
```

Some might already be installed.

## 1.2. Install MariaDB

```bash
sudo apt-get install mariadb-client mariadb-server
```

### Secure the MariaDB installation

```bash
sudo mysql_secure_installation
```

Especially by setting a strong root password.

## 1.3. Install Apache2

```bash
sudo apt-get install apache2
```

### Enable modules, settings, and default of SSL in Apache

```bash
sudo a2dismod status
sudo a2enmod ssl
sudo a2enmod rewrite
sudo a2enmod headers
```

### Apache Virtual Host

Modify default Apache virtual host:

```bash
sudo vi /etc/apache2/sites-enabled/000-default.conf
```

With this configuration:

```conf
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

    SetEnv APP_ENV "development"
</VirtualHost>
```

## 1.4. Install PHP and dependencies (It's recommended to install php8 or php8.1 and all the modules of the version)

```bash
sudo apt-get install php apache2 libapache2-mod-php php-curl php-gd php-mysql php-pear php-xml php-mbstring php-intl php-imagick php-zip php-bcmath
```

## 1.5 Apply PHP configuration settings in your php.ini

Edit php.ini file

```bash
sudo vi /etc/php/8.1/apache2/php.ini
```
Change these keys:

```php
upload_max_filesize = 200M
post_max_size = 50M
max_execution_time = 100
max_input_time = 223
memory_limit = 512M
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_NOTICE & ~E_WARNING
```

## 1.6 Apply all changes

```bash
sudo systemctl restart apache2.service
```

# 2. Installation of MONARC

```bash
PATH_TO_MONARC='/var/lib/monarc/fo'
PATH_TO_MONARC_DATA='/var/lib/monarc/fo-data'
MONARC_VERSION=$(curl --silent -H 'Content-Type: application/json' https://api.github.com/repos/monarc-project/MonarcAppFO/releases/latest | jq  -r '.tag_name')
MONARCFO_RELEASE_URL="https://github.com/monarc-project/MonarcAppFO/releases/download/$MONARC_VERSION/MonarcAppFO-$MONARC_VERSION.tar.gz"

mkdir -p /var/lib/monarc/releases/
# Download release
curl -sL $MONARCFO_RELEASE_URL -o /var/lib/monarc/releases/`basename $MONARCFO_RELEASE_URL`
# Create release directory
mkdir /var/lib/monarc/releases/`basename $MONARCFO_RELEASE_URL | sed 's/.tar.gz//'`
# Unarchive release
tar -xzf /var/lib/monarc/releases/`basename $MONARCFO_RELEASE_URL` -C /var/lib/monarc/releases/`basename $MONARCFO_RELEASE_URL | sed 's/.tar.gz//'`
# Create release symlink
ln -s /var/lib/monarc/releases/`basename $MONARCFO_RELEASE_URL | sed 's/.tar.gz//'` $PATH_TO_MONARC
# Create data and caches directories
mkdir -p $PATH_TO_MONARC_DATA/cache $PATH_TO_MONARC_DATA/DoctrineORMModule/Proxy $PATH_TO_MONARC_DATA/LazyServices/Proxy $PATH_TO_MONARC_DATA/import/files
# Create data directory symlink
ln -s $PATH_TO_MONARC_DATA $PATH_TO_MONARC/data
```

## 2.1 Change owner

```bash
sudo chown -R www-data:www-data /var/lib/monarc
```


## 2.2. Databases

### Create a MariaDB user for MONARC

Start MariaDB as root:

```bash
sudo mysql
```

Create a new user for MONARC:

```sql
CREATE USER 'monarc'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON * . * TO 'monarc'@'%';
FLUSH PRIVILEGES;
```

### Create 2 databases

In your MariaDB interpreter:

```sql
CREATE DATABASE monarc_cli DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE monarc_common DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
```

* monarc_common contains models and data created by CASES;
* monarc_cli contains all client risk analyses. Each analysis is based on CASES
  model of monarc_common.

### Initializes the database

```bash
cd /var/lib/monarc/releases/MonarcAppFO-$MONARC_VERSION
mysql -u monarc -ppassword monarc_common < db-bootstrap/monarc_structure.sql
mysql -u monarc -ppassword monarc_common < db-bootstrap/monarc_data.sql
```

### Database connection

Create the configuration file:

```bash
sudo cp ./config/autoload/local.php.dist ./config/autoload/local.php
```

And configure the database connection:

```php
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
```

# 3. Migrating MONARC DB

```bash
php ./vendor/robmorgan/phinx/bin/phinx migrate -c module/Monarc/FrontOffice/migrations/phinx.php
php ./vendor/robmorgan/phinx/bin/phinx migrate -c module/Monarc/Core/migrations/phinx.php
```


# 4. Create initial user

```bash
php ./vendor/robmorgan/phinx/bin/phinx seed:run -c ./module/Monarc/FrontOffice/migrations/phinx.php
```

The username is *admin@admin.localhost* and the password is *admin*.


# 5. Statistics for Global Dashboard

If you would like to use the global dashboard stats feature, you need to
configure a Stats Service instance on your server.

The architecture, installation instructions and GitHub project can be found here:

- https://www.monarc.lu/documentation/stats-service/master/architecture.html
- https://www.monarc.lu/documentation/stats-service/master/installation.html
- https://github.com/monarc-project/stats-service

The communication of access to the StatsService is performed on each instance of
FrontOffice (clients).
