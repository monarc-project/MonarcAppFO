<?php declare(strict_types=1);

namespace MonarcAppFo\Tests\Unit\Stats\Validator;

use Doctrine\ORM\EntityNotFoundException;
use Laminas\InputFilter\InputFilter;
use Monarc\FrontOffice\Model\Entity\Anr;
use Monarc\FrontOffice\Model\Table\AnrTable;
use Monarc\FrontOffice\Stats\Validator\GetStatsQueryParamsValidator;
use Monarc\FrontOffice\Validator\FieldValidator\AnrExistenceValidator;
use MonarcAppFo\Tests\Unit\AbstractUnitTestCase;
use PHPUnit\Framework\MockObject\MockObject;

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
            new InputFilter(),
            $this->anrTable
        );
    }

    public function testItIsNotValidWhenDateToLowerThenDateFromOrBiggerThenCurrentDate()
    {
        static::assertFalse($this->getStatsQueryParamsValidator->isValid([
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
            'dateFrom' => '2019-12-01',
            'dateTo' => '2020-06-01',
        ]));

        static::assertEmpty($this->getStatsQueryParamsValidator->getErrorMessages());
        static::assertEquals(
            ['dateFrom' => '2019-12-01', 'dateTo' => '2020-06-01', 'anrs' => []],
            $this->getStatsQueryParamsValidator->getValidData()
        );

        static::assertTrue($this->getStatsQueryParamsValidator->isValid([
            'dateFrom' => '2019-12-01',
            'dateTo' => '2019-12-01',
        ]));

        static::assertEmpty($this->getStatsQueryParamsValidator->getErrorMessages());
        static::assertEquals(
            ['dateFrom' => '2019-12-01', 'dateTo' => '2019-12-01', 'anrs' => []],
            $this->getStatsQueryParamsValidator->getValidData()
        );
    }

    public function testItThrowAnExceptionWhenSomeAnrsAreNotPresentedInTheTable()
    {
        $this->anrTable->expects($this->at(0))->method('findById')->willReturn(new Anr());
        $this->anrTable->expects($this->at(1))->method('findById')->willReturn(new Anr());
        $this->anrTable->expects($this->at(2))->method('findById')->willThrowException(new EntityNotFoundException());

        static::assertFalse($this->getStatsQueryParamsValidator->isValid([
            'anrs' => [1, 2, 3, 7],
        ]));

        static::assertEquals(
            [
                'anrs' => [AnrExistenceValidator::ANR_DOES_NOT_EXIST => 'Anr with the ID (3) does not exist.']
            ],
            $this->getStatsQueryParamsValidator->getErrorMessages()
        );
    }
}
