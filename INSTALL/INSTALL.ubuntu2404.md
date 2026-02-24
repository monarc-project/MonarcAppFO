Installation on Ubuntu 24.04
============================

# 1. Dependencies 

Install some utilities, database, webserver
```bash
sudo apt update
sudo apt-get install -y curl jq mariadb-client mariadb-server apache2
```

Install PHP and its dependencies (the default php version in Ubuntu 24.04 is php8.3):
```bash
sudo apt-get install -y php php-cli php-common php-mysql php-zip php-gd php-mbstring php-curl php-xml php-bcmath php-intl php-imagick
```

# 2. Monarc files

Run the [get_and_unpack_the_latest_release.sh](./get_and_unpack_the_latest_release.sh) script with `sudo`
 to download the latest Monarc release and unpack it into `/var/lib/monarc/`.

> The script is built to be used in the CI/CD pipelines and will fail with a clear error if the release is not reachable or the deploy directory already exits.

# 3. Webserver

Enable required Apache modules:

```bash
sudo a2dismod status
sudo a2enmod ssl
sudo a2enmod rewrite
sudo a2enmod headers
```

Modify the default virtual host:

```bash
sudo nano /etc/apache2/sites-enabled/000-default.conf
```

Use this configuration as an example:

```conf
<VirtualHost _default_:80>
    ServerAdmin admin@example.com
    ServerName monarc.local
    DocumentRoot /var/lib/monarc/fo/public

    <Directory /var/lib/monarc/fo/public>
        DirectoryIndex index.php
        AllowOverride All
        Require all granted
        
        # increase the default php limits
        # better here then in the global php.ini as the webserver could run other projects
        php_value upload_max_filesize 200M
        php_value post_max_size 50M
        php_value max_execution_time 100
        php_value max_input_time 223
        php_value memory_limit 512M
        # Error logs settings for production:
        php_value error_reporting E_ALL
        php_flag log_errors On
        # for development, set to "On"
        php_flag display_errors Off

    </Directory>

    <IfModule mod_headers.c>
       Header always set X-Content-Type-Options nosniff
       Header always set X-XSS-Protection "1; mode=block"
       Header always set X-Robots-Tag none
       Header always set X-Frame-Options SAMEORIGIN
    </IfModule>

    SetEnv APP_ENV "production"
</VirtualHost>
```

Check the configuration and apply changes:

```bash
apachectl configtest
sudo apachectl restart
```


# 4. Database

Secure the MariaDB installation and set a strong root password.

```bash
sudo mysql_secure_installation
```

## 4.1 Create a database user

Start MariaDB as root:

```bash
sudo mysql
```

Create a new user for MONARC (please use more secured password):

```sql
CREATE USER 'monarc'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON monarc_cli.* TO 'monarc'@'%';
GRANT ALL PRIVILEGES ON monarc_common.* TO 'monarc'@'%';
FLUSH PRIVILEGES;
```

## 4.2 Create 2 databases

In your MariaDB interpreter:

```sql
CREATE DATABASE monarc_cli DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE monarc_common DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
```

* monarc_common contains models and data created by CASES;
* monarc_cli contains all client risk analyses. Each analysis is based on CASES model of monarc_common.

## 4.3 Initialize the database

```bash
cd /var/lib/monarc/fo
mysql -u monarc -ppassword monarc_common < db-bootstrap/monarc_structure.sql
mysql -u monarc -ppassword monarc_common < db-bootstrap/monarc_data.sql
```

## 4.4 Connect Monarc App to the database

Create and edit the configuration file:

```bash
sudo cp ./config/autoload/local.php.dist ./config/autoload/local.php
sudo nano ./config/autoload/local.php
```

Configure the database connection (use the secured password set on the DB user creation step):

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

## 4.5 Migrate the MONARC DB

```bash
php ./vendor/robmorgan/phinx/bin/phinx migrate -c module/Monarc/FrontOffice/migrations/phinx.php
php ./vendor/robmorgan/phinx/bin/phinx migrate -c module/Monarc/Core/migrations/phinx.php
```


## 4.6 Create initial user

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

The Virtual Machine installation script could be used to detail more steps in case of additional configuration necessity:
https://github.com/monarc-project/monarc-packer/blob/ubuntu-22.04/scripts/bootstrap.sh

The communication of access to the StatsService is performed on each instance of
FrontOffice (clients).
