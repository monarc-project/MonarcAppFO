#!/bin/sh
set -e

if [ -z "$DBUSER_MONARC" ]; then
    echo "DBUSER_MONARC is not set; skipping dev grants."
    exit 0
fi

mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOSQL
GRANT ALL PRIVILEGES ON *.* TO '${DBUSER_MONARC}'@'%';
FLUSH PRIVILEGES;
EOSQL
