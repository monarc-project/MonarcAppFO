#!/bin/bash

oldurl_if_exists() {
	if [ -d $1 ]; then
		pushd $1 >/dev/null
		sed -i -e 's/CASES-LU/monarc-project/g' ./.git/config $2
		git config core.fileMode false
		popd >/dev/nul
	fi
}


oldurl_if_exists . $1
oldurl_if_exists module/MonarcCore $1
oldurl_if_exists module/MonarcBO $1
oldurl_if_exists module/MonarcFO $1
oldurl_if_exists node_modules/ng_backoffice $1
oldurl_if_exists node_modules/ng_client $1
oldurl_if_exists node_modules/ng_anr $1
