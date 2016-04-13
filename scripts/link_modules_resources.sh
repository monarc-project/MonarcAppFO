#!/bin/bash

if [ ! -d public/js ]; then
	mkdir public/js
fi

if [ ! -d public/views ]; then
	mkdir public/views
fi

if [ -d node_modules/ng_backoffice ]; then
	find node_modules/ng_backoffice/views -name "*.html" -exec ln -s $(realpath {}) public/views/ \;
	find node_modules/ng_backoffice/src -name "*.js" -exec ln -s $(realpath {}) public/js/ \;
fi

if [ -d node_modules/ng_client ]; then
	find node_modules/ng_client/views -name "*.html" -exec ln -s {} public/views/ \;
	find node_modules/ng_client/src -name "*.js" -exec ln -s {} public/js/ \;
fi

