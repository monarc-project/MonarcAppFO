#!/bin/bash

if [ -d node_modules/ng_backoffice ]; then
	pushd node_modules/ng_backoffice
	../.bin/grunt compile_translations
    ../.bin/grunt concat
fi

if [ -d node_modules/ng_client ]; then
	pushd node_modules/ng_client
	../.bin/grunt compile_translations
	../.bin/grunt concat
fi
