<?php declare(strict_types=1);

namespace MonarcAppFo\Tests\Unit\Scenario\Validator;

use Monarc\Core\Service\ConnectedUserService;
use Monarc\Core\Validator\InputValidator\InputValidationTranslator;
use Monarc\FrontOffice\Scenario\Validator\ScenarioRiskScenarioValidator;
use PHPUnit\Framework\TestCase;

/** @covers \Monarc\FrontOffice\Scenario\Validator\ScenarioRiskScenarioValidator */
final class ScenarioRiskScenarioValidatorTest extends TestCase
{
    public function testAcceptsAndTrimsAnIncompleteDraftStory(): void
    {
        $validator = $this->validator();

        self::assertTrue($validator->isValid([
            'title' => '  Supplier service disruption  ',
            'sourceSnapshotUuid' => 'd1b5f1d9-4e2a-4ac2-8b36-17a5fbcf1e34',
            'sourceInstanceRecordUuid' => '7d7bafc6-4ba0-47c0-9f98-b0c20b8ca03e',
            'description' => '  SRA-19 unit test  ',
        ]));
        self::assertSame([
            'title' => 'Supplier service disruption',
            'sourceSnapshotUuid' => 'd1b5f1d9-4e2a-4ac2-8b36-17a5fbcf1e34',
            'sourceInstanceRecordUuid' => '7d7bafc6-4ba0-47c0-9f98-b0c20b8ca03e',
            'description' => 'SRA-19 unit test',
        ], $validator->getValidData());
    }

    public function testRejectsAnEmptyStoryTitle(): void
    {
        $validator = $this->validator();

        self::assertFalse($validator->isValid(['title' => '   ']));
        self::assertArrayHasKey('title', $validator->getErrorMessages());
    }

    public function testRejectsAStoryTitleLongerThanTheStorageContract(): void
    {
        $validator = $this->validator();

        self::assertFalse($validator->isValid(['title' => str_repeat('x', 256)]));
        self::assertArrayHasKey('title', $validator->getErrorMessages());
    }

    private function validator(): ScenarioRiskScenarioValidator
    {
        $connectedUserService = $this->createMock(ConnectedUserService::class);
        $connectedUserService->method('getConnectedUser')->willReturn(null);

        return new ScenarioRiskScenarioValidator(
            [],
            new InputValidationTranslator($connectedUserService, [])
        );
    }
}
