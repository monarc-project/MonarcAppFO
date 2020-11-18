<?php declare(strict_types=1);

namespace MonarcAppFo\Tests\Integration;

use Laminas\ServiceManager\ServiceManager;
use Laminas\Test\PHPUnit\Controller\AbstractHttpControllerTestCase;

abstract class AbstractIntegrationTestCase extends AbstractHttpControllerTestCase
{
    /** @var string */
    protected $testPath;

    protected function setUp(): void
    {
        $this->testPath = getenv('TESTS_DIR');

        $this->setApplicationConfig(require dirname($this->testPath) . '/config/application.config.php');

        parent::setUp();

        $this->configureServiceManager($this->getApplicationServiceLocator());
    }

    public static function setUpBeforeClass(): void
    {
        // Creates the DB with initial data, executes all the migrations.
        shell_exec(getenv('TESTS_DIR') . '/scripts/setup_db.sh');
    }

    public static function tearDownAfterClass(): void
    {
        shell_exec(getenv('TESTS_DIR') . '/scripts/clean_client_database.sh');
    }

    protected static function createMyPrintTestData(): void
    {
        shell_exec(getenv('TESTS_DIR') . '/scripts/insert_my_print_anrs.sh');
    }

    protected function configureServiceManager(ServiceManager $serviceManager)
    {
    }
}
