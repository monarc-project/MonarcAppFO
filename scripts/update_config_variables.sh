#!/bin/bash

conf_file='./config/autoload/local.php'
if [ -f "$conf_file" ]; then
  sed -E -i "s/'mospApiUrl' => (.*)\/v1/'mospApiUrl' => \1/g" "$conf_file"
  echo "Done for $conf_file"
fi
