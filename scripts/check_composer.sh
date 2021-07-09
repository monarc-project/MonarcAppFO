#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

vercomp () {
    if [[ $1 == $2 ]]
    then
        return 1
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
    done
    return 0
}

composer_version_string=`composer --version`
composer_version=`echo $composer_version_string | awk 'BEGIN { FS="[ ]" } ; { print $3 }'`

if [[ $(vercomp $composer_version 2.1.0 ; echo $?) -eq 0 ]]; then
    echo -e "${RED}Please update your version of composer.${NC} The minimum requirements is 2.1.0."
    echo -e "You can run 'composer self-update' command or follow the link with the installation details:"

    cat << EOF
https://getcomposer.org/download/
EOF

    exit 1

fi
