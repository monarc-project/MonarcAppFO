<?php declare(strict_types=1);
/**
 * @link      https://github.com/monarc-project for the canonical source repository
 * @copyright Copyright (c) 2016-2026 Luxembourg House of Cybersecurity LHC.lu - Licensed under GNU Affero GPL v3
 * @license   MONARC is licensed under GNU Affero General Public License version 3
 */

namespace MonarcAppFo\Tests\Unit\Stats\Validator;

use Doctrine\ORM\EntityNotFoundException;
use Monarc\Core\Service\ConnectedUserService;
use Monarc\Core\Validator\InputValidator\InputValidationTranslator;
use Monarc\FrontOffice\Entity\Anr;
use Monarc\FrontOffice\Table\AnrTable;
use Monarc\FrontOffice\Stats\DataObject\StatsDataObject;
use Monarc\FrontOffice\Stats\Service\StatsAnrService;
use Monarc\FrontOffice\Stats\Validator\GetStatsQueryParamsValidator;
use Monarc\FrontOffice\Validator\FieldValidator\AnrExistenceValidator;
use MonarcAppFo\Tests\Unit\AbstractUnitTestCase;
use PHPUnit\Framework\MockObject\MockObject;

/**
 * @covers \Monarc\FrontOffice\Stats\Validator\GetStatsQueryParamsValidator
 */
class GetStatsQueryParamsValidatorTest extends AbstractUnitTestCase
{
    /** @var AnrTable|MockObject */
    private $anrTable;

    /** @var GetStatsQueryParamsValidator */
    private $getStatsQueryParamsValidator;

    public function setUp(): void
    {
        parent::setUp();

        $this->anrTable = $this->createMock(AnrTable::class);
        $this->getStatsQueryParamsValidator = new GetStatsQueryParamsValidator(
            [],
            new InputValidationTranslator($this->createMock(ConnectedUserService::class), []),
            $this->anrTable
        );
    }

    public function testItIsNotValidWhenDateToLowerThenDateFromOrBiggerThenCurrentDate()
    {
        static::assertFalse($this->getStatsQueryParamsValidator->isValid([
            'type' => StatsDataObject::TYPE_RISK,
            'dateFrom' => '2020-01-01',
            'dateTo' => '2019-12-01',
        ]));

        static::assertEquals(
            [
                'dateFrom' => ['"dateFrom" should be lower or equal to "dateTo".'],
                'dateTo' => ['"dateTo" should be bigger or equal to "dateFrom".'],
            ],
            $this->getStatsQueryParamsValidator->getErrorMessages()
        );

        static::assertFalse($this->getStatsQueryParamsValidator->isValid([
            'type' => StatsDataObject::TYPE_RISK,
            'dateFrom' => '3020-01-01',
            'dateTo' => '3019-12-01',
        ]));

        static::assertEquals(
            [
                'dateFrom' => ['"dateFrom" should be lower or equal to current date.'],
                'dateTo' => ['"dateTo" should be lower or equal to current date.'],
            ],
            $this->getStatsQueryParamsValidator->getErrorMessages()
        );
    }

    public function testItIsValidWhenTheDatesAreTheSameOrDateFromIsLessThenDateTo()
    {
        static::assertTrue($this->getStatsQueryParamsValidator->isValid([
            'type' => StatsDataObject::TYPE_RISK,
            'dateFrom' => '2019-12-01',
            'dateTo' => '2020-06-01',
        ]));

        static::assertEmpty($this->getStatsQueryParamsValidator->getErrorMessages());
        static::assertEquals(
            [
                'dateFrom' => '2019-12-01',
                'dateTo' => '2020-06-01',
                'anrs' => [],
                'type' => StatsDataObject::TYPE_RISK,
                'aggregationPeriod' => null,
                'offset' => null,
                'limit' => null,
                'getLast' => null,
            ],
            $this->getStatsQueryParamsValidator->getValidData()
        );

        static::assertTrue($this->getStatsQueryParamsValidator->isValid([
            'type' => StatsDataObject::TYPE_RISK,
            'dateFrom' => '2019-12-01',
            'dateTo' => '2019-12-01',
        ]));

        static::assertEmpty($this->getStatsQueryParamsValidator->getErrorMessages());
        static::assertEquals(
            [
                'dateFrom' => '2019-12-01',
                'dateTo' => '2019-12-01',
                'anrs' => [],
                'type' => StatsDataObject::TYPE_RISK,
                'aggregationPeriod' => null,
                'offset' => null,
                'limit' => null,
                'getLast' => null,
            ],
            $this->getStatsQueryParamsValidator->getValidData(1)
        );
    }

    public function testItThrowAnExceptionWhenSomeAnrsAreNotPresentedInTheTable()
    {
        $this->anrTable->expects($this->exactly(3))->method('findById')
            ->willReturnCallback(static function (int $id): Anr {
                if ($id === 3) {
                    throw new EntityNotFoundException();
                }

                return new Anr();
            });

        static::assertFalse($this->getStatsQueryParamsValidator->isValid([
            'type' => StatsDataObject::TYPE_RISK,
            'anrs' => [['id' => 1], ['id' => 2], ['id' => 3], ['id' => 7]],
        ]));

        $errors = $this->getStatsQueryParamsValidator->getErrorMessages();
        static::assertSame(['anrs'], array_keys($errors));
        static::assertArrayHasKey(AnrExistenceValidator::ANR_DOES_NOT_EXIST, $errors['anrs']);
        // The current field validator includes the supplied ANR object in its message.
        static::assertStringContainsString("'id' => 3", $errors['anrs'][AnrExistenceValidator::ANR_DOES_NOT_EXIST]);
    }

    public function testItIsNotValidWhenTypeIsNotPassedOrWrong()
    {
        static::assertFalse($this->getStatsQueryParamsValidator->isValid([]));
        static::assertEquals(
            [
                'type' => ['isEmpty' => 'Value is required and can\'t be empty']
            ],
            $this->getStatsQueryParamsValidator->getErrorMessages()
        );

        static::assertFalse($this->getStatsQueryParamsValidator->isValid([
            'type' => 'not-existed-type'
        ]));
        static::assertEquals(
            [
                'type' => [
                    'notInArray' => 'Should be one of the values: '
                        . implode(', ', StatsDataObject::getAvailableTypes())
                ]
            ],
            $this->getStatsQueryParamsValidator->getErrorMessages()
        );
    }

    public function testItIsNotValidOnlyWhenPassedWrongAggregationPeriod()
    {
        static::assertFalse($this->getStatsQueryParamsValidator->isValid([
            'type' => StatsDataObject::TYPE_RISK,
            'aggregationPeriod' => 'not-existed-period'
        ]));
        static::assertEquals(
            [
                'aggregationPeriod' => [
                    'notInArray' => 'Should be one of the values: '
                        . implode(', ', StatsAnrService::AVAILABLE_AGGREGATION_FIELDS)
                ]
            ],
            $this->getStatsQueryParamsValidator->getErrorMessages()
        );

        static::assertTrue($this->getStatsQueryParamsValidator->isValid([
            'type' => StatsDataObject::TYPE_RISK,
        ]));
        static::assertTrue($this->getStatsQueryParamsValidator->isValid([
            'type' => StatsDataObject::TYPE_RISK,
            'aggregationPeriod' => 'week',
        ]));
    }

    public function testGetLastRemainsAbsentOrIsConvertedToBooleanWhenPassed()
    {
        static::assertTrue($this->getStatsQueryParamsValidator->isValid([
            'type' => StatsDataObject::TYPE_RISK,
        ]));
        static::assertEquals(
            [
                'type' => StatsDataObject::TYPE_RISK,
                'getLast' => null,
                'anrs' => [],
                'dateFrom' => null,
                'dateTo' => null,
                'aggregationPeriod' => null,
                'offset' => null,
                'limit' => null,
            ],
            $this->getStatsQueryParamsValidator->getValidData()
        );

        static::assertTrue($this->getStatsQueryParamsValidator->isValid([
            'type' => StatsDataObject::TYPE_RISK,
            'getLast' => true,
        ]));
        static::assertEquals(
            [
                'type' => StatsDataObject::TYPE_RISK,
                'getLast' => true,
                'anrs' => [],
                'dateFrom' => null,
                'dateTo' => null,
                'aggregationPeriod' => null,
                'offset' => null,
                'limit' => null,
            ],
            $this->getStatsQueryParamsValidator->getValidData(1)
        );

        static::assertTrue($this->getStatsQueryParamsValidator->isValid([
            'type' => StatsDataObject::TYPE_RISK,
            'getLast' => 'the value is converted to boolean.',
        ]));
        static::assertEquals(
            [
                'type' => StatsDataObject::TYPE_RISK,
                'getLast' => true,
                'anrs' => [],
                'dateFrom' => null,
                'dateTo' => null,
                'aggregationPeriod' => null,
                'offset' => null,
                'limit' => null,
            ],
            $this->getStatsQueryParamsValidator->getValidData(2)
        );
    }
}
