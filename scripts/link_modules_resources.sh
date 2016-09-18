#!/bin/bash

# Ensure folders are existing
if [ ! -d public/js ]; then
	mkdir public/js
else
	find -L public/js -type l -exec rm {} \;
fi

if [ ! -d public/css ]; then
	mkdir public/css
else
	find -L public/css -type l -exec rm {} \;
fi
if [ ! -d public/views/dialogs ]; then
	mkdir -p public/views/dialogs
else
	find -L public/views -type l -exec rm {} \;
fi

if [ ! -d public/views/partials ]; then
	mkdir -p public/views/partials
else
	find -L public/views -type l -exec rm {} \;
fi

if [ ! -d public/img ]; then
	mkdir public/img
else
	find -L public/img -type l -exec rm {} \;
fi

# Link modules resources
if [ -d node_modules/ng_backoffice ]; then
	cd public/views/ && find ../../node_modules/ng_backoffice/views -maxdepth 1 -name "*.html" -exec ln -s {} \; 2>/dev/null
	cd dialogs/ && find ../../../node_modules/ng_backoffice/views/dialogs -maxdepth 1 -name "*.html" -exec ln -s {} \; 2>/dev/null
	cd ../partials/ && find ../../../node_modules/ng_backoffice/views/partials -maxdepth 1 -name "*.html" -exec ln -s {} \; 2>/dev/null
	cd ../../js/ && find ../../node_modules/ng_backoffice/src -maxdepth 1 -name "*" -exec ln -s {} \; 2>/dev/null
	cd ../css/ && find ../../node_modules/ng_backoffice/css -name "*" -exec ln -s {} \; 2>/dev/null
	cd ../img/ && find ../../node_modules/ng_backoffice/img -name "*" -exec ln -s {} \; 2>/dev/null

	if [ -d ../../node_modules/ng_anr ]; then
		cd ../js/
		mkdir -p anr
		cd anr && find ../../../node_modules/ng_anr/src -type f -maxdepth 1 -name "*" -exec ln -s {} \; 2>/dev/null
		cd ..

		cd ../views/
		mkdir -p anr
		cd anr && find ../../../node_modules/ng_anr/views -type f -maxdepth 1 -name "*" -exec ln -s {} \; 2>/dev/null
		cd ..
	fi

	cd ../..

	pushd node_modules/ng_backoffice
	node_modules/.bin/grunt concat
	popd
fi

if [ -d node_modules/ng_client ]; then
	cd public/views/ && find ../../node_modules/ng_client/views -name "*.html" -exec ln -s {} \; 2>/dev/null
	cd dialogs/ && find ../../../node_modules/ng_client/views/dialogs -maxdepth 1 -name "*.html" -exec ln -s {} \; 2>/dev/null
	cd ../../js/ && find ../../node_modules/ng_client/src -name "*" -exec ln -s {} \; 2>/dev/null
	cd ../css/ && find ../../node_modules/ng_client/css -name "*" -exec ln -s {} \; 2>/dev/null
	cd ../img/ && find ../../node_modules/ng_client/img -name "*" -exec ln -s {} \; 2>/dev/null

	if [ -d ../../node_modules/ng_anr ]; then
		cd ../js/
		mkdir -p anr
		cd anr && find ../../../node_modules/ng_anr/src -type f -maxdepth 1 -name "*" -exec ln -s {} \; 2>/dev/null
		cd ..

		cd ../views/
		mkdir -p anr
		cd anr && find ../../../node_modules/ng_anr/views -type f -maxdepth 1 -name "*" -exec ln -s {} \; 2>/dev/null
		cd ..
	fi

	cd ../..

	pushd node_modules/ng_client
	node_modules/.bin/grunt concat
	popd
fi

