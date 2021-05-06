#! /usr/bin/env bash

conf_file='./config/autoload/local.php'
if [ -f "$conf_file" ]; then
  sed -E -i "s/(.*) => (.*)\/v1/\1 => \2/g" "$conf_file"
  echo "Done for $conf_file"
fi
