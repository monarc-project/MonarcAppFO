#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting MONARC FrontOffice setup...${NC}"

# Wait for database to be ready
echo -e "${YELLOW}Waiting for MariaDB to be ready...${NC}"
while ! mysqladmin ping -h"${DBHOST}" -u"${DBUSER_MONARC}" -p"${DBPASSWORD_MONARC}" --silent 2>/dev/null; do
    echo "Waiting for MariaDB..."
    sleep 2
done
echo -e "${GREEN}MariaDB is ready!${NC}"

# Check if this is the first run
if [ ! -f "/var/www/html/monarc/.docker-initialized" ]; then
    echo -e "${GREEN}First run detected, initializing application...${NC}"
    
    cd /var/www/html/monarc
    
    # Install composer dependencies
    if [ ! -d "vendor" ]; then
        echo -e "${YELLOW}Installing Composer dependencies...${NC}"
        composer install --ignore-platform-req=php
    fi
    
    # Create module symlinks
    echo -e "${YELLOW}Creating module symlinks...${NC}"
    mkdir -p module/Monarc
    cd module/Monarc
    ln -sfn ./../../vendor/monarc/core Core
    ln -sfn ./../../vendor/monarc/frontoffice FrontOffice
    cd /var/www/html/monarc
    
    # Clone frontend repositories
    echo -e "${YELLOW}Setting up frontend repositories...${NC}"
    mkdir -p node_modules
    cd node_modules
    
    if [ ! -d "ng_client" ]; then
        git clone --config core.fileMode=false https://github.com/monarc-project/ng-client.git ng_client
    fi
    
    if [ ! -d "ng_anr" ]; then
        git clone --config core.fileMode=false https://github.com/monarc-project/ng-anr.git ng_anr
    fi
    
    cd /var/www/html/monarc
    
    # Check if database exists and create if needed
    echo -e "${YELLOW}Setting up databases...${NC}"
    DB_EXISTS=$(mysql -h"${DBHOST}" -u"${DBUSER_MONARC}" -p"${DBPASSWORD_MONARC}" -e "SHOW DATABASES LIKE '${DBNAME_CLI}';" | grep -c "${DBNAME_CLI}" || true)
    
    if [ "$DB_EXISTS" -eq 0 ]; then
        echo -e "${YELLOW}Creating databases...${NC}"
        mysql -h"${DBHOST}" -u"${DBUSER_MONARC}" -p"${DBPASSWORD_MONARC}" -e "CREATE DATABASE ${DBNAME_CLI} DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
        mysql -h"${DBHOST}" -u"${DBUSER_MONARC}" -p"${DBPASSWORD_MONARC}" -e "CREATE DATABASE ${DBNAME_COMMON} DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
        
        echo -e "${YELLOW}Populating databases...${NC}"
        mysql -h"${DBHOST}" -u"${DBUSER_MONARC}" -p"${DBPASSWORD_MONARC}" ${DBNAME_COMMON} < db-bootstrap/monarc_structure.sql
        mysql -h"${DBHOST}" -u"${DBUSER_MONARC}" -p"${DBPASSWORD_MONARC}" ${DBNAME_COMMON} < db-bootstrap/monarc_data.sql
    fi
    
    # Generate local config if it doesn't exist
    if [ ! -f "config/autoload/local.php" ]; then
        echo -e "${YELLOW}Creating local configuration...${NC}"
        cat > config/autoload/local.php <<EOF
<?php
\$appdir = getenv('APP_DIR') ? getenv('APP_DIR') : '/var/www/html/monarc';
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
                    'host' => '${DBHOST}',
                    'user' => '${DBUSER_MONARC}',
                    'password' => '${DBPASSWORD_MONARC}',
                    'dbname' => '${DBNAME_COMMON}',
                ],
            ],
            'orm_cli' => [
                'params' => [
                    'host' => '${DBHOST}',
                    'user' => '${DBUSER_MONARC}',
                    'password' => '${DBPASSWORD_MONARC}',
                    'dbname' => '${DBNAME_CLI}',
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
        'baseUrl' => 'http://stats-service:5005',
        'apiKey' => '${STATS_API_KEY:-}',
    ],

    'import' => [
        'uploadFolder' => '\$appdir/data/import/files',
        'isBackgroundProcessActive' => false,
    ],
];
EOF
    fi
    
    # Update and build frontend
    echo -e "${YELLOW}Building frontend...${NC}"
    ./scripts/update-all.sh -d
    
    # Seed database with initial user
    echo -e "${YELLOW}Creating initial user and client...${NC}"
    php ./bin/phinx seed:run -c ./module/Monarc/FrontOffice/migrations/phinx.php
    
    # Set permissions
    echo -e "${YELLOW}Setting permissions...${NC}"
    chown -R www-data:www-data /var/www/html/monarc/data
    chmod -R 775 /var/www/html/monarc/data
    
    # Mark initialization as complete
    touch /var/www/html/monarc/.docker-initialized
    echo -e "${GREEN}Initialization complete!${NC}"
else
    echo -e "${GREEN}Application already initialized, starting services...${NC}"
fi

# Execute the main command
exec apachectl -D FOREGROUND
