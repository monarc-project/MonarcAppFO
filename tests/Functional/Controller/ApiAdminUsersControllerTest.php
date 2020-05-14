<?php declare(strict_types=1);

namespace MonarcAppFo\Tests\Functional\Controller;

use Monarc\Core\Model\Table\UserTable;
use Monarc\Core\Service\AuthenticationService;
use Monarc\Core\Service\ConnectedUserService;
use Monarc\Core\Model\Entity\UserRole;
use Monarc\FrontOffice\Controller\ApiAdminUsersController;
use Monarc\FrontOffice\Model\Entity\User;
use MonarcAppFo\Tests\Functional\AbstractFunctionalTestCase;
use PHPUnit\Framework\MockObject\MockObject;
use Laminas\Http\Header\HeaderInterface;
use Laminas\ServiceManager\ServiceManager;

class ApiAdminUsersControllerTest extends AbstractFunctionalTestCase
{
    //protected $traceError = false;

    /** @var ConnectedUserService */
    private $connectedUserService;

    /** @var AuthenticationService */
    private $authenticationService;

    protected function configureServiceManager(ServiceManager $serviceManager)
    {
        $serviceManager->setAllowOverride(true);

        $this->connectedUserService = $this->createMock(ConnectedUserService::class);
        $serviceManager->setService(ConnectedUserService::class, $this->connectedUserService);

        $this->authenticationService = $this->createMock(AuthenticationService::class);
        $serviceManager->setService(AuthenticationService::class, $this->authenticationService);

        $serviceManager->setAllowOverride(false);
    }

    public function testUserCreationByAdminUser()
    {
        $user = $this->createMock(User::class);
        $user->method('getRoles')->willReturn([UserRole::SUPER_ADMIN_FO]);
        $user->method('getId')->willReturn(1);

        $this->connectedUserService->method('getConnectedUser')->willReturn($user);
        $header = $this->createMock(HeaderInterface::class);
        $header->method('getFieldName')->willReturn('token');
        $header->method('getFieldValue')->willReturn('token-value');
        $this->getRequest()->getHeaders()->addHeader($header);

        $this->authenticationService
            ->expects($this->once())
            ->method('checkConnect')
            ->with(['token' => 'token-value'])
            ->willReturn(true);

        $email = 'testlast@gmail.com';

        $this->dispatch('/api/users', 'POST', [
            'firstname' => 'test',
            'lastname' => 'testlast',
            'email' => $email,
            'role' => [UserRole::USER_FO],
        ], true);

        $this->assertModuleName('Monarc');
        $this->assertControllerName(ApiAdminUsersController::class);
        $this->assertMatchedRouteName('monarc_api_admin_users');
        $this->assertResponseStatusCode(200);
        $this->assertEquals('{"status":"ok"}', $this->getResponse()->getContent());

        $this->removeTestUser($email);
    }

    public function testUserCreationFailsWhenEmailIsAlreadyExist()
    {
        $user = $this->createMock(User::class);
        $user->method('getRoles')->willReturn([UserRole::SUPER_ADMIN_FO]);
        $user->method('getId')->willReturn(1);

        $this->connectedUserService->method('getConnectedUser')->willReturn($user);
        $header = $this->createMock(HeaderInterface::class);
        $header->method('getFieldName')->willReturn('token');
        $header->method('getFieldValue')->willReturn('token-value');
        $this->getRequest()->getHeaders()->addHeader($header);

        $this->authenticationService
            ->expects($this->once())
            ->method('checkConnect')
            ->with(['token' => 'token-value'])
            ->willReturn(true);

        $email = 'testlast@gmail.com';

        $this->createTestUser($email);

        $this->dispatch('/api/users', 'POST', [
            'firstname' => 'test',
            'lastname' => 'testlast',
            'email' => $email,
            'role' => [UserRole::USER_FO],
        ], true);

        $this->assertModuleName('Monarc');
        $this->assertControllerName(ApiAdminUsersController::class);
        $this->assertMatchedRouteName('monarc_api_admin_users');
        $this->assertResponseStatusCode(400);
        $this->assertStringContainsString('This email is already used', $this->getResponse()->getContent());

        $this->removeTestUser($email);
    }

    protected function createTestUser(string $email): User
    {
        /** @var UserTable $userTable */
        $userTable = $this->getApplicationServiceLocator()->get(UserTable::class);
        $user = new User([
            'email' => $email,
            'firstname' => 'firstname',
            'lastname' => 'lastname',
            'language' => 'fr',
            'creator' => 'Test',
            'role' => [],
        ]);
        $userTable->saveEntity($user);

        return $user;
    }

    protected function removeTestUser(string $email): void
    {
        /** @var UserTable $userTable */
        $userTable = $this->getApplicationServiceLocator()->get(UserTable::class);
        $userTable->deleteEntity($userTable->findByEmail($email));
    }
}
