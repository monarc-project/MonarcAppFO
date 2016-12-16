#!/bin/bash

if [ -d node_modules/ng_backoffice ]; then
	pushd node_modules/ng_backoffice

	if [ -f node_modules/.bin/grunt ]; then
		node_modules/.bin/grunt extract_translations
	else
		grunt extract_translations
	fi
fi


if [ -d node_modules/ng_client ]; then
	pushd node_modules/ng_client

	if [ -f node_modules/.bin/grunt ]; then
		node_modules/.bin/grunt extract_translations
	else
		grunt extract_translations
	fi
fi
