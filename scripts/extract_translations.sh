#!/bin/bash

if [ -d node_modules/ng_backoffice ]; then
	pushd node_modules/ng_backoffice
	grunt extract_translations
fi


if [ -d node_modules/ng_client ]; then
	pushd node_modules/ng_client
	grunt extract_translations
fi
