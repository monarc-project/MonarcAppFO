<?php
$appdir = getenv('APP_DIR') ?: '/home/vagrant/monarc';
$string = file_get_contents($appdir.'/package.json');
if (!$string) {
    $string = file_get_contents('./package.json');
}
$package_json = json_decode($string, true);

return [
    'doctrine' => [
        'connection' => [
            'orm_default' => [
                'params' => [
                    'host' => 'monarc_mariadb',
                    'user' => 'sqlmonarcuser',
                    'password' => 'sqlmonarcuser',
                    'dbname' => 'monarc_common',
                ],
            ],
            'orm_cli' => [
                'params' => [
                    'host' => 'monarc_mariadb',
                    'user' => 'sqlmonarcuser',
                    'password' => 'sqlmonarcuser',
                    'dbname' => 'monarc_cli',
                ],
            ],
        ],
    ],

    'activeLanguages' => array('fr','en','de','nl','es','ro','it','ja','pl','pt','ru','zh'),

    'appVersion' => $package_json['version'],

    'checkVersion' => false,
    'appCheckingURL' => 'https://version.monarc.lu/check/MONARC',

    'email' => [
        'name' => 'MONARC',
        'from' => 'info@monarc.lu',
    ],

    'mospApiUrl' => 'https://objects.monarc.lu/api/',

    'monarc' => [
        'ttl' => 60, // timeout
        'salt' => '', // private salt for password encryption
    ],

    'statsApi' => [
        'baseUrl' => '',
        'apiKey' => '',
    ],
];
