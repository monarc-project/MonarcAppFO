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
while ! mysqladmin ping -h"${DBHOST}" -u"root" -p"${DBPASSWORD_ADMIN}" --silent 2>/dev/null; do
    echo "Waiting for MariaDB..."
    sleep 2
done
echo -e "${GREEN}MariaDB is ready!${NC}"

is_true() {
    case "$1" in
        1|true|yes|on) return 0 ;;
        *) return 1 ;;
    esac
}

# Check if this is the first run
if [ ! -f "/var/www/html/monarc/.docker-initialized" ]; then
    echo -e "${GREEN}First run detected, initializing application...${NC}"

    cd /var/www/html/monarc

    # Install composer dependencies (always, to ensure binaries like Phinx are present)
    echo -e "${YELLOW}Installing Composer dependencies...${NC}"
    composer install --ignore-platform-req=php --no-interaction

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

    # Check if CLI database exists and create databases if needed
    echo -e "${YELLOW}Setting up databases...${NC}"
    DB_EXISTS=$(mysql -h"${DBHOST}" -u"root" -p"${DBPASSWORD_ADMIN}" -e "SHOW DATABASES LIKE '${DBNAME_CLI}';" | grep -c "${DBNAME_CLI}" || true)
    USE_BO_COMMON_ENABLED=0
    if is_true "${USE_BO_COMMON}"; then
        USE_BO_COMMON_ENABLED=1
    fi

    if [ "$DB_EXISTS" -eq 0 ]; then
        echo -e "${YELLOW}Creating databases...${NC}"
        mysql -h"${DBHOST}" -u"root" -p"${DBPASSWORD_ADMIN}" -e "CREATE DATABASE IF NOT EXISTS ${DBNAME_CLI} DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"

        if [ "$USE_BO_COMMON_ENABLED" -eq 0 ]; then
            mysql -h"${DBHOST}" -u"root" -p"${DBPASSWORD_ADMIN}" -e "CREATE DATABASE IF NOT EXISTS ${DBNAME_COMMON} DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"

            echo -e "${YELLOW}Populating common database...${NC}"
            export MYSQL_PWD="${DBPASSWORD_MONARC}"
            mysql -h"${DBHOST}" -u"${DBUSER_MONARC}" ${DBNAME_COMMON} < db-bootstrap/monarc_structure.sql
            mysql -h"${DBHOST}" -u"${DBUSER_MONARC}" ${DBNAME_COMMON} < db-bootstrap/monarc_data.sql
        else
            echo -e "${YELLOW}USE_BO_COMMON is enabled; skipping monarc_common creation and bootstrap.${NC}"
        fi
    fi

    echo -e "${YELLOW}Ensuring privileges for ${DBUSER_MONARC}...${NC}"
    mysql -h"${DBHOST}" -u"root" -p"${DBPASSWORD_ADMIN}" -e "GRANT ALL PRIVILEGES ON ${DBNAME_CLI}.* TO '${DBUSER_MONARC}'@'%';"
    if [ "$USE_BO_COMMON_ENABLED" -eq 0 ]; then
        mysql -h"${DBHOST}" -u"root" -p"${DBPASSWORD_ADMIN}" -e "GRANT ALL PRIVILEGES ON ${DBNAME_COMMON}.* TO '${DBUSER_MONARC}'@'%';"
    fi
    mysql -h"${DBHOST}" -u"root" -p"${DBPASSWORD_ADMIN}" -e "FLUSH PRIVILEGES;"

    if [ "$USE_BO_COMMON_ENABLED" -eq 1 ]; then
        COMMON_EXISTS=$(mysql -h"${DBHOST}" -u"root" -p"${DBPASSWORD_ADMIN}" -e "SHOW DATABASES LIKE '${DBNAME_COMMON}';" | grep -c "${DBNAME_COMMON}" || true)
        if [ "$COMMON_EXISTS" -eq 0 ]; then
            echo -e "${RED}USE_BO_COMMON is enabled, but ${DBNAME_COMMON} was not found on ${DBHOST}.${NC}"
            echo -e "${RED}Ensure the BackOffice database is reachable and contains ${DBNAME_COMMON}.${NC}"
            exit 1
        fi
    fi

    # Generate local config (always override to match container DB)
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
        'uploadFolder' => '$appdir/data/import/files',
        'isBackgroundProcessActive' => false,
    ],
];
EOF

    # Update and build frontend and run DB migrations
    echo -e "${YELLOW}Building frontend and running DB migrations...${NC}"
    ./scripts/update-all.sh

    # Seed database with initial user
    echo -e "${YELLOW}Creating initial user and client...${NC}"
    php ./vendor/robmorgan/phinx/bin/phinx seed:run -c ./module/Monarc/FrontOffice/migrations/phinx.php

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
