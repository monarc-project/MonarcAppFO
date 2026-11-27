<?php

// Copied into config/autoload by the development Docker entrypoint.
if (getenv('APP_ENV') !== 'development') {
    return [];
}

return [
    'smtpOptions' => [
        'host' => getenv('SMTP_HOST') ?: 'mailcatcher',
        'port' => (int) (getenv('SMTP_PORT') ?: 1025),
    ],
];
