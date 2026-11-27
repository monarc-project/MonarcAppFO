<?php declare(strict_types=1);
/**
 * @link      https://github.com/monarc-project for the canonical source repository
 * @copyright Copyright (c) 2016-2026 Luxembourg House of Cybersecurity LHC.lu - Licensed under GNU Affero GPL v3
 * @license   MONARC is licensed under GNU Affero General Public License version 3
 */

// Run from this application's directory. Never certify a lock using an older vendor graph.
require_once getcwd() . '/vendor/autoload.php';
$lock = json_decode(file_get_contents(getcwd() . '/composer.lock'), true, 512, JSON_THROW_ON_ERROR);
foreach ($lock['packages'] as $package) {
    if (!in_array($package['name'], ['doctrine/orm', 'doctrine/dbal'], true)) {
        continue;
    }
    $installed = Composer\InstalledVersions::getPrettyVersion($package['name']);
    if ($installed !== $package['version']) {
        fwrite(STDERR, $package['name'] . ': installed ' . $installed . ', locked ' . $package['version']
            . '; run composer install before validation.' . PHP_EOL);
        exit(1);
    }
}
echo 'Installed Doctrine versions match the application lock.' . PHP_EOL;
