#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

bypass=0
forceClearCache=0
isDevEnv=0
while getopts "hbcd" option
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
    d)
      isDevEnv=1
  esac
done

checkout_to_latest_tag() {
  if [ -d $1 ]; then
    pushd $1
    git fetch --tags
    tag=$(git describe --tags `git rev-list --tags --max-count=1`)
    git checkout -b $tag latest
    git pull origin $tag
    popd
  fi
}

migrate_module() {
	if [[ -d $1 ]]; then
		php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./$1/migrations/phinx.php
	fi
}

if [[ ! -f "config/autoload/local.php" && $bypass -eq 0 ]]; then
	echo "Configure Monarc (config/autoload/local.php)"
	exit 1
fi

git pull

if [ $? != 0 ]; then
       echo "A problem occurred while retrieving remote files from repository."
       exit 1
fi

./scripts/check_composer.sh
if [[ $? -eq 1 ]]; then
    exit 1
fi

if [[ $isDevEnv -eq 0 ]]; then
  composer ins -o --no-dev
else
  composer ins
fi

pathCore="module/Monarc/Core"
pathFO="module/Monarc/FrontOffice"

if [[ $bypass -eq 0 ]]; then
	if [ -e data/backup/credentialsmysql.cnf ]; then
		backupdir=data/backup/$(date +"%Y%m%d_%H%M%S")
		mkdir $backupdir
		echo -e "${GREEN}Dumping database to $backupdir...${NC}"
		mysqldump --defaults-file=data/backup/credentialsmysql.cnf --databases monarc_common > $backupdir/dump-common.sql
		mysqldump --defaults-file=data/backup/credentialsmysql.cnf --databases monarc_cli > $backupdir/dump-cli.sql
	else
		echo -e "${GREEN}Database backup not configured. Skipping.${NC}"
	fi

	migrate_module $pathCore
	migrate_module $pathFO
fi

if [[ -d node_modules && -d node_modules/ng_anr ]]; then
	if [[ -d node_modules/ng_anr/.git ]]; then
		checkout_to_latest_tag node_modules/ng_client
		checkout_to_latest_tag node_modules/ng_anr
	else
		npm update
	fi
else
	npm ci
fi

cd node_modules/ng_client
npm ci
cd ../..

./scripts/link_modules_resources.sh
./scripts/compile_translations.sh

if [[ $forceClearCache -eq 1 ]]; then
	# Clear doctrine cache
	# Move to Monarc/Core Module.php
	php ./public/index.php orm:clear-cache:metadata
	php ./public/index.php orm:clear-cache:query
	php ./public/index.php orm:clear-cache:result

	# Clear ZF2 cache
	touch ./data/cache/upgrade && chmod 777 ./data/cache/upgrade
fi

if [[ $forceClearCache -eq 0 && $bypass -eq 0 ]]; then
	# Clear ZF2 cache
	touch ./data/cache/upgrade && chmod 777 ./data/cache/upgrade
fi

./scripts/update_config_variables.sh

exit 0
