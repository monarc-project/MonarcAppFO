<?php declare(strict_types=1);

namespace MonarcAppFo\Tests\Unit\Scenario\Service;

use Monarc\FrontOffice\Scenario\Service\ScenarioRiskGraph;
use PHPUnit\Framework\TestCase;

/** @covers \Monarc\FrontOffice\Scenario\Service\ScenarioRiskGraph */
final class ScenarioRiskGraphTest extends TestCase
{
    public function testAllowsAnAcyclicBranch(): void
    {
        $children = [1 => [2, 3], 2 => [4], 3 => [], 4 => []];

        self::assertFalse(ScenarioRiskGraph::createsCycle(
            2,
            3,
            static fn (int $node): array => $children[$node] ?? []
        ));
    }

    public function testRejectsABackEdgeAcrossAnExistingBranch(): void
    {
        $children = [1 => [2], 2 => [3], 3 => []];

        self::assertTrue(ScenarioRiskGraph::createsCycle(
            3,
            1,
            static fn (int $node): array => $children[$node] ?? []
        ));
    }

    public function testRejectsASelfEdge(): void
    {
        self::assertTrue(ScenarioRiskGraph::createsCycle(7, 7, static fn (int $node): array => []));
    }
}
