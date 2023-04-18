#! /usr/bin/env bash

PATH_TO_MONARC_FO=$HOME/MonarcAppFO
PATH_TO_MONARC_BO=$HOME/MonarcAppBO

APPENV='local'
ENVIRONMENT='development'

# MariaDB database
DBHOST='localhost'
DBNAME_COMMON='monarc_common'
DBNAME_MASTER='monarc_master'
DBNAME_CLI='monarc_cli'
DBUSER_ADMIN='root'
DBPASSWORD_ADMIN='root'
DBUSER_MONARC='sqlmonarcuser'
DBPASSWORD_MONARC='sqlmonarcuser'

# PHP configuration
upload_max_filesize=200M
post_max_size=50M
max_execution_time=100
max_input_time=223
memory_limit=512M

PHP_INI=/etc/php/8.1/apache2/php.ini
XDEBUG_CFG=/etc/php/8.1/apache2/conf.d/20-xdebug.ini
MARIA_DB_CFG=/etc/mysql/mariadb.conf.d/50-server.cnf

# Stats service
STATS_PATH=$HOME/stats-service
STATS_HOST='0.0.0.0'
STATS_PORT='5005'
STATS_DB_NAME='statsservice'
STATS_DB_USER='sqlmonarcuser'
STATS_DB_PASSWORD="sqlmonarcuser"
STATS_SECRET_KEY="$(openssl rand -hex 32)"

echo -e "\n--- Installing now… ---\n"
sudo chmod 755 $HOME
sudo apt-get update > /dev/null 2>&1

echo -e "\n--- Updating packages list… ---\n"
sudo apt-get upgrade -y > /dev/null 2>&1

echo -e "\n--- Install base packages… ---\n"
sudo apt-get -y install vim zip unzip git gettext curl gsfonts > /dev/null


echo -e "\n--- Install MariaDB specific packages and settings… ---\n"
sudo apt-get -y install mariadb-server mariadb-client > /dev/null
# Secure the MariaDB installation (especially by setting a strong root password)
sudo service mariadb restart > /dev/null
sleep 5
sudo mysql_secure_installation > /dev/null 2>&1 <<EOF

y
$DBPASSWORD_ADMIN
$DBPASSWORD_ADMIN
y
y
y
y
EOF

echo -e "\n--- Configuring MariaDB… ---\n"
sudo sed -i "s/skip-external-locking/#skip-external-locking/g" $MARIA_DB_CFG
sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" $MARIA_DB_CFG

echo -e "\n--- Setting up our MariaDB user for MONARC… ---\n"
sudo mysql -u root -p$DBPASSWORD_ADMIN -e "CREATE USER '$DBUSER_MONARC'@'%' IDENTIFIED BY '$DBPASSWORD_MONARC';"
sudo mysql -u root -p$DBPASSWORD_ADMIN -e "GRANT ALL PRIVILEGES ON * . * TO '$DBUSER_MONARC'@'%';"
sudo mysql -u root -p$DBPASSWORD_ADMIN -e "FLUSH PRIVILEGES;"
sudo service mariadb restart > /dev/null

echo -e "\n--- Installing PHP-specific packages… ---\n"
sudo apt-get -y install php apache2 libapache2-mod-php php-curl php-gd php-mysql php-pear php-apcu php-xml php-mbstring php-intl php-zip php-xdebug php-bcmath > /dev/null 2>&1

echo -e "\n--- Configuring PHP… ---\n"
for key in upload_max_filesize post_max_size max_execution_time max_input_time memory_limit
do
 sudo sed -i "s/^\($key\).*/\1 = $(eval echo \${$key})/" $PHP_INI
done

echo -e "\n--- Configuring Xdebug for development ---\n"
sudo bash -c "cat << EOF > $XDEBUG_CFG
zend_extension=xdebug.so
xdebug.remote_enable=1
xdebug.remote_connect_back=1
xdebug.idekey=IDEKEY
EOF"

echo -e "\n--- Enabling mod-rewrite and ssl… ---\n"
sudo a2enmod rewrite > /dev/null 2>&1
sudo a2enmod ssl > /dev/null 2>&1
sudo a2enmod headers > /dev/null 2>&1

echo -e "\n--- Configuring Apache  ---\n"
sudo sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
sudo bash -c "cat << EOF >> /etc/apache2/apache2.conf
AcceptFilter https none
AcceptFilter http none
EOF"

echo -e "\n--- Installing composer… ---\n"
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "\nERROR: unable to install composer\n"
    exit 1;
fi


echo -e "\n--- Installing MONARC … ---\n"
cd $PATH_TO_MONARC_FO
git config core.fileMode false


echo -e "\n--- Installing the FO dependencies… ---\n"
composer ins > /dev/null 2>&1


# Make modules symlinks.
mkdir -p module/Monarc
cd module/Monarc
ln -sfn ./../../vendor/monarc/core Core
ln -sfn ./../../vendor/monarc/frontoffice FrontOffice
cd $PATH_TO_MONARC_FO



# Front-end
mkdir -p node_modules
cd node_modules
if [ ! -d "ng_client" ]; then
  git clone --config core.fileMode=false https://github.com/monarc-project/ng-client.git ng_client > /dev/null 2>&1
fi
if [ $? -ne 0 ]; then
    echo "\nERROR: unable to clone the ng-client repository\n"
    exit 1;
fi
if [ ! -d "ng_anr" ]; then
  git clone --config core.fileMode=false https://github.com/monarc-project/ng-anr.git ng_anr > /dev/null 2>&1
fi
if [ $? -ne 0 ]; then
    echo "\nERROR: unable to clone the ng-anr repository\n"
    exit 1;
fi

cd $PATH_TO_MONARC_BO
git config core.fileMode false

echo -e "\n--- Installing the BO dependencies… ---\n"
composer ins > /dev/null 2>&1


# Make modules symlinks.
mkdir -p module/Monarc
cd module/Monarc
ln -sfn ./../../vendor/monarc/core Core
ln -sfn ./../../vendor/monarc/backoffice BackOffice
cd $PATH_TO_MONARC_BO


# Front-end
mkdir -p node_modules
cd node_modules
if [ ! -d "ng_client" ]; then
  git clone --config core.fileMode=false https://github.com/monarc-project/ng-backoffice.git ng_backoffice  > /dev/null 2>&1
fi
if [ $? -ne 0 ]; then
    echo "\nERROR: unable to clone the ng-client repository\n"
    exit 1;
fi
if [ ! -d "ng_anr" ]; then
  git clone --config core.fileMode=false https://github.com/monarc-project/ng-anr.git ng_anr > /dev/null 2>&1
fi
if [ $? -ne 0 ]; then
    echo "\nERROR: unable to clone the ng-anr repository\n"
    exit 1;
fi
cd ..



echo -e "\n--- Add a VirtualHost for MONARC ---\n"
sudo bash -c "cat << EOF > /etc/apache2/sites-enabled/000-default.conf
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot $PATH_TO_MONARC_FO/public

    <Directory $PATH_TO_MONARC_FO/public>
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
    SetEnv APP_DIR $PATH_TO_MONARC_FO
</VirtualHost>

Listen 8080

<VirtualHost *:8080>
    ServerName localhost
    DocumentRoot $PATH_TO_MONARC_BO/public

    <Directory $PATH_TO_MONARC_BO/public>
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
    SetEnv APP_DIR $PATH_TO_MONARC_BO
</VirtualHost>
EOF"

echo -e "\n--- Restarting Apache… ---\n"
sudo service apache2 restart > /dev/null


echo -e "\n--- Installation of Node, NPM and Grunt… ---\n"
curl -sL https://deb.nodesource.com/setup_15.x | sudo bash - > /dev/null 2>&1
sudo apt-get install -y nodejs > /dev/null 2>&1
sudo npm install -g grunt-cli > /dev/null 2>&1


echo -e "\n--- Installing the stats service… ---\n"
sudo apt-get -y install postgresql python3-pip python3-venv > /dev/null 2>&1
sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 10 > /dev/null 2>&1
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 20 > /dev/null 2>&1
sudo service postgresql restart > /dev/null
sudo -u postgres psql -c "CREATE USER $STATS_DB_USER WITH PASSWORD '$STATS_DB_PASSWORD';" > /dev/null
sudo -u postgres psql -c "ALTER USER $STATS_DB_USER WITH SUPERUSER;" > /dev/null

cd ~
curl -sSL https://install.python-poetry.org | python3 - > /dev/null > /dev/null
echo  'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
echo  'export FLASK_APP=runserver.py' >> ~/.bashrc
echo  'export STATS_CONFIG=production.py' >> ~/.bashrc

git clone https://github.com/monarc-project/stats-service $STATS_PATH > /dev/null 2>&1
cd $STATS_PATH
export PATH="$PATH:$HOME/.local/bin"
export FLASK_APP=runserver.py
export STATS_CONFIG=production.py
npm ci > /dev/null 2>&1
poetry install --no-dev > /dev/null

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

FLASK_APP=runserver.py poetry run flask db_create
FLASK_APP=runserver.py poetry run flask db_init
FLASK_APP=runserver.py poetry run flask client_create --name ADMIN --role admin
FLASK_APP=runserver.py poetry run nohup python runserver.py > /dev/null 2>&1 &

# Create a new client and set the apiKey.
cd $STATS_PATH ; apiKey=$(poetry run flask client_create --name admin_localhost | sed -nr 's/Token: (.*)$/\1/p')

echo -e "\n--- Configuration of MONARC database connection ---\n"
cat > $PATH_TO_MONARC_FO/config/autoload/local.php <<EOF
<?php
\$appdir = getenv('APP_DIR') ? getenv('APP_DIR') : '$PATH_TO_MONARC_FO';
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

    'activeLanguages' => array('fr','en','de','nl','es','ro','it','ja','pl','pt','ru','zh'),

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
        'salt' => '', // private salt for password encryption
    ],

    'statsApi' => [
        'baseUrl' => 'http://127.0.0.1:$STATS_PORT',
        'apiKey' => '$apiKey',
    ],

    'import' => [
        'uploadFolder' => '$appdir/data/import/files',
        'isBackgroundProcessActive' => false,
    ],
];
EOF

cat > $PATH_TO_MONARC_BO/config/autoload/local.php <<EOF
<?php
\$appdir = getenv('APP_DIR') ? getenv('APP_DIR') : '$PATH_TO_MONARC_BO';
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
                    'dbname' => '$DBNAME_MASTER',
                ],
            ],
        ],
    ],

    'activeLanguages' => array('fr','en','de','nl'),

    'appVersion' => \$package_json['version'],

    'checkVersion' => false,
    'appCheckingURL' => 'https://version.monarc.lu/check/MONARC',

    'monarc' => [
        'ttl' => 60, // timeout
        'salt' => '', // private salt for password encryption
    ],

];
EOF


echo -e "\n--- Creation of the data bases… ---\n"
mysql -u $DBUSER_MONARC -p$DBPASSWORD_MONARC -e "CREATE DATABASE monarc_cli DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;" > /dev/null
mysql -u $DBUSER_MONARC -p$DBPASSWORD_MONARC -e "CREATE DATABASE monarc_master DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;" > /dev/null
mysql -u $DBUSER_MONARC -p$DBPASSWORD_MONARC -e "CREATE DATABASE monarc_common DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;" > /dev/null
echo -e "\n--- Populating MONARC DB… ---\n"
mysql -u $DBUSER_MONARC -p$DBPASSWORD_MONARC monarc_common < $PATH_TO_MONARC_FO/db-bootstrap/monarc_structure.sql > /dev/null
mysql -u $DBUSER_MONARC -p$DBPASSWORD_MONARC monarc_common < $PATH_TO_MONARC_FO/db-bootstrap/monarc_data.sql > /dev/null


echo -e "\n--- Creating cache folders for backend… ---\n"
mkdir -p $PATH_TO_MONARC_FO/data/cache
mkdir -p $PATH_TO_MONARC_FO/data/LazyServices/Proxy
mkdir -p $PATH_TO_MONARC_FO/data/DoctrineORMModule/Proxy
mkdir -p $$PATH_TO_MONARC_FO/data/import/files
chmod -R g+w $PATH_TO_MONARC_FO/data
mkdir -p $PATH_TO_MONARC_BO/data/cache
mkdir -p $PATH_TO_MONARC_BO/data/LazyServices/Proxy
mkdir -p $PATH_TO_MONARC_BO/data/DoctrineORMModule/Proxy
chmod -R g+w $PATH_TO_MONARC_BO/data
sudo chown -R www-data:www-data $PATH_TO_MONARC_FO/data
sudo chown -R www-data:www-data $PATH_TO_MONARC_BO/data


echo -e "\n--- Update the projects… ---\n"
cd $PATH_TO_MONARC_FO ; ./scripts/update-all.sh -d
cd $PATH_TO_MONARC_BO ; ./scripts/update-all.sh


echo -e "\n--- Create initial user and client ---\n"
cd $PATH_TO_MONARC_FO
php ./bin/phinx seed:run -c ./module/Monarc/FrontOffice/migrations/phinx.php
cd $PATH_TO_MONARC_BO
php ./bin/phinx seed:run -c ./module/Monarc/BackOffice/migrations/phinx.php
cd ~

echo -e "\n--- Restarting Apache… ---\n"
sudo service apache2 restart > /dev/null

echo -e "\n--- Adding autostart Services ---\n"
cat >> ~/.bashrc <<EOF
# Autostart services
wsl.exe -u root service mariadb start > /dev/null
wsl.exe -u root service apache2 start > /dev/null
wsl.exe -u root service postgresql start > /dev/null
cd ~/stats-service/ ; poetry run nohup python runserver.py > /dev/null 2>&1 &
cd ~
EOF

echo -e "MONARC FO is ready and available at http://localhost"
echo -e "MONARC BO is ready and available at http://localhost:8080"
echo -e "Stats service is ready and available at http://localhost:$STATS_PORT"
echo -e "user: admin@admin.localhost / password: admin"
