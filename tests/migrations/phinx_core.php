<?php

$config = require dirname(__DIR__) . '/config/local.php';

$connectionConf = [
    'adapter' => 'mysql',
    'host' => $config['doctrine']['connection']['orm_default']['params']['host'],
    'name' => $config['doctrine']['connection']['orm_default']['params']['dbname'],
    'user' => $config['doctrine']['connection']['orm_default']['params']['user'],
    'pass' => $config['doctrine']['connection']['orm_default']['params']['password'],
    'port' => $config['doctrine']['connection']['orm_default']['params']['port'],
    'charset' => 'utf8',
];
if (isset($config['doctrine']['connection']['orm_default']['params']['options'][PDO::MYSQL_ATTR_SSL_KEY])) {
    $connectionConf['ssl_key'] =
        $config['doctrine']['connection']['orm_default']['params']['options'][PDO::MYSQL_ATTR_SSL_KEY];
}

return [
    'paths' => [
        'migrations' => dirname(__DIR__) . '/../module/Monarc/Core/migrations/db',
        'seeds' => dirname(__DIR__) . '/../module/Monarc/Core/migrations/seeds',
    ],
    'environments' => [
        'default_migration_table' => 'phinxlog',
        'default_database' => 'common',
        'common' => $connectionConf,
    ],
];
