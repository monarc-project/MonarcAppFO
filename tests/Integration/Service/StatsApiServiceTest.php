<?php

namespace MonarcAppFo\Tests\Integration\Service;

use DateTime;
use GuzzleHttp\Handler\MockHandler;
use GuzzleHttp\Psr7\Response;
use Laminas\ServiceManager\ServiceManager;
use Monarc\FrontOffice\Model\Table\AnrTable;
use Monarc\FrontOffice\Model\Table\SettingTable;
use Monarc\FrontOffice\Stats\DataObject\StatsDataObject;
use Monarc\FrontOffice\Stats\Exception\StatsAlreadyCollectedException;
use Monarc\FrontOffice\Stats\Provider\StatsApiProvider;
use Monarc\FrontOffice\Stats\Service\StatsAnrService;
use MonarcAppFo\Tests\Integration\AbstractIntegrationTestCase;

class StatsApiServiceTest extends AbstractIntegrationTestCase
{
    /** @var MockHandler */
    private $mockHandler;

    /** @var array */
    private $currentDateParams;

    public static function setUpBeforeClass(): void
    {
        parent::setUpBeforeClass();

        static::createMyPrintTestData();
    }

    public function setUp(): void
    {
        parent::setUp();

        $this->currentDateParams = $this->getCurrentDateParams();
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

        $this->mockHandler->append(new Response(200, [], $this->getStatsResponse([
            [
                'type' => StatsDataObject::TYPE_RISK,
                'data' => [
                    'category' => 'ANR 1',
                    'series' => [
                        [
                            'label' => 'Low risks',
                            'value' => 50,

                        ],
                        [
                            'label' => 'Medium risks',
                            'value' => 30,

                        ],
                        [
                            'label' => 'High risks',
                            'value' => 10,

                        ],
                    ],
                ],
            ],
        ])));

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
        $anrUuids = [];
        foreach ($anrs as $anr) {
            $anrUuids[] = $anr->getUuid();
        }

        $this->mockHandler->append(new Response(200, [], $this->getStatsResponse()));
        $this->mockHandler->append(new Response(201, [], '{"status": "ok"}'));

        /** @var StatsAnrService $statsAnrService */
        $statsAnrService = $this->getApplicationServiceLocator()->get(StatsAnrService::class);
        $statsAnrService->collectStats();

        $this->assertJsonStringEqualsJsonString(
            $this->getExpectedStatsDataJson($anrUuids),
            $this->mockHandler->getLastRequest()->getBody()->getContents()
        );
    }

    public function testItGenerateTheStatsOnlyForPassedAnrs()
    {
        $anrIdsToGenerateTheStats = [1, 2, 3];

        /** @var AnrTable $anrTable */
        $anrTable = $this->getApplicationServiceLocator()->get(AnrTable::class);
        $anrs = $anrTable->findByIds($anrIdsToGenerateTheStats);
        $anrUuids = [];
        foreach ($anrs as $num => $anr) {
            $anrUuids[] = $anr->getUuid();
        }

        $this->assertCount(\count($anrIdsToGenerateTheStats), $anrUuids);

        $this->mockHandler->append(new Response(200, [], $this->getStatsResponse()));
        $this->mockHandler->append(new Response(201, [], '{"status": "ok"}'));

        /** @var StatsAnrService $statsAnrService */
        $statsAnrService = $this->getApplicationServiceLocator()->get(StatsAnrService::class);
        $statsAnrService->collectStats($anrIdsToGenerateTheStats);

        $this->assertJsonStringEqualsJsonString(
            $this->getExpectedStatsDataJson($anrUuids),
            $this->mockHandler->getLastRequest()->getBody()->getContents()
        );
    }
/*
    public function testItThrowsTheExceptionIfUserIsNotLoggedIn()
    {

    }

    public function testItThrowsTheExceptionIfUserDeosNotHaveTheRightsToGetTheStats()
    {

    }

    public function testItAddsToTheFilterAlloedForTheUserAnrUuids()
    {

    }

    public function testItAllowsToFilterBySpecificAnrsForCeoRole()
    {

    }

    public function testItAllowsToGetStatsWithoutAnrsLimitationForCeoRole()
    {

    }

    public function testItCanSendDifferentAgregationParamsToGetTheStats()
    {

    }
*/
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
            'data' => $results,
        ]);
    }

    private function getExpectedStatsDataJson(array $anrUuids): string
    {
        $statsData = json_decode(
            file_get_contents($this->testPath . '/data/expected_stats_data_for_my_print.json'),
            true
        );

        $expectedStats = [];
        foreach ($anrUuids as $num => $anrUuid) {
            foreach ($statsData as $data) {
                $data['anr'] = $anrUuid;
                $data['day'] = $this->currentDateParams['day'];
                $data['week'] = $this->currentDateParams['week'];
                $data['month'] = $this->currentDateParams['month'];
                $data['quarter'] = $this->currentDateParams['quarter'];
                $data['year'] = $this->currentDateParams['year'];
                $expectedStats[] = $data;
            }
        }

        return json_encode($expectedStats);
    }

    private function getCurrentDateParams(): array
    {
        $dateTime = new DateTime();

        return [
            'day' => (int)$dateTime->format('z') + 1,
            'week' => (int)$dateTime->format('W'),
            'month' => (int)$dateTime->format('m'),
            'quarter' => (int)ceil($dateTime->format('m') / 3),
            'year' => (int)$dateTime->format('Y'),
        ];
    }
}
