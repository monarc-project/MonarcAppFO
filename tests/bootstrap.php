<?php declare(strict_types=1);
/**
 * @link      https://github.com/monarc-project for the canonical source repository
 * @copyright Copyright (c) 2016-2026 Luxembourg House of Cybersecurity LHC.lu - Licensed under GNU Affero GPL v3
 * @license   MONARC is licensed under GNU Affero General Public License version 3
 */

chdir(dirname(__DIR__));

if (date_default_timezone_get() !== ini_get('date.timezone')) {
    date_default_timezone_set('Europe/Luxembourg');
}

putenv('APP_CONF_DIR=' . dirname(__DIR__) . '/tests/config');
putenv('TESTS_DIR=' . dirname(__DIR__) . '/tests');
putenv('APPLICATION_ENV=testing');
putenv('APP_ENV=testing');

require dirname(__DIR__) . '/vendor/autoload.php';
