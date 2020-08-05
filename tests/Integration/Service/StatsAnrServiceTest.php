<?php

namespace MonarcAppFo\Tests\Integration\Service;

use DateTime;
use DateTimeImmutable;
use Doctrine\Common\Collections\ArrayCollection;
use GuzzleHttp\Handler\MockHandler;
use GuzzleHttp\Psr7\Response;
use Laminas\ServiceManager\ServiceManager;
use LogicException;
use Monarc\Core\Service\ConnectedUserService;
use Monarc\FrontOffice\Model\Entity\Anr;
use Monarc\FrontOffice\Model\Entity\UserAnr;
use Monarc\FrontOffice\Model\Entity\UserRole;
use Monarc\FrontOffice\Exception\AccessForbiddenException;
use Monarc\FrontOffice\Exception\UserNotAuthorizedException;
use Monarc\FrontOffice\Model\Entity\User;
use Monarc\FrontOffice\Model\Table\AnrTable;
use Monarc\FrontOffice\Model\Table\SettingTable;
use Monarc\FrontOffice\Stats\DataObject\StatsDataObject;
use Monarc\FrontOffice\Stats\Exception\StatsAlreadyCollectedException;
use Monarc\FrontOffice\Stats\Provider\StatsApiProvider;
use Monarc\FrontOffice\Stats\Service\StatsAnrService;
use MonarcAppFo\Tests\Integration\AbstractIntegrationTestCase;
use PHPUnit\Framework\MockObject\MockObject;

class StatsAnrServiceTest extends AbstractIntegrationTestCase
{
    /** @var MockHandler */
    private $statsApiMockHandler;

    /** @var string */
    private $currentDate;

    /** @var StatsAnrService */
    private $statsAnrService;

    /** @var ConnectedUserService|MockObject */
    private $connectedUserService;

    public static function setUpBeforeClass(): void
    {
        parent::setUpBeforeClass();

        static::createMyPrintTestData();
    }

    public function setUp(): void
    {
        parent::setUp();

        $this->currentDate = (new DateTime())->format('Y-m-d');
        $this->statsAnrService = $this->getApplicationServiceLocator()->get(StatsAnrService::class);
    }

    protected function configureServiceManager(ServiceManager $serviceManager)
    {
        $serviceManager->setAllowOverride(true);

        $this->statsApiMockHandler = new MockHandler();
        $statsApiProvider = new StatsApiProvider(
            $serviceManager->get(SettingTable::class),
            [],
            $this->statsApiMockHandler
        );
        $serviceManager->setService(StatsApiProvider::class, $statsApiProvider);

        $this->connectedUserService = $this->createMock(ConnectedUserService::class);
        $serviceManager->setService(ConnectedUserService::class, $this->connectedUserService);

        $serviceManager->setAllowOverride(false);
    }

    public function testItThrowsTheErrorWhenTheTheStatsAlreadyGeneratedForToday()
    {
        $this->expectException(StatsAlreadyCollectedException::class);
        $this->expectExceptionMessage('The stats is already collected for today.');

        $this->statsApiMockHandler->append(new Response(200, [], $this->getStatsResponse([
            new StatsDataObject([
                'type' => StatsDataObject::TYPE_RISK,
                'anr' => '1232-31abcd-213efgh-123klmp',
                'data' => [
                    'total' => [
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
            ])
        ])));

        $this->statsAnrService->collectStats();
    }

    public function testItDoesNotSendTheStatsWhenTheDataIsEmpty()
    {
        $this->statsApiMockHandler->append(new Response(200, [], $this->getStatsResponse()));

        $this->statsAnrService->collectStats([99, 78]);

        $this->assertEquals('GET', $this->statsApiMockHandler->getLastRequest()->getMethod());
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

        $this->statsApiMockHandler->append(new Response(200, [], $this->getStatsResponse()));
        $this->statsApiMockHandler->append(new Response(201, [], '{"status": "ok"}'));

        $this->statsAnrService->collectStats();

        $this->assertJsonStringEqualsJsonString(
            $this->getExpectedStatsDataJson($anrUuids),
            $this->statsApiMockHandler->getLastRequest()->getBody()->getContents()
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

        $this->statsApiMockHandler->append(new Response(200, [], $this->getStatsResponse()));
        $this->statsApiMockHandler->append(new Response(201, [], '{"status": "ok"}'));

        $this->statsAnrService->collectStats($anrIdsToGenerateTheStats);

        $this->assertJsonStringEqualsJsonString(
            $this->getExpectedStatsDataJson($anrUuids),
            $this->statsApiMockHandler->getLastRequest()->getBody()->getContents()
        );
    }

    public function testItThrowsTheExceptionIfUserIsNotLoggedIn()
    {
        $this->expectException(UserNotAuthorizedException::class);
        $this->expectExceptionMessage('User not authorized.');

        $this->statsAnrService->getStats([]);
    }

    public function testItThrowsTheExceptionIfUserDoesNotHaveTheRightsToGetTheStats()
    {
        $this->expectException(AccessForbiddenException::class);
        $this->expectExceptionMessage('User does not have an access to the action.');

        $user = $this->createMock(User::class);
        $user->expects($this->once())->method('hasRole')->with(UserRole::USER_ROLE_CEO)->willReturn(false);
        $user->method('getUserAnrs')->willReturn(new ArrayCollection());

        $this->connectedUserService
            ->expects($this->once())
            ->method('getConnectedUser')
            ->willReturn($user);

        $this->statsAnrService->getStats(['type' => StatsDataObject::TYPE_CARTOGRAPHY]);
    }

    public function testItThrowsLogicExceptionIfTypeIsNotPassed()
    {
        $this->expectException(LogicException::class);
        $this->expectExceptionMessage('Filter parameter \'type\' is mandatory to get the stats.');

        $user = $this->createMock(User::class);
        $this->connectedUserService
            ->expects($this->once())
            ->method('getConnectedUser')
            ->willReturn($user);

        $this->statsAnrService->getStats([]);
    }

    public function testItAddsToTheFilterAllowedForTheUserAnrUuids()
    {
        $user = $this->createMock(User::class);
        $user->expects($this->exactly(2))->method('hasRole')->with(UserRole::USER_ROLE_CEO)->willReturn(false);
        /** @var Anr $anr1 */
        $anr1 = (new Anr())->setId(1);
        /** @var Anr $anr2 */
        $anr2 = (new Anr())->setId(2);
        /** @var Anr $anr3 */
        $anr3 = (new Anr())->setId(3);
        $user->method('getUserAnrs')->willReturn(new ArrayCollection([
            (new UserAnr())->setAnr($anr1->generateAndSetUuid()),
            (new UserAnr())->setAnr($anr2->generateAndSetUuid()),
            (new UserAnr())->setAnr($anr3->generateAndSetUuid()),
        ]));
        $this->connectedUserService->expects($this->exactly(2))->method('getConnectedUser')->willReturn($user);
        $this->statsApiMockHandler->append(new Response(200, [], $this->getStatsResponse()));

        $stats = $this->statsAnrService->getStats(['type' => StatsDataObject::TYPE_COMPLIANCE]);

        $this->assertEmpty($stats);

        $defaultDates = [
            'date_from' => (new DateTime())->modify('-' . StatsAnrService::DEFAULT_STATS_DATES_RANGE)->format('Y-m-d'),
            'date_to' => (new DateTime())->format('Y-m-d'),
        ];
        $queryParams = [];
        parse_str($this->statsApiMockHandler->getLastRequest()->getUri()->getQuery(), $queryParams);
        $this->assertEquals(
            array_merge([
                'anrs' => [$anr1->getUuid(), $anr2->getUuid(), $anr3->getUuid()],
                'type' => StatsDataObject::TYPE_COMPLIANCE,
                'get_last' => 0,
            ], $defaultDates),
            $queryParams
        );

        $statsResponse = $this->getStatsResponse([
            new StatsDataObject([
                'type' => StatsDataObject::TYPE_RISK,
                'anr' => '1232-31abcd-213efgh-123klmp',
                'data' => [
                    'risks' => [],
                    'total' => [],
                ],
            ])
        ]);
        $this->statsApiMockHandler->append(new Response(200, [], $statsResponse));

        $stats = $this->statsAnrService->getStats(['type' => StatsDataObject::TYPE_RISK, 'anrs' => [1, 3, 7]]);

        $this->assertEquals($this->getStatsResponse($stats), $this->getStatsResponse());

        parse_str($this->statsApiMockHandler->getLastRequest()->getUri()->getQuery(), $queryParams);
        $this->assertEquals(
            array_merge([
                'anrs' => [$anr1->getUuid(), $anr3->getUuid()],
                'type' => StatsDataObject::TYPE_RISK,
                'get_last' => 0,
            ], $defaultDates),
            $queryParams
        );
    }

    public function testItAllowsToFilterBySpecificAnrsForCeoRoleOrGetItWithoutLimitations()
    {
        $user = $this->createMock(User::class);
        $user->expects($this->exactly(2))->method('hasRole')->with(UserRole::USER_ROLE_CEO)->willReturn(true);
        $user->expects($this->never())->method('getUserAnrs');
        $this->connectedUserService->expects($this->exactly(2))->method('getConnectedUser')->willReturn($user);

        /** @var AnrTable $anrTable */
        $anrTable = $this->getApplicationServiceLocator()->get(AnrTable::class);
        $anrUuids = [];
        foreach ($anrTable->findByIds([1, 2, 3]) as $anr) {
            $anrUuids[] = $anr->getUuid();
        }

        $defaultDates = [
            'date_from' => (new DateTime())->modify('-' . StatsAnrService::DEFAULT_STATS_DATES_RANGE)->format('Y-m-d'),
            'date_to' => (new DateTime())->format('Y-m-d'),
        ];

        $this->statsApiMockHandler->append(new Response(200, [], $this->getStatsResponse()));
        $this->statsApiMockHandler->append(new Response(200, [], $this->getStatsResponse()));

        $this->statsAnrService->getStats([
            'type' => StatsDataObject::TYPE_RISK,
            'anrs' => [1, 2, 3, 99] // anr ID = 99 is not in thew db.
        ]);

        parse_str($this->statsApiMockHandler->getLastRequest()->getUri()->getQuery(), $queryParams);
        $this->assertEquals(array_merge([
            'anrs' => $anrUuids,
            'type' => StatsDataObject::TYPE_RISK,
            'get_last' => 0,
        ], $defaultDates), $queryParams);

        $this->statsAnrService->getStats(['type' => StatsDataObject::TYPE_VULNERABILITY]);

        parse_str($this->statsApiMockHandler->getLastRequest()->getUri()->getQuery(), $queryParams);
        $this->assertEquals(
            array_merge(['type' => StatsDataObject::TYPE_VULNERABILITY], $defaultDates + ['get_last' => 0]),
            $queryParams
        );
    }

    public function testItCanSendDifferentParamsToGetTheStats()
    {
        $user = $this->createMock(User::class);
        $user->expects($this->exactly(3))->method('hasRole')->with(UserRole::USER_ROLE_CEO)->willReturn(true);
        $user->expects($this->never())->method('getUserAnrs');
        $this->connectedUserService->expects($this->exactly(3))->method('getConnectedUser')->willReturn($user);

        /** @var AnrTable $anrTable */
        $anrTable = $this->getApplicationServiceLocator()->get(AnrTable::class);
        $anrUuids = [];
        foreach ($anrTable->findByIds([1, 2, 3, 4]) as $anr) {
            $anrUuids[] = $anr->getUuid();
        }

        $datesRange = [
            'dateFrom' => (new DateTime())->modify('-1 year')->format('Y-m-d'),
            'dateTo' => (new DateTime())->format('Y-m-d'),
        ];

        $this->statsApiMockHandler->append(new Response(200, [], $this->getStatsResponse()));
        $this->statsApiMockHandler->append(new Response(200, [], $this->getStatsResponse()));
        $this->statsApiMockHandler->append(new Response(200, [], $this->getStatsResponse()));

        $this->statsAnrService->getStats(array_merge([
            'anrs' => [1, 2, 3, 4],
            'aggregationPeriod' => 'month',
            'type' => StatsDataObject::TYPE_COMPLIANCE
        ], $datesRange));

        parse_str($this->statsApiMockHandler->getLastRequest()->getUri()->getQuery(), $queryParams);
        $this->assertEquals(array_merge([
            'anrs' => $anrUuids,
            'aggregation_period' => 'month',
            'type' => StatsDataObject::TYPE_COMPLIANCE,
            'get_last' => 0,
        ], [
            'date_from' => $datesRange['dateFrom'],
            'date_to' => $datesRange['dateTo'],
        ]), $queryParams);

        $this->statsAnrService->getStats(array_merge([
            'aggregationPeriod' => 'week',
            'type' => StatsDataObject::TYPE_VULNERABILITY
        ], $datesRange));

        parse_str($this->statsApiMockHandler->getLastRequest()->getUri()->getQuery(), $queryParams);
        $this->assertEquals(array_merge([
            'aggregation_period' => 'week',
            'get_last' => 0,
            'type' => StatsDataObject::TYPE_VULNERABILITY
        ], [
            'date_from' => $datesRange['dateFrom'],
            'date_to' => $datesRange['dateTo'],
        ]), $queryParams);

        $this->statsAnrService->getStats(array_merge([
            'getLast' => true,
            'type' => StatsDataObject::TYPE_CARTOGRAPHY,
        ], $datesRange));

        parse_str($this->statsApiMockHandler->getLastRequest()->getUri()->getQuery(), $queryParams);
        $this->assertEquals(array_merge([
            'get_last' => 1,
            'type' => StatsDataObject::TYPE_CARTOGRAPHY
        ]), $queryParams);
    }

    public function testItFetchesStatsForDefaultPeriodIfFromAndToDatesAreNotPassed()
    {
        $user = $this->createMock(User::class);
        $user->expects($this->exactly(3))->method('hasRole')->with(UserRole::USER_ROLE_CEO)->willReturn(true);
        $user->expects($this->never())->method('getUserAnrs');
        $this->connectedUserService->expects($this->exactly(3))->method('getConnectedUser')->willReturn($user);

        $defaultDates = [
            'dateFrom' => (new DateTime())->modify('-' . StatsAnrService::DEFAULT_STATS_DATES_RANGE)->format('Y-m-d'),
            'dateTo' => (new DateTime())->format('Y-m-d'),
        ];

        $this->statsApiMockHandler->append(new Response(200, [], $this->getStatsResponse()));
        $this->statsApiMockHandler->append(new Response(200, [], $this->getStatsResponse()));
        $this->statsApiMockHandler->append(new Response(200, [], $this->getStatsResponse()));

        $this->statsAnrService->getStats(['type' => StatsDataObject::TYPE_THREAT]);

        parse_str($this->statsApiMockHandler->getLastRequest()->getUri()->getQuery(), $queryParams);
        $this->assertEquals([
            'date_from' => $defaultDates['dateFrom'],
            'date_to' => $defaultDates['dateTo'],
            'type' => StatsDataObject::TYPE_THREAT,
            'get_last' => 0,
        ], $queryParams);

        $this->statsAnrService->getStats([
            'type' => StatsDataObject::TYPE_THREAT,
            'dateFrom' => (new DateTime())->modify('-6 months')->format('Y-m-d')
        ]);

        parse_str($this->statsApiMockHandler->getLastRequest()->getUri()->getQuery(), $queryParams);
        $this->assertEquals([
            'date_from' => (new DateTime())->modify('-6 months')->format('Y-m-d'),
            'date_to' => $defaultDates['dateTo'],
            'type' => StatsDataObject::TYPE_THREAT,
            'get_last' => 0,
        ], $queryParams);

        $dateTo = (new DateTimeImmutable())->modify('-6 months');
        $this->statsAnrService->getStats(['type' => StatsDataObject::TYPE_THREAT, 'dateTo' => $dateTo->format('Y-m-d')]);

        parse_str($this->statsApiMockHandler->getLastRequest()->getUri()->getQuery(), $queryParams);
        $this->assertEquals([
            'type' => StatsDataObject::TYPE_THREAT,
            'date_from' => $dateTo->modify('-' . StatsAnrService::DEFAULT_STATS_DATES_RANGE)->format('Y-m-d'),
            'date_to' => $dateTo->format('Y-m-d'),
            'get_last' => 0,
        ], $queryParams);
    }

    private function getStatsResponse(array $results = []): string
    {
        return json_encode([
            'metadata' => [
                'count' => \count($results),
                'offset' => 0,
                'limit' => 0,
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
                $data['date'] = $this->currentDate;
                $expectedStats[] = $data;
            }
        }

        return json_encode($expectedStats);
    }
}
