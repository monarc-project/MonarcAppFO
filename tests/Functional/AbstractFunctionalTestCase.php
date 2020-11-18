<?php declare(strict_types=1);

namespace MonarcAppFo\Tests\Functional;

use Laminas\ServiceManager\ServiceManager;
use Laminas\Test\PHPUnit\Controller\AbstractHttpControllerTestCase;

abstract class AbstractFunctionalTestCase extends AbstractHttpControllerTestCase
{
    protected function setUp(): void
    {
        $this->setApplicationConfig(require dirname(__DIR__) . '/../config/application.config.php');

        parent::setUp();

        $this->configureServiceManager($this->getApplicationServiceLocator());
    }

    protected function tearDown(): void
    {
    }

    public static function setUpBeforeClass(): void
    {
        shell_exec(getenv('TESTS_DIR') . '/scripts/setup_db.sh');
    }

    public static function tearDownAfterClass(): void
    {
    }

    protected function configureServiceManager(ServiceManager $serviceManager)
    {
    }
}
