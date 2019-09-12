#!/bin/bash

php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./module/Monarc/Core/migrations/phinx.php

if [ -d module/Monarc/BackOffice ]; then
        php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./module/Monarc/BackOffice/migrations/phinx.php
fi

if [ -d module/Monarc/FrontOffice ]; then
        php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./module/Monarc/FrontOffice/migrations/phinx.php
fi
