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

CLIENT=$0
MYSQL_CREDENTIALS='/var/www/'$CLIENT'/credentialsmysql.cnf'
BACKUP_DIR='/var/www/'$CLIENT'/backup/'
BACKUP_DIR=$BACKUP_DIR$(date +"%Y%m%d_%H%M%S")

if [ -e $MYSQL_CREDENTIALS ]; then
    mkdir $BACKUP_DIR
    echo -e "\e[32mDumping database to $BACKUP_DIR...\e[0m"
    mysqldump --defaults-file=$MYSQL_CREDENTIALS --databases monarc_cli > $BACKUP_DIR/dump-cli.sql

    echo -e "\e[32mEncrypting database...\e[0m"
    openssl smime -encrypt -binary -text -aes256 -in plain.txt -out $BACKUP_DIR/dump-cli.sql.enc -outform DER /home/mysqldump/key/mysqldump.pub.pem

    rm $BACKUP_DIR/dump-cli.sql
else
    echo -e "\e[93mDatabase backup not configured. Skipping.\e[0m"
fi
