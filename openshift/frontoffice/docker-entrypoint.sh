#!/bin/bash
set -e

# Environment variables required at runtime (with proposed defaults):
DBUSER_MONARC=${DBUSER_MONARC:-sqlmonarcuser}
DBPASSWORD_MONARC=${DBPASSWORD_MONARC:-sqlmonarcuser}
DBPASSWORD_ADMIN=${DBPASSWORD_ADMIN:-root}
DBHOST=${DBHOST:-fodb}
DBNAME_COMMON=${DBNAME_COMMON:-monarc_common}
DBNAME_CLI=${DBNAME_CLI:-monarc_cli}
DBHOST_PORT=${DBHOST_PORT:-3306}
USE_BO_COMMON_ENABLED=${USE_BO_COMMON_ENABLED:-0}
CAPTCHA_ENABLED_PHP=false

export DBUSER_MONARC DBPASSWORD_MONARC DBPASSWORD_ADMIN DBHOST DBNAME_COMMON DBNAME_CLI DBHOST_PORT USE_BO_COMMON

echo "Starting MONARC FrontOffice setup..."

# Wait for database to be ready
echo "Waiting for MariaDB to be ready..."
while ! mysqladmin ping -h"${DBHOST}" -u"root" -p"${DBPASSWORD_ADMIN}" -P${DBHOST_PORT} --silent 2>/dev/null; do
    echo "Waiting for MariaDB..."
    sleep 2
done
echo "MariaDB is ready!"

is_true() {
    case "$1" in
        1|true|yes|on) return 0 ;;
        *) return 1 ;;
    esac
}

cd /var/www/html/monarc
ln -s /var/lib/monarc data/monarc

# Check if CLI database exists and create databases if needed
DB_EXISTS=$(mysql -h"${DBHOST}" -u"root" -p"${DBPASSWORD_ADMIN}" -e "SHOW DATABASES LIKE '${DBNAME_CLI}';" | grep -c "${DBNAME_CLI}" || true)

if [ "$DB_EXISTS" -eq 0 ]; then
    echo "Creating databases..."
    mysql -h"${DBHOST}" -P${DBHOST_PORT} -u"root" -p"${DBPASSWORD_ADMIN}" -e "CREATE DATABASE IF NOT EXISTS ${DBNAME_CLI} DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"

    if [ "$USE_BO_COMMON_ENABLED" -eq 0 ]; then
        mysql -h"${DBHOST}" -P${DBHOST_PORT} -u"root" -p"${DBPASSWORD_ADMIN}" -e "CREATE DATABASE IF NOT EXISTS ${DBNAME_COMMON} DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"

        echo "Populating common database..."
        export MYSQL_PWD="${DBPASSWORD_MONARC}"
        mysql -h"${DBHOST}" -P${DBHOST_PORT} -u"${DBUSER_MONARC}" ${DBNAME_COMMON} < db-bootstrap/monarc_structure.sql
        mysql -h"${DBHOST}" -P${DBHOST_PORT} -u"${DBUSER_MONARC}" ${DBNAME_COMMON} < db-bootstrap/monarc_data.sql
    else
        echo "USE_BO_COMMON is enabled; skipping monarc_common creation and bootstrap."
    fi

    echo "Ensuring privileges for ${DBUSER_MONARC}..."
    mysql -h"${DBHOST}" -P${DBHOST_PORT} -u"root" -p"${DBPASSWORD_ADMIN}" -e "GRANT ALL PRIVILEGES ON ${DBNAME_CLI}.* TO '${DBUSER_MONARC}'@'%';"
    if [ "$USE_BO_COMMON_ENABLED" -eq 0 ]; then
        mysql -h"${DBHOST}" -P${DBHOST_PORT} -u"root" -p"${DBPASSWORD_ADMIN}" -e "GRANT ALL PRIVILEGES ON ${DBNAME_COMMON}.* TO '${DBUSER_MONARC}'@'%';"
    fi
    mysql -h"${DBHOST}" -P${DBHOST_PORT} -u"root" -p"${DBPASSWORD_ADMIN}" -e "FLUSH PRIVILEGES;"

    if [ "$USE_BO_COMMON_ENABLED" -eq 1 ]; then
        COMMON_EXISTS=$(mysql -h"${DBHOST}" -P${DBHOST_PORT} -u"root" -p"${DBPASSWORD_ADMIN}" -e "SHOW DATABASES LIKE '${DBNAME_COMMON}';" | grep -c "${DBNAME_COMMON}" || true)
        if [ "$COMMON_EXISTS" -eq 0 ]; then
            echo "USE_BO_COMMON is enabled, but ${DBNAME_COMMON} was not found on ${DBHOST}."
            echo "Ensure the BackOffice database is reachable and contains ${DBNAME_COMMON}."
            exit 1
        fi
    fi

    # Update and build frontend and run DB migrations
    echo "Building frontend and running DB migrations..."
    if [ -e data/backup/credentialsmysql.cnf ]; then
        backupdir=data/backup/$(date +"%Y%m%d_%H%M%S")
        mkdir $backupdir
        echo -e "Dumping database to $backupdir..."
        mysqldump --defaults-file=data/backup/credentialsmysql.cnf --databases monarc_common > $backupdir/dump-common.sql
        mysqldump --defaults-file=data/backup/credentialsmysql.cnf --databases monarc_cli > $backupdir/dump-cli.sql
    else
        echo -e "Database backup not configured. Skipping."
    fi

    # DB migration with Phinx
    php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./module/Monarc/Core/migrations/phinx.php
    php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./module/Monarc/FrontOffice/migrations/phinx.php

    # Seed database with initial user
    echo "Creating initial user and client..."
    if ! php ./vendor/robmorgan/phinx/bin/phinx seed:run -c ./module/Monarc/FrontOffice/migrations/phinx.php; then
        echo "Initial user/client seed failed. update-all completed successfully, so initialization will continue."
        echo "If needed, rerun the seed manually after startup."
    fi
    echo "Initialization complete!"
fi

# Set permissions
echo "Setting permissions..."
mkdir -p /var/www/html/monarc/public/captcha
chown -R www-data:www-data /var/www/html/monarc/data
chown -R www-data:www-data /var/www/html/monarc/public/captcha
chmod -R 775 /var/www/html/monarc/data

echo "Running application..."

# Execute the main command
if [[ $# -gt 0 ]]; then
    exec "$@"
else
    exec apachectl -e debug -D FOREGROUND || true
fi
