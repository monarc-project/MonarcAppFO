<?php declare(strict_types=1);

chdir(dirname(__DIR__));

if (date_default_timezone_get() !== ini_get('date.timezone')) {
    date_default_timezone_set('Europe/Luxembourg');
}

putenv('APP_CONF_DIR=' . dirname(__DIR__) . '/tests/config');
putenv('TESTS_DIR=' . dirname(__DIR__) . '/tests');
putenv('APPLICATION_ENV=testing');

require dirname(__DIR__) . '/vendor/autoload.php';
