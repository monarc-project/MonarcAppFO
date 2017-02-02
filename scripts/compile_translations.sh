#!/bin/bash

if [ -d node_modules/ng_backoffice ]; then
	pushd node_modules/ng_backoffice
	grunt compile_translations
	grunt concat

	if [ -d node_modules/ng_backoffice/po ]; then
		for i in $(ls node_modules/ng_backoffice/po/*\.po); do
			l=$(basename $i .po)
			msgfmt -o ./node_modules/ng_backoffice/po/$l.mo -v ./node_modules/ng_backoffice/po/$l.po
		done;
	fi
fi

if [ -d node_modules/ng_client ]; then
	pushd node_modules/ng_client
	grunt compile_translations
	grunt concat
	
	if [ -d node_modules/ng_client/po ]; then
		for i in $(ls node_modules/ng_client/po/*\.po); do
			l=$(basename $i .po)
			msgfmt -o ./node_modules/ng_client/po/$l.mo -v ./node_modules/ng_client/po/$l.po
		done;
	fi
fi
