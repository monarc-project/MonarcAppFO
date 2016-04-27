#!/bin/bash

pull_if_exists() {
	if [ -d $1 ]; then
		pushd $1
		git pull
		popd
	fi
}


git pull

php composer.phar update

pull_if_exists module/MonarcCore
pull_if_exists module/MonarcBO
pull_if_exists node_modules/ng_backoffice

if [ -d node_modules/ng_backoffice ]; then
	cd node_modules/ng_backoffice
	npm install
	cd ../..
fi

./scripts/link_modules_resources.sh
