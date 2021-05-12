<?php declare(strict_types=1);

namespace MonarcAppFo\Tests\Unit\Validator\FieldValidator;

use Monarc\FrontOffice\Model\Table\AnrTable;
use Monarc\FrontOffice\Validator\FieldValidator\AnrExistenceValidator;
use MonarcAppFo\Tests\Unit\AbstractUnitTestCase;
use PHPUnit\Framework\MockObject\MockObject;

class AnrExistenceValidatorTest extends AbstractUnitTestCase
{
    /** @var AnrTable|MockObject */
    private $anrTable;

    /** @var AnrExistenceValidator */
    private $anrExistenceValidator;

    public function setUp(): void
    {
        parent::setUp();

        $this->anrTable = $this->createMock(AnrTable::class);
        $this->anrExistenceValidator = new AnrExistenceValidator([
            'anrTable' => $this->anrTable,
        ]);
    }

    public function testItCanValidateAnrsIdsListPassedAsArray()
    {
        $this->anrTable->method('findByIds');
    }

    public function testItCanValidateAnrsIdsListPassedAsArrayOfArraysAndAnrKey()
    {
        $this->anrTable->method('findByIds');
    }
}
