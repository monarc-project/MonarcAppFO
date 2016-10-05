#!/bin/bash

if [ -d node_modules/ng_backoffice ]; then
	pushd node_modules/ng_backoffice
	node_modules/.bin/grunt extract_translations
fi


if [ -d node_modules/ng_client ]; then
	pushd node_modules/ng_client
	node_modules/.bin/grunt extract_translations
fi
