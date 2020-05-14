<?php declare(strict_types=1);

namespace MonarcAppFo\Tests\Integration;

use Laminas\ServiceManager\ServiceManager;
use Laminas\Test\PHPUnit\Controller\AbstractHttpControllerTestCase;

abstract class AbstractIntegrationTestCase extends AbstractHttpControllerTestCase
{
    protected function setUp(): void
    {
        $this->setApplicationConfig(require dirname(__DIR__) . '/../config/application.config.php');

        parent::setUp();

        $this->configureServiceManager($this->getApplicationServiceLocator());
    }

    protected function tearDown(): void
    {
        // TODO: clear the db data.
    }

    public static function setUpBeforeClass(): void
    {
        // Creates the DB with initial data, executes all the migrations.
        shell_exec(getenv('TESTS_DIR') . '/scripts/setup_db.sh');
    }

    public static function tearDownAfterClass(): void
    {
        // TODO: drop the database or clear the phinxlog table and all the data.
    }

    protected function configureServiceManager(ServiceManager $serviceManager)
    {
    }
}
