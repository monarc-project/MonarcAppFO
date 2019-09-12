#!/bin/bash

if [ -d module/Monarc/Core ]; then
	php ./vendor/robmorgan/phinx/bin/phinx seed:run -c ./module/Monarc/Core/migrations/phinx.php
fi

if [ -d module/Monarc/BackOffice ]; then
	php ./vendor/robmorgan/phinx/bin/phinx seed:run -c ./module/Monarc/BackOffice/migrations/phinx.php
fi

if [ -d module/Monarc/FrontOffice ]; then
	php ./vendor/robmorgan/phinx/bin/phinx seed:run -c ./module/Monarc/FrontOffice/migrations/phinx.php
fi

