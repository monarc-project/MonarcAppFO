<?php declare(strict_types=1);
/**
 * @link      https://github.com/monarc-project for the canonical source repository
 * @copyright Copyright (c) 2016-2026 Luxembourg House of Cybersecurity LHC.lu - Licensed under GNU Affero GPL v3
 * @license   MONARC is licensed under GNU Affero General Public License version 3
 */

// Run from an assembled application, including an install with --no-dev.
require getcwd() . '/vendor/autoload.php';
$manifest = json_decode(file_get_contents('composer.json'), true, 512, JSON_THROW_ON_ERROR);
$lock = json_decode(file_get_contents('composer.lock'), true, 512, JSON_THROW_ON_ERROR);
if ($manifest['minimum-stability'] !== 'stable' || !empty($manifest['repositories'])) {
    throw new RuntimeException('Release manifests must use stable packages from Packagist.');
}
$classes = [
    'monarc/core' => Monarc\Core\Entity\Asset::class,
    'monarc/frontoffice' => Monarc\FrontOffice\Controller\ApiAnrAssetsController::class,
    'monarc/backoffice' => Monarc\BackOffice\Controller\ApiAssetsController::class,
];
$versions = [];
foreach ($lock['packages'] as $package) {
    $name = $package['name'];
    if (!isset($classes[$name])) {
        continue;
    }
    $installPath = Composer\InstalledVersions::getInstallPath($name);
    $expectedPath = getcwd() . '/vendor/' . $name;
    if (!preg_match('/^v?\d+\.\d+\.\d+(?:\.\d+)?$/', $package['version'])
        || ($package['dist']['type'] ?? '') !== 'zip'
        || is_link($expectedPath)
        || realpath($installPath) !== realpath($expectedPath)
        || Composer\InstalledVersions::getPrettyVersion($name) !== $package['version']
        || Composer\InstalledVersions::getReference($name) !== $package['source']['reference']
    ) {
        throw new RuntimeException($name . ' must match its locked release in vendor, without a path override.');
    }
    $source = realpath((new ReflectionClass($classes[$name]))->getFileName());
    if (!str_starts_with($source, realpath($expectedPath) . '/src/')) {
        throw new RuntimeException($name . ' loads classes outside its released vendor package.');
    }
    $versions[$name] = ['version' => $package['version'], 'reference' => $package['source']['reference']];
}
foreach ($manifest['require'] as $name => $constraint) {
    if (isset($classes[$name]) && !isset($versions[$name])) {
        throw new RuntimeException('Missing locked release: ' . $name);
    }
}
echo json_encode(['releasedSources' => $versions, 'result' => 'passed'], JSON_PRETTY_PRINT | JSON_THROW_ON_ERROR)
    . PHP_EOL;
