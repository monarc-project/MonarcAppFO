#! /usr/bin/env bash

# Variables
GITHUB_AUTH_TOKEN=$1

BRANCH='master'
#BRANCH='v0.1'
#TAG='v0.1'
TAG=''

PATH_TO_MONARC='/home/ubuntu/monarc'

APPENV='local'
ENVIRONMENT='PRODUCTION'

DBHOST='localhost'
DBNAME_COMMON='monarc_common'
DBNAME_CLI='monarc_cli'
DBUSER_ADMIN='root'
DBPASSWORD_ADMIN="$(openssl rand -hex 32)"
DBUSER_MONARC='sqlmonarcuser'
DBPASSWORD_MONARC="$(openssl rand -hex 32)"

upload_max_filesize=200M
post_max_size=50M
max_execution_time=100
max_input_time=223
memory_limit=512M
PHP_INI=/etc/php/7.1/apache2/php.ini


export DEBIAN_FRONTEND=noninteractive
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales

echo -e "\n--- Installing MONARC FO… ---\n"

echo -e "\n--- Updating packages list… ---\n"
apt-get update

echo -e "\n--- Install base packages… ---\n"
apt-get -y install vim zip unzip git gettext > /dev/null

echo -e "\n--- Install MariaDB specific packages and settings… ---\n"
echo "mysql-server mysql-server/root_password password $DBPASSWORD_ADMIN" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DBPASSWORD_ADMIN" | debconf-set-selections
apt-get -y install mariadb-server mariadb-client > /dev/null
systemctl restart mariadb.service
sleep 5

echo -e "\n--- Installing PHP-specific packages… ---\n"
apt-get -y install php apache2 libapache2-mod-php php-curl php-gd php-mcrypt php-mysql php-pear php-apcu php-xml php-mbstring php-intl php-imagick php-zip > /dev/null

echo -e "\n--- Configuring PHP… ---\n"
for key in upload_max_filesize post_max_size max_execution_time max_input_time memory_limit
do
 sed -i "s/^\($key\).*/\1 = $(eval echo \${$key})/" $PHP_INI
done

echo -e "\n--- Enabling mod-rewrite and ssl… ---\n"
a2enmod rewrite > /dev/null 2>&1
a2enmod ssl > /dev/null 2>&1

echo -e "\n--- Allowing Apache override to all ---\n"
sudo sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

#echo -e "\n--- We want to see the PHP errors, turning them on ---\n"
#sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/apache2/php.ini
#sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/apache2/php.ini

echo -e "\n--- Setting up our MariaDB user for MONARC… ---\n"
mysql -u root -p$DBPASSWORD_ADMIN -e "CREATE USER '$DBUSER_MONARC'@'localhost' IDENTIFIED BY '$DBPASSWORD_MONARC';"
mysql -u root -p$DBPASSWORD_ADMIN -e "GRANT ALL PRIVILEGES ON * . * TO '$DBUSER_MONARC'@'localhost';"
mysql -u root -p$DBPASSWORD_ADMIN -e "FLUSH PRIVILEGES;"

echo -e "\n--- Installing composer… ---\n"
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "\nERROR: unable to install composer\n"
    exit 1;
fi
composer self-update

echo -e "\n--- Installing MONARC… ---\n"
cd $PATH_TO_MONARC
git config core.fileMode false
if [ "$TAG" != '' ]; then
    # Checkout the latest tag
    #latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
    git checkout $TAG
fi

echo -e "\n--- Retrieving MONARC libraries… ---\n"
composer config -g github-oauth.github.com $GITHUB_AUTH_TOKEN
composer install -o

# Modules
mkdir module
cd module
ln -s ./../vendor/monarc/core MonarcCore
ln -s ./../vendor/monarc/frontoffice MonarcFO
cd $PATH_TO_MONARC
cd module/MonarcFO/
git config core.fileMode false
cd $PATH_TO_MONARC
cd module/MonarcCore/
git config core.fileMode false
cd $PATH_TO_MONARC

# Interfaces
mkdir node_modules
cd node_modules
git clone --config core.filemode=false https://github.com/monarc-project/ng-client.git ng_client > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "\nERROR: unable to clone the ng-client repository\n"
    exit 1;
fi
git clone --config core.filemode=false https://github.com/monarc-project/ng-anr.git ng_anr > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "\nERROR: unable to clone the ng-anr repository\n"
    exit 1;
fi
cd ..


chown -R www-data $PATH_TO_MONARC
chgrp -R www-data $PATH_TO_MONARC
chmod -R 700 $PATH_TO_MONARC


echo -e "\n--- Add a VirtualHost for MONARC ---\n"
cat > /etc/apache2/sites-enabled/000-default.conf <<EOF
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot $PATH_TO_MONARC/public

    <Directory $PATH_TO_MONARC/public>
        DirectoryIndex index.php
        AllowOverride All
        Require all granted
    </Directory>

    SetEnv APPLICATION_ENV $ENVIRONMENT
    SetEnv APP_ENV $APPENV
    SetEnv APP_DIR $PATH_TO_MONARC
    SetEnv DB_HOST $DBHOST
    SetEnv DB_USER $DBUSER_MONARC
    SetEnv DB_PASS $DBPASSWORD_MONARC
</VirtualHost>
EOF
echo -e "\n--- Restarting Apache… ---\n"
service apache2 restart > /dev/null 2>&1


echo -e "\n--- Configuration of MONARC data base connection ---\n"
cat > config/autoload/local.php <<EOF
<?php
\$appdir = getenv('APP_DIR') ? getenv('APP_DIR') : '$PATH_TO_MONARC';
\$string = file_get_contents(\$appdir.'/package.json');
if(\$string === FALSE) {
    \$string = file_get_contents('./package.json');
}
\$package_json = json_decode(\$string, true);

return array(
    'doctrine' => array(
        'connection' => array(
            'orm_default' => array(
                'params' => array(
                    'host' => '$DBHOST',
                    'user' => '$DBUSER_MONARC',
                    'password' => '$DBPASSWORD_MONARC',
                    'dbname' => '$DBNAME_COMMON',
                ),
            ),
            'orm_cli' => array(
                'params' => array(
                    'host' => '$DBHOST',
                    'user' => '$DBUSER_MONARC',
                    'password' => '$DBPASSWORD_MONARC',
                    'dbname' => '$DBNAME_CLI',
                    ),
                ),
            ),
        ),

    /* Link with (ModuleCore)
    config['languages'] = [
        'fr' => array(
            'index' => 1,
            'label' => 'Français'
        ),
        'en' => array(
            'index' => 2,
            'label' => 'English'
        ),
        'de' => array(
            'index' => 3,
            'label' => 'Deutsch'
        ),
    ]
    */
    'activeLanguages' => array('fr','en','de','ne',),

    'appVersion' => \$package_json['version'],

    'email' => [
            'name' => 'MONARC',
            'from' => 'info@monarc.lu',
    ],

    'monarc' => array(
        'ttl' => 60, // timeout
        'salt' => '', // salt privé pour chiffrement pwd
    ),
);
EOF


echo -e "\n--- Creation of the data bases… ---\n"
mysql -u $DBUSER_MONARC -p$DBPASSWORD_MONARC -e "CREATE DATABASE monarc_cli DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;" > /dev/null
mysql -u $DBUSER_MONARC -p$DBPASSWORD_MONARC -e "CREATE DATABASE monarc_common DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;" > /dev/null
echo -e "\n--- Populating MONARC DB… ---\n"
mysql -u $DBUSER_MONARC -p$DBPASSWORD_MONARC monarc_common < db-bootstrap/monarc_structure.sql > /dev/null
mysql -u $DBUSER_MONARC -p$DBPASSWORD_MONARC monarc_common < db-bootstrap/monarc_data.sql > /dev/null


echo -e "\n--- Installation of Grunt… ---\n"
apt-get -y install nodejs > /dev/null
apt-get -y install npm > /dev/null
npm install -g grunt-cli > /dev/null
# ln -s /usr/bin/nodejs /usr/bin/node


echo -e "\n--- Update the project… ---\n"
/bin/bash ./scripts/update-all.sh > /dev/null


echo -e "\n--- Create initial user and client ---\n"
php ./vendor/robmorgan/phinx/bin/phinx seed:run -c ./module/MonarcFO/migrations/phinx.php


echo -e "\n--- Restarting Apache… ---\n"
systemctl restart apache2.service > /dev/null


echo -e "\n--- MONARC is ready! Point your Web browser to http://127.0.0.1:5001 ---\n"
