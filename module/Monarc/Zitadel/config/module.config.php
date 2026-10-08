<?php declare(strict_types=1);

use Laminas\ServiceManager\AbstractFactory\ReflectionBasedAbstractFactory;
use Monarc\Zitadel\Controller\ZitadelAuthController;
use Monarc\Zitadel\Service\ZitadelAuthService;
use Psr\Container\ContainerInterface;
use Monarc\Core\Storage\Authentication as AuthenticationStorage;
use Monarc\FrontOffice\Table\UserTable;

return [
    'router' => [
        'routes' => [
            'monarc_api_zitadel_login' => [
                'type' => 'literal',
                'options' => [
                    'route'    => '/api/auth/zitadel/login',
                    'defaults' => [
                        'controller' => ZitadelAuthController::class,
                        'action'     => 'login',
                    ],
                ],
            ],
            'monarc_api_zitadel_callback' => [
                'type' => 'literal',
                'options' => [
                    'route'    => '/api/auth/zitadel/callback',
                    'defaults' => [
                        'controller' => ZitadelAuthController::class,
                        'action'     => 'callback',
                    ],
                ],
            ],
            'monarc_api_zitadel_logout' => [
                'type' => 'literal',
                'options' => [
                    'route'    => '/api/auth/zitadel/logout',
                    'defaults' => [
                        'controller' => ZitadelAuthController::class,
                        'action'     => 'logout',
                    ],
                ],
            ],
            'monarc_api_zitadel_logout_callback' => [
                'type' => 'literal',
                'options' => [
                    'route'    => '/api/auth/zitadel/logout/callback',
                    'defaults' => [
                        'controller' => ZitadelAuthController::class,
                        'action'     => 'logoutCallback',
                    ],
                ],
            ],
        ],
    ],

    'controllers' => [
        'factories' => [
            ZitadelAuthController::class => ReflectionBasedAbstractFactory::class,
        ],
    ],

    'service_manager' => [
        'factories' => [
            ZitadelAuthService::class => static function (ContainerInterface $container): ZitadelAuthService {
                $config  = $container->get('Config');
                $zitadel = $config['zitadel'] ?? [];

                return new ZitadelAuthService(
                    $container->get(AuthenticationStorage::class),
                    $container->get(UserTable::class),
                    $zitadel['domain']         ?? '',
                    $zitadel['backchannelDomain'] ?? '',
                    $zitadel['backchannelHostHeader'] ?? '',
                    $zitadel['clientId']       ?? '',
                    $zitadel['clientSecret']   ?? '',
                    $zitadel['callbackUrl']    ?? '',
                    $zitadel['postLogoutUrl']  ?? '',
                    $zitadel['postLoginUrl']   ?? '',
                    $zitadel['scopes']         ?? [],
                    $zitadel['autoProvisionUsers'] ?? true,
                    $zitadel['requireEmailVerified'] ?? true,
                    $zitadel['allowedEmailDomains'] ?? [],
                    $zitadel['allowedResourceOwnerIds'] ?? [],
                    $zitadel['defaultRole']    ?? 'userfo',
                    $zitadel['defaultLanguage'] ?? ($config['defaultLanguageIndex'] ?? 1),
                    $zitadel['clockSkewSeconds'] ?? 60,
                );
            },
        ],
    ],

    // Whitelisted these routes so they bypass the token-auth middleware
    'permissions' => [
        'monarc_api_zitadel_login',
        'monarc_api_zitadel_callback',
        'monarc_api_zitadel_logout',
        'monarc_api_zitadel_logout_callback',
    ],
];
