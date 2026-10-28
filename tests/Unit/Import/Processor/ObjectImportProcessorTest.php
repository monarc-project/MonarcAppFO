<?php declare(strict_types=1);

namespace MonarcAppFo\Tests\Unit\Import\Processor;

use Monarc\FrontOffice\Import\Processor\ObjectImportProcessor;
use Monarc\FrontOffice\Import\Helper\ImportCacheHelper;
use MonarcAppFo\Tests\Unit\AbstractUnitTestCase;
use ReflectionClass;

class ObjectImportProcessorTest extends AbstractUnitTestCase
{
    private ObjectImportProcessor $objectImportProcessor;

    public static function setUpBeforeClass(): void
    {
        require_once dirname(__DIR__, 5) . '/zm-client/src/Import/Processor/ObjectImportProcessor.php';
    }

    protected function setUp(): void
    {
        parent::setUp();

        $reflection = new ReflectionClass(ObjectImportProcessor::class);
        $this->objectImportProcessor = $reflection->newInstanceWithoutConstructor();
        $this->setImportCacheHelper(new ImportCacheHelper());
    }

    public function testItKeepsTheNameWhenItExistsOnlyInAnotherCategory(): void
    {
        $cacheHelper = new ImportCacheHelper();
        $cacheHelper->addItemToArrayCache('objects_names_by_category', 'Shared asset', '1:Shared asset');
        $this->setImportCacheHelper($cacheHelper);

        static::assertSame(
            'Shared asset',
            $this->invokePrepareUniqueObjectName('Shared asset', 2)
        );
    }

    public function testItAddsImportSuffixWhenTheNameAlreadyExistsInTheSameCategory(): void
    {
        $cacheHelper = new ImportCacheHelper();
        $cacheHelper->addItemToArrayCache('objects_names_by_category', 'Shared asset', '2:Shared asset');
        $this->setImportCacheHelper($cacheHelper);

        static::assertSame(
            'Shared asset - Imp. #1',
            $this->invokePrepareUniqueObjectName('Shared asset', 2)
        );
    }

    private function setImportCacheHelper(ImportCacheHelper $cacheHelper): void
    {
        $reflection = new ReflectionClass($this->objectImportProcessor);
        $property = $reflection->getProperty('importCacheHelper');
        $property->setValue($this->objectImportProcessor, $cacheHelper);
    }

    private function invokePrepareUniqueObjectName(string $objectName, int $categoryId): string
    {
        $reflection = new ReflectionClass($this->objectImportProcessor);
        $method = $reflection->getMethod('prepareUniqueObjectName');
        return $method->invoke($this->objectImportProcessor, $objectName, $categoryId);
    }
}
