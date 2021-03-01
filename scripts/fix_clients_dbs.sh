#! /usr/bin/env bash

for conf_file in /var/www/*/local.php
do
    db_user=$(grep 'user' $conf_file | head -1  | sed "s/'user' => '//" | sed "s/',//" | sed  's/^[ \t]*//;s/[ \t]*$//')
    db_pwd=$(grep 'password' $conf_file | head -1  | sed "s/'password' => '//" | sed "s/',//" | sed  's/^[ \t]*//;s/[ \t]*$//')
    echo "Alter anrs table raw size for $db_user ..."
    mysql -u $db_user -p$db_pwd $db_user -e "ALTER TABLE anrs ROW_FORMAT=DYNAMIC;"
    echo "Done."
done
