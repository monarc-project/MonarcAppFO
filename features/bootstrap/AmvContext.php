<?php

use Behat\Behat\Context\ClosuredContextInterface,
    Behat\Behat\Context\TranslatedContextInterface,
    Behat\Behat\Context\BehatContext,
    Behat\Behat\Exception\PendingException;

/**
 * Features context.
 */
class AmvContext  extends \Behat\MinkExtension\Context\MinkContext implements \Behat\Behat\Context\SnippetAcceptingContext
{

    protected $service;

    /**
     * @var Zend\Mvc\Application
     */
    protected static $zendApp;


    /**
     * @BeforeSuite
     */
    public static function initializeZendFramework() {
        if(self::$zendApp === null) {
            $path = __DIR__ . '/../../config/application.config.php';
            self::$zendApp = Zend\Mvc\Application::init(require $path);
        }
    }

    /**
     * Initializes context.
     *
     * Every scenario gets its own context instance.
     * You can also pass arbitrary arguments to the
     * context constructor through behat.yml.
     */
    public function __construct()
    {

    }

    /**
     * @Given /^That I want to call the amv service$/
     */
    public function thatIWantToCallTheAmvService()
    {
        $this->service = new \MonarcCore\Service\AmvService();
    }


    /**
     * @Given I should test complies with Amode :arg1 and Tmode :arg2 and Vmode :arg3 and Amodel :arg4 and Tmodel :arg5 and Vmodel :arg6 and IsRegulator :arg7 and the Result is true
     */
    public function iShouldTestCompliesWithAmodeAndTmodeAndVmodeAndAmodelAndTmodelAndVmodelAndIsregulatorAndTheResultIsTrue($arg1, $arg2, $arg3, $arg4, $arg5, $arg6, $arg7)
    {
        $service = $this->service;

        $result = $service->compliesControl($arg1, $arg2, $arg3, $arg4, $arg5, $arg6, $arg7);

        PHPUnit_Framework_Assert::assertTrue($result);
    }

    /**
     * @Given I should test complies with Amode :arg1 and Tmode :arg2 and Vmode :arg3 and Amodel :arg4 and Tmodel :arg5 and Vmodel :arg6 and IsRegulator :arg7 and the Result is false
     */
    public function iShouldTestCompliesWithAmodeAndTmodeAndVmodeAndAmodelAndTmodelAndVmodelAndIsregulatorAndTheResultIsFalse($arg1, $arg2, $arg3, $arg4, $arg5, $arg6, $arg7)
    {
        $service = $this->service;

        $result = $service->compliesControl($arg1, $arg2, $arg3, $arg4, $arg5, $arg6, $arg7);

        PHPUnit_Framework_Assert::assertFalse($result);
    }

}
