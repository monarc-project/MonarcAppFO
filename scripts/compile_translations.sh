#!/bin/bash

pwd

if [ -d node_modules/ng_backoffice ]; then
	pushd node_modules/ng_backoffice
	node_modules/.bin/grunt compile_translations
	node_modules/.bin/grunt concat
fi


if [ -d node_modules/ng_client ]; then
	pushd node_modules/ng_client
	node_modules/.bin/grunt compile_translations
	node_modules/.bin/grunt concat
fi
