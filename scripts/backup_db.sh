#!/usr/bin/env bash

# Create a key pair on the backup system or on your computer:
# $ openssl req -x509 -sha256 -nodes -newkey rsa:4096 -keyout mysqldump.priv.pem -out mysqldump.pub.pem
# Do not transport your private key to any other systems.
#
# And copy the public key to your server:
# $ scp mysqldump.pub.pem mysqldump@your.server.tld:/home/mysqldump/key/
#
# If needed, decryption is done like this:
# $ openssl smime -decrypt -in dump-cli.sql.enc -binary -inform DEM -inkey mysqldump.priv.pem -out dump-cli.sql
#
#

CLIENT=$1
MYSQL_CREDENTIALS='/var/www/'$CLIENT'/credentialsmysql.cnf'
BACKUP_DIR='/var/www/'$CLIENT'/backup/'
BACKUP_DIR=$BACKUP_DIR$(date +"%Y%m%d_%H%M%S")
PUCLIC_KEY=$2

if [ -e $MYSQL_CREDENTIALS ]; then
    mkdir $BACKUP_DIR
    echo -e "\e[32mDumping database to $BACKUP_DIR...\e[0m"
    mysqldump --defaults-file=$MYSQL_CREDENTIALS --databases $CLIENT > $BACKUP_DIR/$CLIENT.sql

    echo -e "\e[32mEncrypting database...\e[0m"
    openssl smime -encrypt -binary -text -aes256 -in $BACKUP_DIR/$CLIENT.sql -out $BACKUP_DIR/$CLIENT.sql.enc -outform DER $PUCLIC_KEY

    rm $BACKUP_DIR/$CLIENT.sql
else
    echo -e "\e[93mDatabase backup not configured. Skipping.\e[0m"
fi
