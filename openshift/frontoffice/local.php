<?php
$dbhost = getenv('DBHOST');
$dbuser_monarc = getenv('DBUSER_MONARC');
$dbpassword_monarc = getenv('DBPASSWORD_MONARC');
$dbname_common = getenv('DBNAME_COMMON');
$dbname_cli = getenv('DBNAME_CLI');
$stats_api_base_url = getenv('STATS_API_BASE_URL') ? getenv('STATS_API_BASE_URL') : 'http://stats-service:5005';
$stats_api_key = getenv('STATS_API_KEY') ? getenv('STATS_API_KEY') : "null";
$pdf_converter_binary = getenv('PDF_CONVERTER_BINARY') ? getenv('PDF_CONVERTER_BINARY') : '/usr/bin/soffice';
$captcha_enabled_php = getenv('CAPTCHA_ENABLED_PHP');
$smtp_host = getenv('SMTP_HOST');
$smtp_port = getenv('SMTP_PORT');
$smtp_sender = getenv('SMTP_SENDER');
$smtp_sender_email = getenv('SMTP_SENDER_EMAIL');

$appdir = getenv('APP_DIR') ? getenv('APP_DIR') : '/var/www/html/monarc';
$string = file_get_contents($appdir.'/package.json');
if($string === FALSE) {
    $string = file_get_contents('./package.json');
}
$package_json = json_decode($string, true);

return [
    'doctrine' => [
        'connection' => [
            'orm_default' => [
                'params' => [
                    'host' => $dbhost,
                    'user' => $dbuser_monarc,
                    'password' => $dbpassword_monarc,
                    'dbname' => $dbname_common,
                ],
            ],
            'orm_cli' => [
                'params' => [
                    'host' => $dbhost,
                    'user' => $dbuser_monarc,
                    'password' => $dbpassword_monarc,
                    'dbname' => $dbname_cli,
                ],
            ],
        ],
    ],

    'defaultLanguageIndex' => 1,

     // Languages available for the analysis / DB data.
    'languages' => [
        'fr' => ['index' => 1, 'label' => 'Français'],
        'en' => ['index' => 2, 'label' => 'English'],
        'de' => ['index' => 3, 'label' => 'Deutsch'],
        'nl' => ['index' => 4, 'label' => 'Dutch'],
    ],

    // Languages available for the user interface.
    'activeLanguages' => ['fr', 'en', 'de', 'nl', 'es', 'ro', 'it', 'ja', 'pl', 'pt', 'zh'],

    'appVersion' => $package_json['version'],

    'checkVersion' => false,
    'appCheckingURL' => 'https://version.monarc.lu/check/MONARC',

    'email' => [
        'name' => $smtp_sender,
        'from' => $smtp_sender_email,
    ],

    'mospApiUrl' => 'https://objects.monarc.lu/api/',

    'monarc' => [
        'ttl' => 60, // timeout
    ],

    'statsApi' => [
        'baseUrl' => $stats_api_base_url,
        'apiKey' => $stats_api_key,
    ],

    'deliverable' => [
        'pdfConverterBinary' => $pdf_converter_binary,
    ],

    'captcha' => [
        'enabled' => $captcha_enabled_php,
        'failedLoginAttempts' => 3,
        'params' => [
            'name' => 'MonarcCaptcha',
            'font' => $appdir . '/data/fonts/arial.ttf',
            'fontSize' => 30,
            'height' => 60,
            'wordLen' => 6,
            'timeout' => 300,
            'imgDir' => $appdir . '/public/captcha',
            'imgUrl' => 'captcha/',
        ],
    ],

    'import' => [
        'uploadFolder' => "${appdir}/data/import/files",
        'isBackgroundProcessActive' => false,
    ],

    'smtpOptions' => [
        'name' => "Monarc",
        'host' => $smtp_host,
        'port' => $smtp_port
    ],
];
