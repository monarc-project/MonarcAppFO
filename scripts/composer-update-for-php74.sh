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

php_version_string=`php -v | grep -Eow '^PHP [^ ]+' | grep -Eow '[0-9\.]{1,3}'`
echo Your php version is $php_version_string

if [[ $(vercomp $php_version_string 7.4; echo $?) -eq 1 ]]; then
  composer require "ocramius/proxy-manager: ^2.8" --ignore-platform-reqs
fi
