<?php declare(strict_types=1);
/**
 * @link      https://github.com/monarc-project for the canonical source repository
 * @copyright Copyright (c) 2016-2026 Luxembourg House of Cybersecurity LHC.lu - Licensed under GNU Affero GPL v3
 * @license   MONARC is licensed under GNU Affero General Public License version 3
 */

// Run from an initialized local application directory, after its image rebuild.
use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\Tools\SchemaValidator;
use Laminas\Mvc\Application;
use Monarc\Core\Entity\Asset;
use Monarc\Core\Entity\Guide;
use Monarc\Core\InputFormatter\Asset\GetAssetsInputFormatter;
use Monarc\Core\Service\AssetService;
use Monarc\Core\Service\ConnectedUserService;
use Monarc\Core\Service\GuideService;

$phase = 'environment';
set_error_handler(static function (int $severity, string $message, string $file, int $line): bool {
    if (error_reporting() & $severity) {
        throw new ErrorException($message, 0, $severity, $file, $line);
    }

    return false;
});
try {
    if (getenv('APP_ENV') !== 'development') {
        throw new RuntimeException('Run only in the local development application.');
    }
    if (PHP_VERSION_ID < 80428 || PHP_VERSION_ID >= 80500) {
        throw new RuntimeException('PHP >=8.4.28 <8.5 is required.');
    }
    $appDir = getcwd();
    require $appDir . '/vendor/autoload.php';
    $office = 'FrontOffice';
    $controller = Monarc\FrontOffice\Controller\ApiAnrAssetsController::class;
    $sources = [Asset::class => 'zm-core', Guide::class => 'zm-core', $controller => 'zm-client'];
    $released = in_array('--released', $argv, true);
    $coreDir = $released ? $appDir . '/vendor/monarc/core' : dirname($appDir) . '/zm-core';
    $officeDir = $released ? $appDir . '/vendor/monarc/frontoffice' : dirname($appDir) . '/zm-client';
    $phase = $released ? 'released sources' : 'local sources';
    foreach ($sources as $class => $repo) {
        $actual = realpath((new ReflectionClass($class))->getFileName());
        $moduleDir = $repo === 'zm-core' ? $coreDir : $officeDir;
        if ($released && is_link($moduleDir)) {
            throw new RuntimeException('Released modules cannot use sibling symlinks.');
        }
        $expected = realpath($moduleDir . '/src');
        if ($expected === false || !str_starts_with($actual, $expected . '/')) {
            throw new RuntimeException('A module does not resolve to the selected source mode.');
        }
    }
    $dependency = realpath((new ReflectionClass(EntityManagerInterface::class))->getFileName());
    if (!str_starts_with($dependency, realpath($appDir . '/vendor') . '/')) {
        throw new RuntimeException('Doctrine does not resolve through this application vendor directory.');
    }
    $phase = 'application bootstrap';
    $app = Application::init(require $appDir . '/config/application.config.php');
    $container = $app->getServiceManager();
    $metadataCounts = [];
    $mappingDiagnostics = [];
    // Require clean mappings in every active manager; no historical exemptions.
    $strictMapping = true;
    foreach (['orm_default', 'orm_cli'] as $name) {
        $phase = $name . ' database';
        $manager = $container->get('doctrine.entitymanager.' . $name);
        if ((int)$manager->getConnection()->fetchOne('SELECT 1') !== 1) {
            throw new RuntimeException('Database read probe failed.');
        }
        $phase = $name . ' metadata';
        $manager->getConfiguration()->getMetadataCache()?->clear();
        $metadata = $manager->getMetadataFactory()->getAllMetadata();
        if ($metadata === []) {
            throw new RuntimeException('No Doctrine metadata was loaded.');
        }
        $mappingErrors = (new SchemaValidator($manager))->validateMapping();
        if ($mappingErrors !== []) {
            $diagnostic = json_encode(['unexpectedMappingErrors' => $mappingErrors], JSON_THROW_ON_ERROR);
            fwrite(STDERR, $diagnostic . PHP_EOL);
            throw new RuntimeException('Doctrine mapping validation failed.');
        }
        $phase = $name . ' native mapping parity';
        require_once $coreDir . '/tests/Fixture/MappingTestEnvironment.php';
        require_once $coreDir . '/tests/Fixture/MappingSnapshot.php';
        $driver = $manager->getConfiguration()->getMetadataDriverImpl();
        if (!$driver instanceof \Doctrine\Persistence\Mapping\Driver\MappingDriverChain) {
            throw new RuntimeException('Entity managers must retain namespace driver chains.');
        }
        foreach ($driver->getDrivers() as $leaf) {
            if (!$leaf instanceof \Doctrine\ORM\Mapping\Driver\AttributeDriver) {
                throw new RuntimeException('Every mapping leaf must use native attributes.');
            }
        }
        $expectedMappings = json_decode(
            file_get_contents($appDir . '/tests/Fixture/attribute-mapping-fingerprints.json'),
            true,
            512,
            JSON_THROW_ON_ERROR
        );
        $actualMappings = \Monarc\Core\Tests\Fixture\MappingSnapshot::fingerprints(
            \Monarc\Core\Tests\Fixture\MappingSnapshot::capture($manager)
        );
        if ($expectedMappings[$name] !== $actualMappings) {
            throw new RuntimeException('Native mappings differ from the captured persisted metadata/schema.');
        }
        $mappingDiagnostics[$name] = array_sum(array_map('count', $mappingErrors));
        $phase = $name . ' proxies';
        $manager->getProxyFactory()->generateProxyClasses($metadata);
        $metadataCounts[$name] = count($metadata);
    }
    $phase = 'service container';
    // An unsaved identity initializes services that require a connected user.
    // No login, user token, persisted user or database write is involved.
    $container->get(ConnectedUserService::class)->setConnectedUser(new \Monarc\FrontOffice\Entity\User([
        'firstname' => 'Local',
        'lastname' => 'Readiness',
        'email' => 'readiness@example.invalid',
        'creator' => 'readiness-probe',
        'role' => [],
    ]));
    $container->get(GetAssetsInputFormatter::class);
    $container->get('ControllerManager')->get($controller);
    foreach ([
        Monarc\Core\Service\ModelService::class,
        Monarc\Core\Service\ObjectService::class,
        Monarc\Core\Service\ObjectObjectService::class,
        Monarc\Core\Service\ScaleCommentService::class,
    ] as $service) {
        $container->get($service);
    }
    $container->get(Monarc\FrontOffice\Service\AnrScaleCommentService::class);
    $phase = 'modern asset read';
    $params = $container->get(GetAssetsInputFormatter::class)->format([]);
    $assetCount = $container->get(AssetService::class)->getCount($params);
    $phase = 'modern guide read';
    $guideParams = (new Monarc\Core\InputFormatter\Guide\GetGuidesInputFormatter())->format(['limit' => 1]);
    $guides = $container->get(GuideService::class)->getList($guideParams);
    $guideChecks = [];
    if (in_array('--guides', $argv, true)) {
        $phase = 'guide workflows';
        require_once $officeDir . '/tests/Runtime/GuideRuntimeChecks.php';
        $guideChecks = MonarcFrontOfficeTests\Runtime\GuideRuntimeChecks::run($container, $phase);
    }
    $questionChecks = [];
    if (in_array('--questions', $argv, true)) {
        $phase = 'question workflows';
        require_once $coreDir . '/tests/Runtime/QuestionRuntimeChecks.php';
        $questionChecks = Monarc\Core\Tests\Runtime\QuestionRuntimeChecks::run($container, $phase);
        $phase = 'analysis question workflows';
        require_once $officeDir . '/tests/Runtime/QuestionRuntimeChecks.php';
        $questionChecks = array_merge(
            $questionChecks,
            MonarcFrontOfficeTests\Runtime\QuestionRuntimeChecks::run($container, $phase)
        );
    }
    $interviewChecks = [];
    if (in_array('--interviews', $argv, true)) {
        $phase = 'interview workflows';
        require_once $officeDir . '/tests/Runtime/InterviewRuntimeChecks.php';
        $interviewChecks = MonarcFrontOfficeTests\Runtime\InterviewRuntimeChecks::run($container, $phase);
    }
    $ropaChecks = [];
    if (in_array('--ropa', $argv, true)) {
        $phase = 'ROPA workflows';
        require_once $officeDir . '/tests/Runtime/RopaRuntimeChecks.php';
        $ropaChecks = MonarcFrontOfficeTests\Runtime\RopaRuntimeChecks::run($container, $phase);
    }
    $deliveryModelChecks = [];
    if (in_array('--delivery-models', $argv, true)) {
        $phase = 'delivery model workflows';
        require_once $officeDir . '/tests/Runtime/DeliveryModelRuntimeChecks.php';
        $deliveryModelChecks = MonarcFrontOfficeTests\Runtime\DeliveryModelRuntimeChecks::run($container, $phase);
    }
    $historicalChecks = [];
    if (in_array('--historicals', $argv, true)) {
        require_once $coreDir . '/tests/Runtime/HistoricalRuntimeChecks.php';
        $historicalChecks = Monarc\Core\Tests\Runtime\HistoricalRuntimeChecks::run($container, $phase);
        $phase = 'separate FrontOffice history/report consumers';
        $container->get(Monarc\FrontOffice\Service\AnrHistoryService::class);
        $container->get(Monarc\FrontOffice\Service\AnrRecommendationHistoryService::class);
        $container->get(Monarc\FrontOffice\Service\DeliverableGenerationService::class);
        $analysis = $container->get(Monarc\FrontOffice\Table\AnrTable::class)->findByParams(
            (new Monarc\Core\InputFormatter\FormattedInputParams())->setLimit(1)
        );
        if ($analysis !== []) {
            $container->get(Monarc\FrontOffice\Service\AnrHistoryService::class)->getHistory($analysis[0]);
            $container->get(Monarc\FrontOffice\Table\RecommendationHistoryTable::class)->findByAnr($analysis[0]);
        }
        $historicalChecks['frontOfficeModernConsumers'] = 'DI and available analysis history reads passed';
    }
    echo json_encode([
        'office' => $office,
        'php' => PHP_VERSION,
        'sources' => array_map(static function (string $class): string {
            return realpath((new ReflectionClass($class))->getFileName());
        }, array_keys($sources)),
        'metadata' => $metadataCounts,
        'existingMappingDiagnostics' => $mappingDiagnostics,
        'strictMapping' => $strictMapping,
        'assetCount' => $assetCount,
        'guideCount' => count($guides),
        'deliveryModelChecks' => $deliveryModelChecks,
        'historicalChecks' => $historicalChecks,
        'guideChecks' => $guideChecks,
        'questionChecks' => $questionChecks,
        'interviewChecks' => $interviewChecks,
        'ropaChecks' => $ropaChecks,
        'result' => 'passed',
    ], JSON_PRETTY_PRINT | JSON_THROW_ON_ERROR) . PHP_EOL;
} catch (Throwable $error) {
    // Do not serialize application configuration or connection exception traces.
    fwrite(STDERR, 'Readiness validation failed at ' . $phase . ': ' . get_class($error)
        . ' in ' . $error->getFile() . ':' . $error->getLine() . PHP_EOL);
    if ($error instanceof Doctrine\DBAL\Exception\DriverException) {
        fwrite(STDERR, 'Database SQLSTATE: ' . $error->getSQLState()
            . '; driver code: ' . $error->getPrevious()->getCode() . PHP_EOL);
    }
    exit(1);
}
