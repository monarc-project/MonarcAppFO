<?php

namespace MonarcAppFo\Tests\Integration\Service;

use GuzzleHttp\Handler\MockHandler;
use GuzzleHttp\Psr7\Response;
use Laminas\ServiceManager\ServiceManager;
use Monarc\FrontOffice\Model\Table\AnrTable;
use Monarc\FrontOffice\Model\Table\SettingTable;
use Monarc\FrontOffice\Provider\StatsApiProvider;
use Monarc\FrontOffice\Service\Exception\StatsAlreadyCollectedException;
use Monarc\FrontOffice\Service\StatsAnrService;
use MonarcAppFo\Tests\Integration\AbstractIntegrationTestCase;

class StatsApiServiceTest extends AbstractIntegrationTestCase
{
    /** @var MockHandler */
    private $mockHandler;

    public static function setUpBeforeClass(): void
    {
        parent::setUpBeforeClass();

        static::createMyPrintTestData();
    }

    protected function configureServiceManager(ServiceManager $serviceManager)
    {
        $serviceManager->setAllowOverride(true);

        $this->mockHandler = new MockHandler();
        $statsApiProvider = new StatsApiProvider(
            $serviceManager->get(SettingTable::class),
            [],
            $this->mockHandler
        );
        $serviceManager->setService(StatsApiProvider::class, $statsApiProvider);

        $serviceManager->setAllowOverride(false);
    }

    public function testItThrowsTheErrorWhenTheTheStatsAlreadyGeneratedForToday()
    {
        $this->expectException(StatsAlreadyCollectedException::class);
        $this->expectExceptionMessage('The stats is already collected for today.');

        $this->mockHandler->append(new Response(200, [], $this->getStatsResponse([['type' => 'risks']])));

        /** @var StatsAnrService $statsAnrService */
        $statsAnrService = $this->getApplicationServiceLocator()->get(StatsAnrService::class);
        $statsAnrService->collectStats();
    }

    public function testItDoesNotSendTheStatsWhenTheDataIsEmpty()
    {
        $this->mockHandler->append(new Response(200, [], $this->getStatsResponse()));

        /** @var StatsAnrService $statsAnrService */
        $statsAnrService = $this->getApplicationServiceLocator()->get(StatsAnrService::class);
        $statsAnrService->collectStats([99, 78]);

        $this->assertEquals('GET', $this->mockHandler->getLastRequest()->getMethod());
    }

    public function testItCanGenerateTheStatsForAllTheAnrs()
    {
        /** @var AnrTable $anrTable */
        $anrTable = $this->getApplicationServiceLocator()->get(AnrTable::class);
        $anrs = $anrTable->findAll();
        $anrUuid = [];
        foreach ($anrs as $anr) {
            $anrUuid[] = $anr->getUuid();
        }

        $this->mockHandler->append(new Response(200, [], $this->getStatsResponse()));
        $this->mockHandler->append(new Response(200, [], '{"status": "ok"}'));

        /** @var StatsAnrService $statsAnrService */
        $statsAnrService = $this->getApplicationServiceLocator()->get(StatsAnrService::class);
        $statsAnrService->collectStats();

        $this->assertJsonStringEqualsJsonString(
            $this->getExpectedStatsDataJson($anrUuid),
            $this->mockHandler->getLastRequest()->getBody()->getContents()
        );
    }

    public function testItGenerateTheStatsOnlyForPassedAnrs()
    {
        $anrIdsToGenerateTheStats = [1, 2, 3];

        /** @var AnrTable $anrTable */
        $anrTable = $this->getApplicationServiceLocator()->get(AnrTable::class);
        $anrs = $anrTable->findAll();
        $anrUuid = [];
        foreach ($anrs as $num => $anr) {
            if ($num + 1 > \count($anrIdsToGenerateTheStats)) {
                break;
            }
            $anrUuid[] = $anr->getUuid();
        }

        $this->mockHandler->append(new Response(200, [], $this->getStatsResponse()));
        $this->mockHandler->append(new Response(200, [], '{"status": "ok"}'));

        /** @var StatsAnrService $statsAnrService */
        $statsAnrService = $this->getApplicationServiceLocator()->get(StatsAnrService::class);
        $statsAnrService->collectStats($anrIdsToGenerateTheStats);

        $this->assertJsonStringEqualsJsonString(
            $this->getExpectedStatsDataJson($anrUuid),
            $this->mockHandler->getLastRequest()->getBody()->getContents()
        );
    }

    private function getStatsResponse(array $results = []): string
    {
        return json_encode([
            'metadata' => [
                'resultset' => [
                    'count' => \count($results),
                    'offset' => 0,
                    'limit' => 0,
                ],
            ],
            'results' => $results,
        ]);
    }

    private function getExpectedStatsDataJson(array $anrUuid): string
    {
        $allStatsData = json_decode(
            file_get_contents($this->testPath . '/data/expected_stats_data_for_all_anrs.json'),
            true
        );

        $expectedStats = [];
        foreach ($allStatsData as $num => $statsData) {
            if (!isset($anrUuid[$num])) {
                break;
            }
            $statsData['anr_uuid'] = $anrUuid[$num];
            $expectedStats[] = $statsData;
        }

        return json_encode($expectedStats);
    }
}
