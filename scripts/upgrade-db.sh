#!/bin/bash

php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./module/MonarcCore/migrations/phinx.php

if [ -d module/MonarcBO ]; then
        php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./module/MonarcBO/migrations/phinx.php
fi

if [ -d module/MonarcFO ]; then
        php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./module/MonarcFO/migrations/phinx.php
fi
