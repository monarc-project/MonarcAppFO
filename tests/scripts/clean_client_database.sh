#!/bin/bash

DBHOST="127.0.0.1"
DBUSER_MONARC="sqlmonarcuser"
DBPASSWORD_MONARC="sqlmonarcuser"
# Comment/Uncomment and modify the following line to run tests from your host machine:
CONNECTION_OPTIONS="--ssl-key=~/web/monarc/MonarcAppFO/vagrant/.vagrant/machines/default/virtualbox/private_key"

mysql -h $DBHOST -u $DBUSER_MONARC -p$DBPASSWORD_MONARC $CONNECTION_OPTIONS monarc_cli_test < tests/data/clean_client_database.sql > /dev/null
