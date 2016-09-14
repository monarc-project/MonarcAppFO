#!/bin/bash

checkout_if_exists() {
	if [ -d $1 ]; then
		pushd $1 >/dev/null
		git checkout $2
		popd >/dev/null
	fi
}


checkout_if_exists . $1
checkout_if_exists module/MonarcCore $1
checkout_if_exists module/MonarcBO $1
checkout_if_exists module/MonarcFO $1
checkout_if_exists node_modules/ng_backoffice $1
checkout_if_exists node_modules/ng_client $1
checkout_if_exists node_modules/ng_anr $1
