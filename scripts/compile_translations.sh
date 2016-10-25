#!/bin/bash

if [ -d node_modules/ng_backoffice ]; then
	pushd node_modules/ng_backoffice
	grunt compile_translations
	grunt concat
fi

if [ -d node_modules/ng_client ]; then
	pushd node_modules/ng_client
	grunt compile_translations
	grunt concat
fi
