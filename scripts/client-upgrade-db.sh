#!/bin/bash

# Usage: ./scripts/client-upgrade-db.sh <module> <hostname> <user> <password> <db>
# Example: ./scripts/client-upgrade-db.sh MonarcBO localhost root derp monarc_backoffice

MODULE=$1
SQLHOST=$2
SQLUSER=$3
SQLPASS=$4
SQLBASE=$5

cat <<EOF >/tmp/conf.tmp.php
<?php
return array(
    'paths' => array(
        'migrations' => 'vendor/monarc/backoffice/migrations/db',
        'seeds' => 'vendor/monarc/backoffice/migrations/seeds',
    ),
    'environments' => array(
        'default_migration_table' => 'phinxlog',
        'default_database' => 'cli',
        'cli' => array(
            'adapter' => 'mysql',
            'host' => '$SQLHOST',
            'name' => '$SQLBASE',
            'user' => '$SQLUSER',
            'pass' => '$SQLPASS',
            'port' => 3306,
            'charset' => 'utf8',
        ),
    ),
);

EOF


php ./vendor/robmorgan/phinx/bin/phinx migrate -c /tmp/conf.tmp.php
rm /tmp/conf.tmp.php
