#!/bin/bash

php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./vendor/monarc/core/migrations/phinx.php
php ./vendor/robmorgan/phinx/bin/phinx migrate -c ./vendor/monarc/backoffice/migrations/phinx.php