#! /usr/bin/env bash

# local use:
#for conf_file_path in /home/vagrant/monarc/config/*/local.php

for conf_file_path in /var/www/*/local.php
do
  export APP_CONF_DIR=$conf_file_path

  echo "[$(date)] Collecting stats for client: $conf_file_path."

  # local use:
  #/home/vagrant/monarc/bin/console monarc:collect-stats >> "$conf_file_path"/collect_stats.log

  /var/lib/monarc/fo/bin/console monarc:collect-stats >> "$conf_file_path"/data/collect_stats.log

  echo "[$(date)] Finished."
done
