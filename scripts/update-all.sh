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

pull_if_exists module/MonarcCore
pull_if_exists module/MonarcBO
pull_if_exists module/MonarcFO
pull_if_exists node_modules/ng_backoffice
pull_if_exists node_modules/ng_client
pull_if_exists node_modules/ng_anr

if [ -d module/MonarcCore/hooks ]; then
	cd module/MonarcCore/.git/hooks
	ln -s ../../hooks/pre-commit.sh pre-commit 2>/dev/null
	chmod u+x pre-commit
	cd ../../../../
fi


php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./module/MonarcCore/migrations/phinx.php

if [ -d module/MonarcBO ]; then
	php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./module/MonarcBO/migrations/phinx.php

	if [ -d module/MonarcBO/hooks ]; then
		cd module/MonarcBO/.git/hooks
		ln -s ../../hooks/pre-commit.sh pre-commit 2>/dev/null
		chmod u+x pre-commit
		cd ../../../../
	fi
fi

if [ -d module/MonarcFO ]; then
	php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./module/MonarcFO/migrations/phinx.php

	if [ -d module/MonarcFO/hooks ]; then
		cd module/MonarcFO/.git/hooks
		ln -s ../../hooks/pre-commit.sh pre-commit 2>/dev/null
		chmod u+x pre-commit
		cd ../../../../
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
