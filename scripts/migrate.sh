#!/bin/bash
cd /var/www/continuousphp/current

while [ ! -f /var/lib/continuousphp/credentials.ini ]
do
  sleep 2
done

chown -R www-data:www-data /var/www/continuousphp/current/*
chmod +x bin/*
bin/phing -propertyfile /var/lib/continuousphp/credentials.ini init