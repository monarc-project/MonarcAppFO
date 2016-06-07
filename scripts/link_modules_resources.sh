#!/bin/bash

# Ensure folders are existing
if [ ! -d public/js ]; then
	mkdir public/js
fi

if [ ! -d public/css ]; then
	mkdir public/css
fi
if [ ! -d public/views ]; then
	mkdir -p public/views/dialogs
fi

if [ ! -d public/img ]; then
	mkdir public/img
fi

# Link modules resources
if [ -d node_modules/ng_backoffice ]; then
	cd public/views/ && find ../../node_modules/ng_backoffice/views -maxdepth 1 -name "*.html" -exec ln -s {} \; 2>/dev/null
	cd dialogs/ && find ../../../node_modules/ng_backoffice/views/dialogs -maxdepth 1 -name "*.html" -exec ln -s {} \; 2>/dev/null
	cd ../../js/ && find ../../node_modules/ng_backoffice/src -maxdepth 1 -name "*" -exec ln -s {} \; 2>/dev/null
	cd ../css/ && find ../../node_modules/ng_backoffice/css -name "*.css" -exec ln -s {} \; 2>/dev/null
	cd ../img/ && find ../../node_modules/ng_backoffice/img -name "*" -exec ln -s {} \; 2>/dev/null
	cd ../..

	pushd node_modules/ng_backoffice
	grunt concat
	popd
fi

if [ -d node_modules/ng_client ]; then
	cd public/views/ && find ../../node_modules/ng_client/views -name "*.html" -exec ln -s {} \; 2>/dev/null
	cd ../js/ && find node_modules/ng_client/src -name "*.js" -exec ln -s {} \; 2>/dev/null
	cd ../css/ && find node_modules/ng_client/css -name "*.css" -exec ln -s {} \; 2>/dev/null
	cd ../img/ && find node_modules/ng_client/img -name "*" -exec ln -s {} \; 2>/dev/null
	cd ../..

	pushd node_modules/ng_backoffice
	grunt concat
	popd
fi

