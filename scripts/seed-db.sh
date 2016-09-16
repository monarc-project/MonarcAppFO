#!/bin/bash

if [ -d module/MonarcCore ]; then
	php ./vendor/robmorgan/phinx/bin/phinx seed:run -c ./module/MonarcCore/migrations/phinx.php
fi

if [ -d module/MonarcBO ]; then
	php ./vendor/robmorgan/phinx/bin/phinx seed:run -c ./module/MonarcBO/migrations/phinx.php
fi

if [ -d module/MonarcFO ]; then
	php ./vendor/robmorgan/phinx/bin/phinx seed:run -c ./module/MonarcFO/migrations/phinx.php
fi

