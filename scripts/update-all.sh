#!/usr/bin/env bash

bypass=0
forceClearCache=0
while getopts "hbc" option
do
	case $option in
		h)
			echo -e "Update or install all Monarc modules, frontend views and migrate database."
			echo -e "\t-b\tbypass migrate database"
			echo -e "\t-c\tforce clear cache"
			echo -e "\t-h\tdisplay this message"
			exit 1
			;;
		b)
			bypass=1
			echo "Migrate database don't execute !!!"
			;;
		c)
			forceClearCache=1
			;;
	esac
done

pull_if_exists() {
	if [ -d $1 ]; then
		pushd $1
		git pull
		popd
	fi
}

migrate_module() {
	if [[ -d $2 ]]; then
		$1 ./vendor/robmorgan/phinx/bin/phinx migrate -c ./$2/migrations/phinx.php
	fi
}

if [[ ! -f "config/autoload/local.php" && $bypass -eq 0 ]]; then
	echo "Configure Monarc (config/autoload/local.php)"
	exit 1
fi

phpcommand=`command -v php`
if [[ -z "$phpcommand" ]]; then
	echo "PHP must be installed"
	exit 1
fi

git pull

if [ $? != 0 ]; then
       echo "A problem occurred while retrieving remote files from repository."
       exit 1
fi

composer install -o

currentPath=`pwd`
pathCore="module/Monarc/Core"
pathFO="module/Monarc/FrontOffice"

if [[ $bypass -eq 0 ]]; then
	if [ -e data/backup/credentialsmysql.cnf ]; then
		backupdir=data/backup/$(date +"%Y%m%d_%H%M%S")
		mkdir $backupdir
		echo -e "\e[32mDumping database to $backupdir...\e[0m"
		mysqldump --defaults-file=data/backup/credentialsmysql.cnf --databases monarc_common > $backupdir/dump-common.sql
		mysqldump --defaults-file=data/backup/credentialsmysql.cnf --databases monarc_cli > $backupdir/dump-cli.sql
	else
		echo -e "\e[93mDatabase backup not configured. Skipping.\e[0m"
	fi

	migrate_module $phpcommand $pathCore
	migrate_module $phpcommand $pathFO
fi

cd node_modules/ng_client
npm install
cd ../..

./scripts/link_modules_resources.sh
./scripts/compile_translations.sh

if [[ $forceClearCache -eq 1 ]]; then
	# Clear doctrine cache
	# Move to Monarc/Core Module.php
	$phpcommand ./public/index.php orm:clear-cache:metadata
	$phpcommand ./public/index.php orm:clear-cache:query
	$phpcommand ./public/index.php orm:clear-cache:result

	# Clear ZF2 cache
	touch ./data/cache/upgrade && chmod 777 ./data/cache/upgrade
fi

if [[ $forceClearCache -eq 0 && $bypass -eq 0 ]]; then
	# Clear ZF2 cache
	touch ./data/cache/upgrade && chmod 777 ./data/cache/upgrade
fi
