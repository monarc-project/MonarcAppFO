#! /usr/bin/env bash

# local use:
#for conf_file_path in /home/vagrant/monarc/config/*/local.php

for conf_file_path in /var/www/*/local.php
do
  config_path=$(dirname "$conf_file_path")
  export APP_CONF_DIR=$config_path

  echo "[$(date)] Import analyses for: $config_path."

  # local use:
  #./bin/console monarc:import-analyses >> data/background_import.log

  /var/lib/monarc/fo/bin/console monarc:import-analyses >> "$config_path"/data/background_import.log

  echo "[$(date)] Finished."
done
