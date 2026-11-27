#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting MONARC FrontOffice setup...${NC}"

# Validate first-run public URL configuration before any database or dependency changes.
if [ ! -f "/var/www/html/monarc/.docker-initialized" ]; then
    : "${PUBLIC_HOST:?PUBLIC_HOST must be set to the public base URL, e.g. https://monarc.example.org}"
    PUBLIC_HOST_PHP=$(php -r '
        $url = getenv("PUBLIC_HOST");
        if (filter_var($url, FILTER_VALIDATE_URL) === false
            || !preg_match("#^https?://#i", $url)
            || strpbrk($url, "@?#") !== false
        ) {
            fwrite(STDERR, "PUBLIC_HOST must be an absolute http(s) URL without credentials, a query string or a fragment.\n");
            exit(1);
        }
        echo var_export($url, true);
    ')
fi

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

CAPTCHA_ENABLED_PHP=false
if is_true "${CAPTCHA_ENABLED:-false}"; then
    CAPTCHA_ENABLED_PHP=true
fi

# Check if this is the first run
if [ ! -f "/var/www/html/monarc/.docker-initialized" ]; then
    echo -e "${GREEN}First run detected, initializing application...${NC}"

    cd /var/www/html/monarc

    if [ "${MONARC_PREPARED_RELEASE:-0}" = "1" ]; then
        test -f vendor/autoload.php
        php tests/released-sources.php
    else
        composer install --no-interaction --prefer-dist
        ./scripts/install-frontend.sh
    fi

    # Create module symlinks
    echo -e "${YELLOW}Creating module symlinks...${NC}"
    mkdir -p module/Monarc
    cd module/Monarc
    ln -sfn ./../../vendor/monarc/core Core
    ln -sfn ./../../vendor/monarc/frontoffice FrontOffice
    cd /var/www/html/monarc

    # Create office databases independently; a previous attempt may have created only CLI.
    echo -e "${YELLOW}Setting up databases...${NC}"
    USE_BO_COMMON_ENABLED=0
    if is_true "${USE_BO_COMMON}"; then
        USE_BO_COMMON_ENABLED=1
    fi

    mysql -h"${DBHOST}" -u"root" -p"${DBPASSWORD_ADMIN}" -e "CREATE DATABASE IF NOT EXISTS ${DBNAME_CLI} DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"

    if [ "$USE_BO_COMMON_ENABLED" -eq 0 ]; then
        mysql -h"${DBHOST}" -u"root" -p"${DBPASSWORD_ADMIN}" -e "CREATE DATABASE IF NOT EXISTS ${DBNAME_COMMON} DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
    else
        echo -e "${YELLOW}USE_BO_COMMON is enabled; skipping monarc_common creation and bootstrap.${NC}"
    fi

    echo -e "${YELLOW}Ensuring privileges for ${DBUSER_MONARC}...${NC}"
    mysql -h"${DBHOST}" -u"root" -p"${DBPASSWORD_ADMIN}" -e "GRANT ALL PRIVILEGES ON ${DBNAME_CLI}.* TO '${DBUSER_MONARC}'@'%';"
    if [ "$USE_BO_COMMON_ENABLED" -eq 0 ]; then
        mysql -h"${DBHOST}" -u"root" -p"${DBPASSWORD_ADMIN}" -e "GRANT ALL PRIVILEGES ON ${DBNAME_COMMON}.* TO '${DBUSER_MONARC}'@'%';"
    fi
    mysql -h"${DBHOST}" -u"root" -p"${DBPASSWORD_ADMIN}" -e "FLUSH PRIVILEGES;"

    if [ "$USE_BO_COMMON_ENABLED" -eq 0 ]; then
        COMMON_TABLE_COUNT=$(mysql -h"${DBHOST}" -u"root" -p"${DBPASSWORD_ADMIN}" -N -s \
            -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '${DBNAME_COMMON}';")
        if [ "$COMMON_TABLE_COUNT" -eq 0 ]; then
            echo -e "${YELLOW}Populating empty common database...${NC}"
            export MYSQL_PWD="${DBPASSWORD_MONARC}"
            mysql -h"${DBHOST}" -u"${DBUSER_MONARC}" ${DBNAME_COMMON} < db-bootstrap/monarc_structure.sql
            mysql -h"${DBHOST}" -u"${DBUSER_MONARC}" ${DBNAME_COMMON} < db-bootstrap/monarc_data.sql
        fi
    fi

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

    // Absolute public base URL; required to build password-reset links safely.
    'publicHost' => ${PUBLIC_HOST_PHP},

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
        'baseUrl' => '${STATS_API_BASE_URL:-http://stats-service:5005}',
        'apiKey' => '${STATS_API_KEY:-}',
    ],

    'deliverable' => [
        'pdfConverterBinary' => '${PDF_CONVERTER_BINARY:-/usr/bin/soffice}',
    ],

    'captcha' => [
        'enabled' => ${CAPTCHA_ENABLED_PHP},
        'failedLoginAttempts' => 3,
        'params' => [
            'name' => 'MonarcCaptcha',
            'font' => \$appdir . '/data/fonts/arial.ttf',
            'fontSize' => 30,
            'height' => 60,
            'wordLen' => 6,
            'timeout' => 300,
            'imgDir' => \$appdir . '/public/captcha',
            'imgUrl' => 'captcha/',
        ],
    ],

    'import' => [
        'uploadFolder' => '$appdir/data/import/files',
        'isBackgroundProcessActive' => false,
    ],
];
EOF

    # Update and build frontend and run DB migrations
    echo -e "${YELLOW}Building frontend and running DB migrations...${NC}"
    if [ "${MONARC_PREPARED_RELEASE:-0}" != "1" ]; then
        ./scripts/link_modules_resources.sh
        ./scripts/compile_translations.sh
    fi
    php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./module/Monarc/Core/migrations/phinx.php
    php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./module/Monarc/FrontOffice/migrations/phinx.php

    # Seed database with initial user
    echo -e "${YELLOW}Creating initial user and client...${NC}"
    if ! php ./vendor/robmorgan/phinx/bin/phinx seed:run -c ./module/Monarc/FrontOffice/migrations/phinx.php; then
        echo -e "${YELLOW}Initial user/client seed failed. update-all completed successfully, so initialization will continue.${NC}"
        echo -e "${YELLOW}If needed, rerun the seed manually after startup.${NC}"
    fi

    # Set permissions
    echo -e "${YELLOW}Setting permissions...${NC}"
    mkdir -p /var/www/html/monarc/public/captcha
    chown -R www-data:www-data /var/www/html/monarc/data
    chown -R www-data:www-data /var/www/html/monarc/public/captcha
    chmod -R 775 /var/www/html/monarc/data

    # Mark initialization as complete
    touch /var/www/html/monarc/.docker-initialized
    echo -e "${GREEN}Initialization complete!${NC}"
else
    echo -e "${GREEN}Application already initialized, starting services...${NC}"
fi

# Apply development SMTP settings on every startup, including initialized installs.
if [ "${APP_ENV:-}" = "development" ] && [ -n "${SMTP_HOST:-}" ]; then
    cp /var/www/html/monarc/docker/smtp.local.php /var/www/html/monarc/config/autoload/smtp.local.php
fi

# Execute the main command
exec "$@"
