<?php declare(strict_types=1);

namespace MonarcAppFo\Tests\Unit\Scenario\Validator;

use Monarc\Core\Service\ConnectedUserService;
use Monarc\Core\Validator\InputValidator\InputValidationTranslator;
use Monarc\FrontOffice\Scenario\Validator\ScenarioTemplateOverrideValidator;
use PHPUnit\Framework\TestCase;

/** @covers \Monarc\FrontOffice\Scenario\Validator\ScenarioTemplateOverrideValidator */
final class ScenarioTemplateOverrideValidatorTest extends TestCase
{
    public function testAcceptsAnAllowedCopyOnWriteFieldAndStructuredValue(): void
    {
        $validator = $this->validator();

        self::assertTrue($validator->isValid([
            'snapshotUuid' => '11111111-1111-1111-1111-111111111111',
            'fieldName' => 'linkedSubjects',
            'value' => ['subject-1', 'subject-2'],
        ]));
        self::assertSame([
            'snapshotUuid' => '11111111-1111-1111-1111-111111111111',
            'fieldName' => 'linkedSubjects',
            'value' => ['subject-1', 'subject-2'],
        ], $validator->getValidData());
    }

    public function testRejectsFieldsOutsideTheLocalTailoringContract(): void
    {
        $validator = $this->validator();

        self::assertFalse($validator->isValid([
            'snapshotUuid' => '11111111-1111-1111-1111-111111111111',
            'fieldName' => 'catalogTemplateVersion',
            'value' => 2,
        ]));
        self::assertArrayHasKey('fieldName', $validator->getErrorMessages());
    }

    private function validator(): ScenarioTemplateOverrideValidator
    {
        $connectedUserService = $this->createMock(ConnectedUserService::class);
        $connectedUserService->method('getConnectedUser')->willReturn(null);

        return new ScenarioTemplateOverrideValidator(
            [],
            new InputValidationTranslator($connectedUserService, [])
        );
    }
}
