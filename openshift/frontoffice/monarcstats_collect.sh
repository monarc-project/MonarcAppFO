#!/bin/bash

PREVIOUS=""

while true; do
    TODAY=$(date +"%Y%m%d")
    
    # Check if the day has changed
    if [ "$PREVIOUS" != "$TODAY" ]; then
        /var/www/html/monarc/bin/console monarc:collect-stats
        PREVIOUS=$TODAY
    fi
    
    # Sleep for 1 minute (60 seconds) to prevent 100% CPU usage
    sleep 6h
done
