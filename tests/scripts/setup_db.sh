#!/bin/bash

DBUSER_MONARC='sqlmonarcuser'
DBPASSWORD_MONARC="sqlmonarcuser"

mysql -u $DBUSER_MONARC -p$DBPASSWORD_MONARC -e "CREATE DATABASE IF NOT EXISTS monarc_cli_test DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;" > /dev/null

# Check if the database is already exist we don't need to create the structure and import the data.
if ! mysql -u $DBUSER_MONARC -p$DBPASSWORD_MONARC -e 'use monarc_common_test'; then
  mysql -u $DBUSER_MONARC -p$DBPASSWORD_MONARC -e "CREATE DATABASE monarc_common_test DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;" > /dev/null
  mysql -u $DBUSER_MONARC -p$DBPASSWORD_MONARC monarc_common_test < db-bootstrap/monarc_structure.sql > /dev/null
  mysql -u $DBUSER_MONARC -p$DBPASSWORD_MONARC monarc_common_test < db-bootstrap/monarc_data.sql > /dev/null
fi

php bin/phinx migrate -c tests/migrations/phinx_core.php

php bin/phinx migrate -c tests/migrations/phinx_frontoffice.php
