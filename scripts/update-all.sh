#!/bin/bash

pull_if_exists() {
	if [ -d $1 ]; then
		pushd $1
		git pull
		popd
	fi
}

phpcommand=`command -v php`
if [[ -z "$phpcommand" ]]; then
	echo "PHP must be installed"
	exit 1
fi

gitcommand=`command -v git`
if [[ -z "$gitcommand" ]]; then
	echo "Git must be installed"
	exit 1
fi

$gitcommand pull

composercommand=`command -v composer`
if [[ -z "$composercommand" ]]; then
	if [[ ! -f "composer.phar" ]]; then
		# https://getcomposer.org/download/
		# https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
		EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
		$phpcommand -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
		ACTUAL_SIGNATURE=$($phpcommand -r "echo hash_file('SHA384', 'composer-setup.php');")
		if [[ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]]; then
			echo "Error download composer (different hash)"
			rm composer-setup.php
			exit 1
		fi
		rm composer-setup.php
		$phpcommand composer-setup.php --quiet
	fi
	$phpcommand composer.phar update -o
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
	$phpcommand ./vendor/robmorgan/phinx/bin/phinx migrate -c ./$pathCore/migrations/phinx.php
	if [ -d "${pathCore}/hooks" ]; then
		cd $pathCore/.git/hooks
		ln -s ../../hooks/pre-commit.sh pre-commit 2>/dev/null
		chmod u+x pre-commit
		cd $currentPath
	fi
fi

if [ -d $pathBO ]; then
	$phpcommand ./vendor/robmorgan/phinx/bin/phinx migrate -c ./$pathBO/migrations/phinx.php

	if [ -d "${pathBO}/hooks" ]; then
		cd $pathBO/.git/hooks
		ln -s ../../hooks/pre-commit.sh pre-commit 2>/dev/null
		chmod u+x pre-commit
		cd $currentPath
	fi
fi

if [ -d $pathFO ]; then
	$phpcommand ./vendor/robmorgan/phinx/bin/phinx migrate -c ./$pathFO/migrations/phinx.php

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
$phpcommand ./public/index.php orm:clear-cache:metadata
$phpcommand ./public/index.php orm:clear-cache:query
$phpcommand ./public/index.php orm:clear-cache:result

# Clear ZF2 cache
touch ./data/cache/upgrade && chmod 777 ./data/cache/upgrade
