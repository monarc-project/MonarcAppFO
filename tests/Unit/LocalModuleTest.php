<?php declare(strict_types=1);
/**
 * @link      https://github.com/monarc-project for the canonical source repository
 * @copyright Copyright (c) 2016-2026 Luxembourg House of Cybersecurity LHC.lu - Licensed under GNU Affero GPL v3
 * @license   MONARC is licensed under GNU Affero General Public License version 3
 */

namespace MonarcAppFo\Tests\Unit;

use Monarc\FrontOffice\Controller\ApiGuidesController;
use Monarc\Core\Entity\Asset;
use PHPUnit\Framework\TestCase;
use ReflectionClass;

/**
 * @coversNothing
 */
class LocalModuleTest extends TestCase
{
    public function testInstalledModulesExecuteSiblingSources(): void
    {
        $workspace = dirname(__DIR__, 3);
        foreach ([Asset::class => 'zm-core', ApiGuidesController::class => 'zm-client'] as $class => $repo) {
            $file = (new ReflectionClass($class))->getFileName();
            self::assertStringStartsWith(realpath($workspace . '/' . $repo) . '/', realpath($file));
        }
    }
}
