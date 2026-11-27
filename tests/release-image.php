<?php declare(strict_types=1);

// Build-time checks: a release image must contain compiled assets and their targets.
foreach (['bcmath', 'curl', 'dom', 'gd', 'gettext', 'intl', 'mbstring', 'pdo_mysql', 'xml', 'zip', 'imagick', 'Zend OPcache'] as $extension) {
    if (!extension_loaded($extension)) {
        throw new RuntimeException('Missing runtime extension: ' . $extension);
    }
}
if (PHP_VERSION_ID < 80428 || PHP_VERSION_ID >= 80500) {
    throw new RuntimeException('Release images require PHP 8.4.28 or a later PHP 8.4 patch.');
}
$manifest = json_decode(file_get_contents('package.json'), true, 512, JSON_THROW_ON_ERROR);
foreach ($manifest['dependencies'] as $name => $specification) {
    if (!str_starts_with($name, 'ng_')) {
        continue;
    }
    $marker = 'node_modules/' . $name . '/.monarc-source-ref';
    if (!is_file($marker) || trim(file_get_contents($marker)) !== substr($specification, strrpos($specification, '#') + 1)) {
        throw new RuntimeException('Missing or mismatched frontend release: ' . $name);
    }
}
foreach (['db-bootstrap/monarc_structure.sql', 'db-bootstrap/monarc_data.sql',
    'module/Monarc/Core/Module.php',
    'module/Monarc/' . (is_dir('node_modules/ng_client') ? 'FrontOffice' : 'BackOffice') . '/Module.php',
    'public/js/angular-common-libs.js', 'public/css/angular-common-libs.css', 'public/js/translations.js'] as $asset) {
    if (!is_file($asset) || filesize($asset) === 0) {
        throw new RuntimeException('Missing prepared release file: ' . $asset);
    }
}
$frontend = is_dir('node_modules/ng_client') ? 'ng_client' : 'ng_backoffice';
if ($frontend === 'ng_client' && !is_file('data/fonts/arial.ttf')) {
    throw new RuntimeException('The CAPTCHA font is missing.');
}
if (glob('node_modules/' . $frontend . '/po/*.mo') === []) {
    throw new RuntimeException('Compiled backend translations are missing.');
}
foreach (new RecursiveIteratorIterator(new RecursiveDirectoryIterator('public', FilesystemIterator::SKIP_DOTS)) as $file) {
    if ($file->isLink() && !file_exists($file->getPathname())) {
        throw new RuntimeException('Broken public asset link: ' . $file->getPathname());
    }
}
foreach (['config/autoload/local.php', 'config/development.config.php', 'docker/db_data', '.docker-initialized'] as $path) {
    if (file_exists($path)) {
        throw new RuntimeException('Local state must not be packaged: ' . $path);
    }
}
echo "Release image runtime and assets verified.\n";
