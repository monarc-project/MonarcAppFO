<?php
/**
 * Global Configuration Override
 *
 * You can use this file for overriding configuration values from modules, etc.
 * You would place values in here that are agnostic to the environment and not
 * sensitive to security.
 *
 * @NOTE: In practice, this file will typically be INCLUDED in your source
 * control, so do not include passwords or other sensitive information in this
 * file.
 */

use Doctrine\DBAL\Driver\PDO\MySQL\Driver;
use Monarc\Core\Service\DoctrineCacheServiceFactory;
use Monarc\Core\Service\DoctrineLoggerFactory;

$dataPath = 'data';
if (defined('DATA_PATH')) {
    $dataPath = DATA_PATH;
} elseif (getenv('APP_CONF_DIR')) {
    $dataPath = getenv('APP_CONF_DIR') . '/data';
}

return [
    // DOCTRINE CONF
    'service_manager' => [
        'factories' => [
            'doctrine.cache.mycache' => DoctrineCacheServiceFactory::class,
            'doctrine.monarc_logger' => DoctrineLoggerFactory::class,
        ],
    ],
    'doctrine' => [
        'connection' => [
            'orm_default' => [
                'driverClass' => Driver::class,
                'params' => [
                    'host' => 'localhost',
                    'port' => 3306,
                    'user' => 'root',
                    'password' => '',
                    'dbname' => 'monarc_common',
                    'charset' => 'utf8',
                    'driverOptions' => [
                        PDO::ATTR_STRINGIFY_FETCHES => false,
                        PDO::ATTR_EMULATE_PREPARES => false,
                        PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8',
                    ],
                ],
            ],
            'orm_cli' => [
                'driverClass' => Driver::class,
                'params' => [
                    'host' => 'localhost',
                    'port' => 3306,
                    'user' => 'root',
                    'password' => '',
                    'dbname' => 'monarc_cli',
                    'charset' => 'utf8',
                    'driverOptions' => [
                        PDO::ATTR_STRINGIFY_FETCHES => false,
                        PDO::ATTR_EMULATE_PREPARES => false,
                        PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8',
                    ],
                ],
            ],
        ],
        /*'migrations_configuration' => array(
            'orm_default' => array(
                'name' => 'Monarc Migrations',
                'directory' => __DIR__."/../../migrations",
                'namespace' => 'Monarc\Migrations',
                'table' => 'migrations',
                'column' => 'version',
            ),
            'orm_cli' => array(
                'name' => 'Monarc Common Migrations',
                'directory' => __DIR__."/../../migrations",
                'namespace' => 'MonarcCli\Migrations',
                'table' => 'migrations',
                'column' => 'version',
            ),
        ),*/
        'entitymanager' => [
            'orm_default' => [
                'connection' => 'orm_default',
                'configuration' => 'orm_default',
            ],
            'orm_cli' => [
                'connection' => 'orm_cli',
                'configuration' => 'orm_cli',
            ],
        ],
        // https://github.com/beberlei/DoctrineExtensions/blob/master/config/mysql.yml
        'configuration' => [
            'orm_default' => [
                'metadata_cache' => 'mycache',
                'query_cache' => 'mycache',
                'result_cache' => 'mycache',
                'driver' => 'orm_default', // This driver will be defined later
                'generate_proxies' => true,
                'proxy_dir' => $dataPath . '/DoctrineORMModule/Proxy',
                'proxy_namespace' => 'DoctrineORMModule\Proxy',
                'filters' => [],
                'datetime_functions' => [],
                'string_functions' => [],
                'numeric_functions' => [],
                'second_level_cache' => [],
                'sql_logger' => 'doctrine.monarc_logger',
            ],
            'orm_cli' => [
                'metadata_cache' => 'mycache',
                'query_cache' => 'mycache',
                'result_cache' => 'mycache',
                'driver' => 'orm_cli', // This driver will be defined later
                'generate_proxies' => true,
                'proxy_dir' => $dataPath . '/DoctrineORMModule/Proxy',
                'proxy_namespace' => 'DoctrineORMModule\Proxy',
                'filters' => [],
                'datetime_functions' => [],
                'string_functions' => [],
                'numeric_functions' => [],
                'second_level_cache' => [],
                'sql_logger' => 'doctrine.monarc_logger',
            ],
        ],
    ],
    // END DOCTRINE CONF
];
