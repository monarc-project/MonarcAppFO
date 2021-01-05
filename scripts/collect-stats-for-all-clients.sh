#! /usr/bin/env bash

# local use:
#for conf_file_path in /home/vagrant/monarc/config/*/local.php

for conf_file_path in /var/www/*/local.php
do
  config_path=$(dirname "$conf_file_path")
  export APP_CONF_DIR=$config_path

  echo "[$(date)] Collecting stats for client: $config_path."

  # local use:
  #/home/vagrant/monarc/bin/console monarc:collect-stats >> "$config_path"/data/collect_stats.log

  /var/lib/monarc/fo/bin/console monarc:collect-stats >> "$config_path"/data/collect_stats.log

  echo "[$(date)] Finished."
done
