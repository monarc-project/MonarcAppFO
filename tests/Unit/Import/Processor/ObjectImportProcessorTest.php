<?php declare(strict_types=1);

namespace MonarcAppFo\Tests\Unit\Import\Processor;

use Monarc\FrontOffice\Import\Processor\ObjectImportProcessor;
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
    }

    public function testItFallsBackToAnotherLocalizedNameWhenCurrentLanguageNameIsMissing(): void
    {
        static::assertSame(
            'Legacy child',
            $this->invokeResolveImportedObjectName([
                'name2' => null,
                'name1' => 'Legacy child',
                'label2' => 'Displayed label',
                'uuid' => 'object-uuid',
            ], 'name2', 'label2')
        );
    }

    public function testItFallsBackToLabelWhenNoLocalizedNameExists(): void
    {
        static::assertSame(
            'Only label available',
            $this->invokeResolveImportedObjectName([
                'name2' => null,
                'label2' => 'Only label available',
                'uuid' => 'object-uuid',
            ], 'name2', 'label2')
        );
    }

    public function testItFallsBackToUuidWhenNamesAndLabelsAreMissing(): void
    {
        static::assertSame(
            'object-uuid',
            $this->invokeResolveImportedObjectName([
                'name2' => null,
                'label2' => null,
                'uuid' => 'object-uuid',
            ], 'name2', 'label2')
        );
    }

    private function invokeResolveImportedObjectName(array $objectData, string $nameKey, string $labelKey): string
    {
        $reflection = new ReflectionClass($this->objectImportProcessor);
        $method = $reflection->getMethod('resolveImportedObjectName');
        $method->setAccessible(true);

        return $method->invoke($this->objectImportProcessor, $objectData, $nameKey, $labelKey);
    }
}
