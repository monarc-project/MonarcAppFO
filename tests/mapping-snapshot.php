<?php declare(strict_types=1);
/**
 * @link      https://github.com/monarc-project for the canonical source repository
 * @copyright Copyright (c) 2016-2026 Luxembourg House of Cybersecurity LHC.lu - Licensed under GNU Affero GPL v3
 * @license   MONARC is licensed under GNU Affero General Public License version 3
 */

// Run from the application directory. Uses fresh, isolated metadata without installed-data writes.
require getcwd() . '/vendor/autoload.php';
require_once dirname(getcwd()) . '/zm-core/tests/Fixture/MappingTestEnvironment.php';
require_once dirname(getcwd()) . '/zm-core/tests/Fixture/MappingSnapshot.php';
$core = require dirname(getcwd()) . '/zm-core/config/module.config.php';
$office = require dirname(getcwd()) . '/zm-client/config/module.config.php';
$drivers = Laminas\Stdlib\ArrayUtils::merge($core['doctrine']['driver'], $office['doctrine']['driver']);
$snapshots = [];
foreach (['orm_default', 'orm_cli', 'orm_cli_fo'] as $name) {
    $manager = Monarc\Core\Tests\Fixture\MappingTestEnvironment::create($drivers, $name);
    try {
        $snapshots[$name] = Monarc\Core\Tests\Fixture\MappingSnapshot::capture($manager);
    } finally {
        $manager->close();
    }
}
echo json_encode($snapshots, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR) . PHP_EOL;
