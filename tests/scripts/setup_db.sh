#!/bin/bash

DBHOST="127.0.0.1"
DBUSER_MONARC="sqlmonarcuser"
DBPASSWORD_MONARC="sqlmonarcuser"
# Comment/Uncomment and modify the following line to run tests from your host machine:
CONNECTION_OPTIONS="--ssl-key=~/web/monarc/MonarcAppFO/vagrant/.vagrant/machines/default/virtualbox/private_key"
#CONNECTION_OPTIONS=""

mysql -h $DBHOST -u $DBUSER_MONARC -p$DBPASSWORD_MONARC $CONNECTION_OPTIONS -e "CREATE DATABASE IF NOT EXISTS monarc_cli_test DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;" > /dev/null

# Check if the database is already exist we don't need to create the structure and import the data.
if ! mysql -h $DBHOST -u $DBUSER_MONARC -p$DBPASSWORD_MONARC $CONNECTION_OPTIONS -e "use monarc_common_test"; then
  mysql -h $DBHOST -u $DBUSER_MONARC -p$DBPASSWORD_MONARC $CONNECTION_OPTIONS -e "CREATE DATABASE monarc_common_test DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;" > /dev/null
  mysql -h $DBHOST -u $DBUSER_MONARC -p$DBPASSWORD_MONARC $CONNECTION_OPTIONS monarc_common_test < db-bootstrap/monarc_structure.sql > /dev/null
  mysql -h $DBHOST -u $DBUSER_MONARC -p$DBPASSWORD_MONARC $CONNECTION_OPTIONS monarc_common_test < db-bootstrap/monarc_data.sql > /dev/null
fi

if [[ ! $(mysql -h $DBHOST -u $DBUSER_MONARC -p$DBPASSWORD_MONARC $CONNECTION_OPTIONS -e 'SHOW TABLES LIKE "phinxlog"' monarc_common_test) ]]
then
  php bin/phinx migrate -c tests/migrations/phinx_core.php
fi
if [[ ! $(mysql -h $DBHOST -u $DBUSER_MONARC -p$DBPASSWORD_MONARC $CONNECTION_OPTIONS -e 'SHOW TABLES LIKE "phinxlog"' monarc_cli_test) ]]
then
  php bin/phinx migrate -c tests/migrations/phinx_frontoffice.php
fi
