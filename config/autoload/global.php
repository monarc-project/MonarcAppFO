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
return array(
    'doctrine' => array(
        'connection' => array(
            'orm_default' => array(
                'driverClass' => 'Doctrine\DBAL\Driver\PDOMySql\Driver',
                'params' => array(
                    'host' => 'localhost',
                    'port' => 3306,
                    'user' => 'user',
                    'password' => 'password',
                    'dbname' => 'monarc',
                    'charset' => 'utf8',
                    'driverOptions' => array(
                        PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8',
                    ),
                ),
            ),
        ),
        'migrations_configuration' => array(
            'orm_default' => array(
                'name' => 'Monarc Migrations',
                'directory' => __DIR__."/../../migrations",
                'namespace' => 'Monarc\Migrations',
                'table_name' => 'doctrine_migrations',
            ),
        ),
    ),
    'roles' => array(
        'superadmin'=> array(
            'auth',
            'monarc_api_admin_users',
            'monarc_api_admin_servers',
        ),
        'dbadmin'=> array(
            'auth',
            'monarc_api_admin_users',
            'monarc_api_admin_servers',
        ),
        'sysadmin'=> array(
            'auth',
            'monarc_api_admin_servers',
        ),
        'accadmin'=> array(
            'auth',
            'monarc_api_admin_users',
        ),
    )
);
