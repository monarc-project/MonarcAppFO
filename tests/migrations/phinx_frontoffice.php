<?php

$config = require dirname(__DIR__) . '/config/local.php';

$connectionConf = [
    'adapter' => 'mysql',
    'host' => $config['doctrine']['connection']['orm_cli']['params']['host'],
    'name' => $config['doctrine']['connection']['orm_cli']['params']['dbname'],
    'user' => $config['doctrine']['connection']['orm_cli']['params']['user'],
    'pass' => $config['doctrine']['connection']['orm_cli']['params']['password'],
    'port' => $config['doctrine']['connection']['orm_cli']['params']['port'],
    'charset' => 'utf8',
];
if (isset($config['doctrine']['connection']['orm_cli']['params']['options'][PDO::MYSQL_ATTR_SSL_KEY])) {
    $connectionConf['ssl_key'] =
        $config['doctrine']['connection']['orm_cli']['params']['options'][PDO::MYSQL_ATTR_SSL_KEY];
}

return [
    'paths' => [
        'migrations' => dirname(__DIR__) . '/../module/Monarc/FrontOffice/migrations/db',
        'seeds' => dirname(__DIR__) . '/../module/Monarc/FrontOffice/migrations/seeds',
    ],
    'environments' => [
        'default_migration_table' => 'phinxlog',
        'default_database' => 'cli',
        'cli' => $connectionConf,
    ],
];
