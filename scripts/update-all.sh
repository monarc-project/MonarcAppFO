#!/bin/bash

pull_if_exists() {
	if [ -d $1 ]; then
		pushd $1
		git pull
		popd
	fi
}

gitcommand=`command -v git`
if [[ -z "$gitcommand" ]]; then
	echo "Git must be installed"
	exit
fi

$gitcommand pull

composercommand=`command -v composer`
if [[ -z "$composercommand" ]]; then
	if [[ ! -f "composer.phar" ]]; then
		# https://getcomposer.org/download/
		php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
		php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
		php composer-setup.php
		php -r "unlink('composer-setup.php');"
	fi
	php composer.phar update -o
else
	$composercommand update -o
fi


currentPath=`pwd`
pathCore="module/MonarcCore"
if [ -d $pathCore ]; then
	pull_if_exists $pathCore
else
	pathCore="vendor/monarc/core"
fi
pathBO="module/MonarcBO"
if [ -d $pathBO ]; then
	pull_if_exists $pathBO
else
	pathBO="vendor/monarc/backoffice"
fi
pathFO="module/MonarcFO"
if [ -d $pathFO ]; then
	pull_if_exists $pathFO
else
	pathFO="vendor/monarc/frontoffice"
fi

if [[ -d node_modules && -d node_modules/ng_anr ]]; then
	if [[ -d node_modules/ng_anr/.git ]]; then
		pull_if_exists node_modules/ng_backoffice
		pull_if_exists node_modules/ng_client
		pull_if_exists node_modules/ng_anr
	else
		npm update
	fi
else
	npm install
fi


if [ -d $pathCore ]; then
	/opt/php-7.0.5/bin/php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./$pathCore/migrations/phinx.php
	if [ -d "${pathCore}/hooks" ]; then
		cd $pathCore/.git/hooks
		ln -s ../../hooks/pre-commit.sh pre-commit 2>/dev/null
		chmod u+x pre-commit
		cd $currentPath
	fi
fi

if [ -d $pathBO ]; then
	/opt/php-7.0.5/bin/php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./$pathBO/migrations/phinx.php

	if [ -d "${pathBO}/hooks" ]; then
		cd $pathBO/.git/hooks
		ln -s ../../hooks/pre-commit.sh pre-commit 2>/dev/null
		chmod u+x pre-commit
		cd $currentPath
	fi
fi

if [ -d $pathFO ]; then
	/opt/php-7.0.5/bin/php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./$pathFO/migrations/phinx.php

	if [ -d "$pathFO/hooks" ]; then
		cd $pathFO/.git/hooks
		ln -s ../../hooks/pre-commit.sh pre-commit 2>/dev/null
		chmod u+x pre-commit
		cd $currentPath
	fi
fi

if [ -d node_modules/ng_backoffice ]; then
	cd node_modules/ng_backoffice
	npm install
	cd ../..
fi

if [ -d node_modules/ng_client ]; then
	cd node_modules/ng_client
	npm install
	cd ../..
fi

./scripts/link_modules_resources.sh
./scripts/compile_translations.sh

# Clear doctrine cache
/opt/php-7.0.5/bin/php ./public/index.php orm:clear-cache:metadata
/opt/php-7.0.5/bin/php ./public/index.php orm:clear-cache:query
/opt/php-7.0.5/bin/php ./public/index.php orm:clear-cache:result

# Clear ZF2 cache
touch ./data/cache/upgrade && chmod 777 ./data/cache/upgrade
