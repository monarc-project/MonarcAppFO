<?php

namespace MonarcAppFo\Tests\Integration\Service;

use GuzzleHttp\Handler\MockHandler;
use GuzzleHttp\Psr7\Response;
use Laminas\ServiceManager\ServiceManager;
use Monarc\Core\Service\AuthenticationService;
use Monarc\Core\Service\ConnectedUserService;
use Monarc\FrontOffice\Model\Table\SettingTable;
use Monarc\FrontOffice\Provider\StatsApiProvider;
use Monarc\FrontOffice\Service\Exception\StatsAlreadyCollectedException;
use Monarc\FrontOffice\Service\StatsAnrService;
use MonarcAppFo\Tests\Integration\AbstractIntegrationTestCase;

class StatsApiServiceTest extends AbstractIntegrationTestCase
{
    /** @var MockHandler */
    private $mockHandler;

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
        $statsAnrService->collectStats();

        $this->assertEquals('GET', $this->mockHandler->getLastRequest()->getMethod());
    }

    public function testItCanGenerateTheStatsWhenItIsNotDoneForToday()
    {
        $this->mockHandler->append(new Response(200, [], $this->getStatsResponse()));
        $this->mockHandler->append(new Response(200, [], '{"status": "ok"}'));

        // TODO: import MyPrint to test if the exact Json is generated and compare with the last request history.
        /** @var StatsAnrService $statsAnrService */
        $statsAnrService = $this->getApplicationServiceLocator()->get(StatsAnrService::class);
        $statsAnrService->collectStats();
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
}
