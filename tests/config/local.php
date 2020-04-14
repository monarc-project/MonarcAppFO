<?php

use Doctrine\DBAL\Driver\PDOSqlite\Driver;

$appdir = dirname(__DIR__);

return [
    'doctrine' => [
        'connection' => [
            'orm_default' => [
                'params' => array(
                    'host' => 'localhost',
                    'user' => 'sqlmonarcuser',
                    'password' => 'sqlmonarcuser',
                    'dbname' => 'monarc_common_test',
                    'port' => 3306,
                ),
            ],
            'orm_cli' => [
                'params' => array(
                    'host' => 'localhost',
                    'user' => 'sqlmonarcuser',
                    'password' => 'sqlmonarcuser',
                    'dbname' => 'monarc_cli_test',
                    'port' => 3306,
                ),
            ],
        ],
        'entitymanager' => [
            'orm_default' => [
                'connection'    => 'orm_default',
                'configuration' => 'orm_default'
            ],
            'orm_cli' => [
                'connection'    => 'orm_cli',
                'configuration' => 'orm_cli',
            ],
        ],
        'configuration' => [
            'orm_default' => [
                'metadata_cache'        => 'array',
                'query_cache'           => 'array',
                'result_cache'          => 'array',
                'driver'                => 'orm_default',
                'generate_proxies'      => false,
                'filters'               => [],
                'datetime_functions'    => [],
                'string_functions'      => [],
                'numeric_functions'     => [],
                'second_level_cache'    => [],
            ],
            'orm_cli' => [
                'metadata_cache'        => 'array',
                'query_cache'           => 'array',
                'result_cache'          => 'array',
                'driver'                => 'orm_cli',
                'generate_proxies'      => false,
                'filters'               => [],
                'datetime_functions'    => [],
                'string_functions'      => [],
                'numeric_functions'     => [],
                'second_level_cache'    => [],
            ],
        ],
    ],

    'activeLanguages' => ['fr', 'en', 'de', 'nl',],

    'appVersion' => '3.0.0',

    'checkVersion' => false,
    'appCheckingURL' => 'https://version.monarc.lu/check/MONARC',

    'email' => [
        'name' => 'MONARC',
        'from' => 'info@monarc.lu',
    ],

    'mospApiUrl' => 'https://objects.monarc.lu/api/v1/',

    'monarc' => [
        'ttl' => 60,
        'salt' => '',
    ],
];
