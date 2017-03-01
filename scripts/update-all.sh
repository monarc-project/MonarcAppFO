#!/bin/bash

pull_if_exists() {
	if [ -d $1 ]; then
		pushd $1
		git pull
		popd
	fi
}


git pull

php composer.phar update -o

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

pull_if_exists node_modules/ng_backoffice
pull_if_exists node_modules/ng_client
pull_if_exists node_modules/ng_anr

if [ -d $pathCore ]; then
	php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./$pathCore/migrations/phinx.php
	if [ -d "${pathCore}/hooks" ]; then
		cd $pathCore/.git/hooks
		ln -s ../../hooks/pre-commit.sh pre-commit 2>/dev/null
		chmod u+x pre-commit
		cd $currentPath
	fi
fi

if [ -d $pathBO ]; then
	php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./$pathBO/migrations/phinx.php

	if [ -d "${pathBO}/hooks" ]; then
		cd $pathBO/.git/hooks
		ln -s ../../hooks/pre-commit.sh pre-commit 2>/dev/null
		chmod u+x pre-commit
		cd $currentPath
	fi
fi

if [ -d $pathFO ]; then
	php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./$pathFO/migrations/phinx.php

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
php ./public/index.php orm:clear-cache:metadata
php ./public/index.php orm:clear-cache:query
php ./public/index.php orm:clear-cache:result

# Clear ZF2 cache
touch ./data/cache/upgrade && chmod 777 ./data/cache/upgrade
