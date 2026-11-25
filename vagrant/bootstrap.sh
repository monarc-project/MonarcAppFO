#!/usr/bin/env bash
set -eo pipefail

source /etc/os-release
if [[ "$ID" != ubuntu || "$VERSION_ID" != 26.04 ]]; then
    echo 'This bootstrap requires a fresh Ubuntu 26.04 Vagrant guest.' >&2
    exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

PATH_TO_MONARC='/home/vagrant/monarc'

ENVIRONMENT='development'

# MariaDB database
DBHOST='localhost'
DBNAME_COMMON='monarc_common'
DBNAME_CLI='monarc_cli'
DBUSER_MONARC='sqlmonarcuser'
DBPASSWORD_MONARC="sqlmonarcuser"

# PHP configuration
upload_max_filesize=200M
post_max_size=50M
max_execution_time=100
max_input_time=223
memory_limit=512M

PHP_INI=/etc/php/8.4/apache2/php.ini
XDEBUG_CFG=/etc/php/8.4/apache2/conf.d/20-xdebug.ini
MARIA_DB_CFG=/etc/mysql/mariadb.conf.d/50-server.cnf

# Stats service
STATS_PATH='/home/vagrant/stats-service'
STATS_HOST='0.0.0.0'
STATS_PORT='5005'
STATS_DB_NAME='statsservice'
STATS_DB_USER='sqlmonarcuser'
STATS_DB_PASSWORD="sqlmonarcuser"
STATS_SECRET_KEY="$(openssl rand -hex 32)"


export DEBIAN_FRONTEND=noninteractive
export LANGUAGE=C.UTF-8
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

echo -e "\n--- Installing now… ---\n"

echo -e "\n--- Updating packages list… ---\n"
sudo apt-get update
sudo apt-get upgrade -y

echo -e "\n--- Install base packages… ---\n"
sudo apt-get -y install vim zip unzip xz-utils git gettext curl ca-certificates gsfonts locales \
    build-essential python3 pkg-config libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev > /dev/null
sudo localedef -i en_US -f UTF-8 en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo -e "\n--- Install MariaDB specific packages and settings… ---\n"
sudo apt -y install mariadb-server mariadb-client

# Ubuntu's MariaDB root account uses local Unix-socket authentication.
sudo systemctl restart mariadb.service > /dev/null
sudo mariadb -u root <<'SQL'
DELETE FROM mysql.global_priv WHERE User = '';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db = 'test' OR Db LIKE 'test\_%';
FLUSH PRIVILEGES;
SQL

echo -e "\n--- Configuring… ---\n"
sudo sed -i "s/skip-external-locking/#skip-external-locking/g" $MARIA_DB_CFG
sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" $MARIA_DB_CFG
sudo sed -i "s/.*character-set-server.*/character-set-server = utf8mb4/" $MARIA_DB_CFG
sudo sed -i "s/.*collation-server.*/collation-server = utf8mb4_general_ci/" $MARIA_DB_CFG


echo -e "\n--- Setting up our MariaDB user for MONARC… ---\n"
sudo mariadb -u root -e "CREATE USER '$DBUSER_MONARC'@'%' IDENTIFIED BY '$DBPASSWORD_MONARC';"
sudo mariadb -u root -e "GRANT ALL PRIVILEGES ON * . * TO '$DBUSER_MONARC'@'%';"
sudo mariadb -u root -e "FLUSH PRIVILEGES;"
sudo systemctl restart mariadb.service > /dev/null

echo -e "\n--- Installing Apache… ---\n"
sudo apt install apache2 -y

echo -e "\n--- Installing PHP-specific packages… ---\n"
# Ubuntu 26.04 ships PHP 8.5; use the maintainer's repository for PHP 8.4.
php_keyring=$(mktemp)
curl -fsSL https://packages.sury.org/debsuryorg-archive-keyring.deb -o "$php_keyring"
sudo dpkg -i "$php_keyring" > /dev/null
rm -f "$php_keyring"
printf '%s\n' 'deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ resolute main' \
    | sudo tee /etc/apt/sources.list.d/php.list > /dev/null
sudo apt-get update > /dev/null
sudo apt-get install -y libapache2-mod-php8.4 php8.4 php8.4-cli php8.4-common php8.4-mysql \
    php8.4-zip php8.4-gd php8.4-mbstring php8.4-curl php8.4-xml php8.4-bcmath php8.4-intl \
    php8.4-imagick php8.4-xdebug > /dev/null || exit 1
if ! php8.4 -r 'exit(PHP_VERSION_ID >= 80428 && PHP_VERSION_ID < 80500 ? 0 : 1);'; then
    echo 'MONARC requires PHP >=8.4.28 <8.5.' >&2
    exit 1
fi
sudo update-alternatives --set php /usr/bin/php8.4 || exit 1
for php_module in /etc/apache2/mods-enabled/php*.load; do
    [ -e "$php_module" ] || continue
    php_module_name=$(basename "$php_module" .load)
    if [ "$php_module_name" != 'php8.4' ]; then
        sudo a2dismod "$php_module_name" > /dev/null || exit 1
    fi
done
sudo a2enmod php8.4 > /dev/null || exit 1

echo -e "\n--- Configuring PHP… ---\n"
for key in upload_max_filesize post_max_size max_execution_time max_input_time memory_limit
do
 sudo sed -i "s/^\($key\).*/\1 = $(eval echo \${$key})/" $PHP_INI
done
# session expires in 1 week:
sudo sed -i "s/^\(session\.gc_maxlifetime\).*/\1 = $(eval echo 604800)/" $PHP_INI
sudo sed -i "s/^\(session\.gc_probability\).*/\1 = $(eval echo 1)/" $PHP_INI
sudo sed -i "s/^\(session\.gc_divisor\).*/\1 = $(eval echo 1000)/" $PHP_INI

echo -e "\n--- Configuring Xdebug for development ---\n"
sudo bash -c "cat << EOF > $XDEBUG_CFG
zend_extension=xdebug.so
xdebug.mode=debug
xdebug.discover_client_host=1
xdebug.idekey=IDEKEY
EOF"

echo -e "\n--- Enabling mod-rewrite and ssl… ---\n"
sudo a2enmod rewrite > /dev/null 2>&1
sudo a2enmod ssl > /dev/null 2>&1
sudo a2enmod headers > /dev/null 2>&1

echo -e "\n--- Allowing Apache override to all ---\n"
sudo sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf


echo -e "\n--- Installing composer… ---\n"
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "\nERROR: unable to install composer\n"
    exit 1;
fi
sudo composer self-update

echo -e "\n--- Installing MONARC… ---\n"
cd $PATH_TO_MONARC
git config core.fileMode false

echo -e "\n--- Installing the dependencies… ---\n"
composer ins


# Make modules symlinks.
mkdir -p module/Monarc
cd module/Monarc
ln -sfn ./../../vendor/monarc/core Core
ln -sfn ./../../vendor/monarc/frontoffice FrontOffice
cd $PATH_TO_MONARC



# Front-end
echo -e "\n--- Installation of Node, NPM… ---\n"
# Keep the frontend build runtime aligned with the existing release images.
NODE_VERSION=16.20.2
case "$(dpkg --print-architecture)" in
    amd64) node_arch=x64 ;;
    arm64) node_arch=arm64 ;;
    *) echo 'The frontend build requires an amd64 or arm64 guest.' >&2; exit 1 ;;
esac
node_directory=$(mktemp -d)
node_archive="node-v${NODE_VERSION}-linux-${node_arch}.tar.xz"
curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/${node_archive}" -o "$node_directory/$node_archive"
curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt" -o "$node_directory/SHASUMS256.txt"
(cd "$node_directory" && sha256sum --check --ignore-missing SHASUMS256.txt)
sudo tar -xJf "$node_directory/$node_archive" -C /usr/local --strip-components=1 --no-same-owner
rm -rf "$node_directory"
node --version
npm --version
sudo npm install -g grunt-cli
# npm 8 bundles node-gyp 9, which relies on Python distutils removed in Ubuntu 26.04.
sudo npm explore npm/node_modules/@npmcli/run-script -g -- npm_config_global=false npm install node-gyp@10 --no-audit --no-fund

echo -e "\n--- Add a VirtualHost for MONARC ---\n"
sudo bash -c "cat << EOF > /etc/apache2/sites-enabled/000-default.conf
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot $PATH_TO_MONARC/public

    <Directory $PATH_TO_MONARC/public>
        DirectoryIndex index.php
        AllowOverride All
        Require all granted
    </Directory>

    <IfModule mod_headers.c>
       Header always set X-Content-Type-Options nosniff
       Header always set X-XSS-Protection '1; mode=block'
       Header always set X-Robots-Tag none
       Header always set X-Frame-Options SAMEORIGIN
    </IfModule>

    SetEnv APP_ENV $ENVIRONMENT
    SetEnv APP_DIR $PATH_TO_MONARC
</VirtualHost>
EOF"
echo -e "\n--- Restarting Apache… ---\n"
sudo systemctl restart apache2.service > /dev/null



echo -e "\n--- Installing the stats service… ---\n"
sudo apt-get -y install postgresql python3 python3-venv python3-poetry
sudo -u postgres psql -c "CREATE USER $STATS_DB_USER WITH PASSWORD '$STATS_DB_PASSWORD';"
sudo -u postgres psql -c "ALTER USER $STATS_DB_USER WITH SUPERUSER;"

cd ~
# Isolate the stats service from Ubuntu 26.04's newer system Python.
poetry python install 3.12

git clone https://github.com/monarc-project/stats-service $STATS_PATH
cd $STATS_PATH
npm ci
poetry env use 3.12
poetry install --only main --no-interaction

bash -c "cat << EOF > $STATS_PATH/instance/production.py
HOST = '$STATS_HOST'
PORT = $STATS_PORT
DEBUG = False
TESTING = False
INSTANCE_URL = 'http://127.0.0.1:$STATS_PORT'

ADMIN_EMAIL = 'info@cases.lu'
ADMIN_URL = 'https://www.cases.lu'

REMOTE_STATS_SERVER = 'https://dashboard.monarc.lu'

DB_CONFIG_DICT = {
    'user': '$STATS_DB_USER',
    'password': '$STATS_DB_PASSWORD',
    'host': 'localhost',
    'port': 5432,
}
DATABASE_NAME = '$STATS_DB_NAME'
SQLALCHEMY_DATABASE_URI = 'postgresql://{user}:{password}@{host}:{port}/{name}'.format(
    name=DATABASE_NAME, **DB_CONFIG_DICT
)
SQLALCHEMY_TRACK_MODIFICATIONS = False

SECRET_KEY = '$STATS_SECRET_KEY'

LOG_PATH = './var/stats.log'

MOSP_URL = 'https://objects.monarc.lu'
EOF"

export FLASK_APP=app.py
export STATS_CONFIG=production.py

FLASK_APP=app.py poetry run flask db_create
FLASK_APP=app.py poetry run flask db_init
FLASK_APP=app.py poetry run flask client_create --name ADMIN --role admin


sudo bash -c "cat << EOF > /etc/systemd/system/statsservice.service
[Unit]
Description=MONARC Stats service
After=network.target

[Service]
User=vagrant
Environment=LANG=en_US.UTF-8
Environment=LC_ALL=en_US.UTF-8
Environment=FLASK_APP=app.py
Environment=FLASK_ENV=production
Environment=STATS_CONFIG=production.py
Environment=FLASK_RUN_HOST=$STATS_HOST
Environment=FLASK_RUN_PORT=$STATS_PORT
WorkingDirectory=$STATS_PATH
ExecStart=/usr/bin/poetry run flask run
Restart=always

[Install]
WantedBy=multi-user.target
EOF"

sudo systemctl daemon-reload > /dev/null
sleep 1
sudo systemctl enable statsservice.service > /dev/null
sleep 3
sudo systemctl restart statsservice > /dev/null
#systemctl status statsservice.service

# Create a new client and set the apiKey.
cd $STATS_PATH ; apiKey=$(poetry run flask client_create --name admin_localhost | sed -nr 's/Token: (.*)$/\1/p')
cd $PATH_TO_MONARC


echo -e "\n--- Configuration of MONARC database connection ---\n"
cat > config/autoload/local.php <<EOF
<?php
\$appdir = getenv('APP_DIR') ? getenv('APP_DIR') : '$PATH_TO_MONARC';
\$string = file_get_contents(\$appdir.'/package.json');
if(\$string === FALSE) {
    \$string = file_get_contents('./package.json');
}
\$package_json = json_decode(\$string, true);

return [
    'doctrine' => [
        'connection' => [
            'orm_default' => [
                'params' => [
                    'host' => '$DBHOST',
                    'user' => '$DBUSER_MONARC',
                    'password' => '$DBPASSWORD_MONARC',
                    'dbname' => '$DBNAME_COMMON',
                ],
            ],
            'orm_cli' => [
                'params' => [
                    'host' => '$DBHOST',
                    'user' => '$DBUSER_MONARC',
                    'password' => '$DBPASSWORD_MONARC',
                    'dbname' => '$DBNAME_CLI',
                ],
            ],
        ],
    ],

    // Public base URL used to build absolute links (e.g. password reset). Must be an
    // absolute http(s) URL; never derived from the request Host header.
    'publicHost' => 'http://127.0.0.1:5001',

    'defaultLanguageIndex' => 1,

     // Languages available for the analysis / DB data.
    'languages' => [
        'fr' => ['index' => 1, 'label' => 'Français'],
        'en' => ['index' => 2, 'label' => 'English'],
        'de' => ['index' => 3, 'label' => 'Deutsch'],
        'nl' => ['index' => 4, 'label' => 'Dutch'],
    ],

    // Languages available for the user interface.
    'activeLanguages' => ['fr', 'en', 'de', 'nl', 'es', 'ro', 'it', 'ja', 'pl', 'pt', 'zh'],

    'appVersion' => \$package_json['version'],

    'checkVersion' => false,
    'appCheckingURL' => 'https://version.monarc.lu/check/MONARC',

    'email' => [
        'name' => 'MONARC',
        'from' => 'info@monarc.lu',
    ],

    'mospApiUrl' => 'https://objects.monarc.lu/api/',

    'monarc' => [
        'ttl' => 60, // timeout
    ],

    'statsApi' => [
        'baseUrl' => 'http://127.0.0.1:$STATS_PORT',
        'apiKey' => '$apiKey',
    ],

    'import' => [
        'uploadFolder' => '$PATH_TO_MONARC/data/import/files',
        'isBackgroundProcessActive' => false,
    ],
];
EOF


echo -e "\n--- Creation of the data bases… ---\n"
mysql -u $DBUSER_MONARC -p$DBPASSWORD_MONARC -e "CREATE DATABASE monarc_cli DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;" > /dev/null
mysql -u $DBUSER_MONARC -p$DBPASSWORD_MONARC -e "CREATE DATABASE monarc_common DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;" > /dev/null
echo -e "\n--- Populating MONARC DB… ---\n"
mysql -u $DBUSER_MONARC -p$DBPASSWORD_MONARC monarc_common < db-bootstrap/monarc_structure.sql > /dev/null
mysql -u $DBUSER_MONARC -p$DBPASSWORD_MONARC monarc_common < db-bootstrap/monarc_data.sql > /dev/null


echo -e "\n--- Creating cache folders for backend… ---\n"
mkdir -p $PATH_TO_MONARC/data/cache
mkdir -p $PATH_TO_MONARC/data/LazyServices/Proxy
mkdir -p $PATH_TO_MONARC/data/DoctrineORMModule/Proxy
mkdir -p $PATH_TO_MONARC/data/import/files


echo -e "\n--- Adjusting user mod… ---\n"
sudo usermod -aG www-data vagrant
sudo usermod -aG vagrant www-data


echo -e "\n--- Update the project… ---\n"
mkdir -p /home/vagrant/.config
sudo chown -R "$USER:$(id -gn "$USER")" /home/vagrant/.config
./scripts/install-frontend.sh
./scripts/link_modules_resources.sh
./scripts/compile_translations.sh
./scripts/upgrade-db.sh


echo -e "\n--- Create initial user and client ---\n"
php ./bin/phinx seed:run -c ./module/Monarc/FrontOffice/migrations/phinx.php

echo -e "\n--- Install and run mailcatcher ---\n"
sudo apt-get install -y build-essential software-properties-common
sudo apt-get install -y libsqlite3-dev ruby-dev
sudo gem install mailcatcher
sudo mailcatcher --http-ip 0.0.0.0


echo -e "\n--- Restarting Apache… ---\n"
sudo systemctl restart apache2.service > /dev/null


echo -e "MONARC is ready and available at http://127.0.0.1:5001"
echo -e "Stats service is ready and available at http://127.0.0.1:$STATS_PORT"
echo -e "Mailcatcher is available http://127.0.0.1:1080"
