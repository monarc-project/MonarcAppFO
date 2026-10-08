<?php declare(strict_types=1);

namespace Monarc\Zitadel\Service;

use Doctrine\ORM\EntityNotFoundException;
use Exception;
use Firebase\JWT\JWK;
use Firebase\JWT\JWT;
use Monarc\Core\Storage\Authentication as AuthenticationStorage;
use Monarc\FrontOffice\Entity\User;
use Monarc\FrontOffice\Entity\UserRole;
use Monarc\FrontOffice\Table\UserTable;
use stdClass;
use UnexpectedValueException;

/**
 * Handles the Zitadel OIDC/PKCE authentication flow:
 * - Generates PKCE challenge and authorization URL
 * - Exchanges authorization code for tokens using HTTP Basic Auth
 * - Validates the id_token JWT signature and standard claims
 * - Fetches userinfo from Zitadel
 * - Finds or auto-creates a Monarc user by email
 * - Issues a Monarc session token via AuthenticationStorage
 * - Supports access token refresh via the refresh_token grant
 * - Builds logout URL for OIDC end_session
 */
class ZitadelAuthService
{
    private AuthenticationStorage $authenticationStorage;

    private UserTable $userTable;

    private string $zitadelDomain;

    private string $backchannelDomain;

    private string $backchannelHostHeader;

    private string $clientId;

    private string $clientSecret;

    private string $callbackUrl;

    private string $postLogoutUrl;

    private string $postLoginUrl;

    /** @var string[] */
    private array $scopes;

    private bool $autoProvisionUsers;

    private bool $requireEmailVerified;

    /** @var string[] */
    private array $allowedEmailDomains;

    /** @var string[] */
    private array $allowedResourceOwnerIds;

    private string $defaultRole;

    private int $defaultLanguage;

    private int $clockSkewSeconds;

    public function __construct(
        AuthenticationStorage $authenticationStorage,
        UserTable $userTable,
        string $zitadelDomain,
        string $backchannelDomain,
        string $backchannelHostHeader,
        string $clientId,
        string $clientSecret,
        string $callbackUrl,
        string $postLogoutUrl,
        string $postLoginUrl = '',
        array $scopes = [],
        bool $autoProvisionUsers = true,
        bool $requireEmailVerified = true,
        array $allowedEmailDomains = [],
        array $allowedResourceOwnerIds = [],
        string $defaultRole = UserRole::USER_FO,
        int $defaultLanguage = 1,
        int $clockSkewSeconds = 60
    ) {
        $this->authenticationStorage = $authenticationStorage;
        $this->userTable             = $userTable;
        $this->zitadelDomain         = rtrim($zitadelDomain, '/');
        $this->backchannelDomain     = rtrim($backchannelDomain !== '' ? $backchannelDomain : $zitadelDomain, '/');
        $this->backchannelHostHeader = $backchannelHostHeader;
        $this->clientId              = $clientId;
        $this->clientSecret          = $clientSecret;
        $this->callbackUrl           = $callbackUrl;
        $this->postLogoutUrl         = $postLogoutUrl;
        $this->postLoginUrl          = $postLoginUrl;
        $this->scopes                = $scopes ?: [
            'openid',
            'profile',
            'email',
            'urn:zitadel:iam:user:metadata',
            'urn:zitadel:iam:user:resourceowner',
            'urn:zitadel:iam:org:projects:roles',
        ];
        $this->autoProvisionUsers      = $autoProvisionUsers;
        $this->requireEmailVerified    = $requireEmailVerified;
        $this->allowedEmailDomains     = array_values(array_filter($allowedEmailDomains));
        $this->allowedResourceOwnerIds = array_values(array_filter($allowedResourceOwnerIds));
        $this->defaultRole             = $defaultRole;
        $this->defaultLanguage         = $defaultLanguage;
        $this->clockSkewSeconds        = $clockSkewSeconds;
    }

    /**
     * Generates PKCE parameters and the Zitadel authorization URL.
     *
     * @return array{authorizeUrl: string, codeVerifier: string, state: string, nonce: string}
     * @throws Exception
     */
    public function buildAuthorizationUrl(): array
    {
        $codeVerifier  = rtrim(strtr(base64_encode(random_bytes(32)), '+/', '-_'), '=');
        $codeChallenge = rtrim(strtr(base64_encode(hash('sha256', $codeVerifier, true)), '+/', '-_'), '=');
        $state         = bin2hex(random_bytes(16));
        $nonce         = bin2hex(random_bytes(16));

        $params = http_build_query([
            'client_id'             => $this->clientId,
            'redirect_uri'          => $this->callbackUrl,
            'response_type'         => 'code',
            'scope'                 => implode(' ', $this->scopes),
            'state'                 => $state,
            'nonce'                 => $nonce,
            'code_challenge'        => $codeChallenge,
            'code_challenge_method' => 'S256',
        ]);

        return [
            'authorizeUrl' => $this->zitadelDomain . '/oauth/v2/authorize?' . $params,
            'codeVerifier' => $codeVerifier,
            'state'        => $state,
            'nonce'        => $nonce,
        ];
    }

    /**
     * Exchanges the authorization code for tokens, validates the id_token, fetches userinfo,
     * creates/finds the Monarc user, issues a Monarc session token and returns it together
     * with user metadata and the id_token (needed for OIDC logout).
     *
     * @return array{token: string, uid: int, language: int, idToken: string}
     * @throws Exception
     */
    public function handleCallback(string $code, string $codeVerifier, string $nonce): array
    {
        $tokens = $this->exchangeCodeForTokens($code, $codeVerifier);

        if (empty($tokens['access_token'])) {
            throw new Exception('No access_token in token response.');
        }

        if (empty($tokens['id_token'])) {
            throw new Exception(
                'Zitadel did not return an id_token. Ensure the "openid" scope is requested.'
            );
        }

        // Validate the id_token signature and standard claims before trusting any data from it.
        $idTokenPayload = $this->validateIdToken($tokens['id_token'], $nonce);

        $userInfo = $this->fetchUserInfo($tokens['access_token']);
        $this->validateUserInfo($userInfo, $idTokenPayload);

        if (empty($userInfo['email'])) {
            throw new Exception('No email claim in Zitadel userinfo response.');
        }

        $user  = $this->findOrCreateUser($userInfo);
        $token = bin2hex(random_bytes(32));
        $this->authenticationStorage->addUserToken($token, $user);

        return [
            'token'    => $token,
            'uid'      => $user->getId(),
            'language' => $user->getLanguage(),
            'idToken'  => $tokens['id_token'],
        ];
    }

    public function buildPostLoginRedirectUrl(array $loginResult): ?string
    {
        if ($this->postLoginUrl === '') {
            return null;
        }

        $separator = str_contains($this->postLoginUrl, '#') ? '&' : '#';

        return $this->postLoginUrl . $separator . http_build_query([
            'token'    => $loginResult['token'],
            'uid'      => $loginResult['uid'],
            'language' => $loginResult['language'],
            'idToken'  => $loginResult['idToken'],
        ]);
    }

    public function logoutLocalToken(?string $token): bool
    {
        if ($token === null || $token === '') {
            return false;
        }

        return $this->authenticationStorage->removeUserToken($token);
    }

    /**
     * Builds the Zitadel end_session URL with CSRF state for logout.
     *
     * @return array{url: string, state: string}
     * @throws Exception
     */
    public function buildLogoutUrl(string $idToken): array
    {
        $state  = bin2hex(random_bytes(16));
        $params = http_build_query([
            'id_token_hint'            => $idToken,
            'post_logout_redirect_uri' => $this->postLogoutUrl,
            'state'                    => $state,
        ]);

        return [
            'url'   => $this->zitadelDomain . '/oidc/v1/end_session?' . $params,
            'state' => $state,
        ];
    }

    // -------------------------------------------------------------------------
    // Private helpers
    // -------------------------------------------------------------------------

    /**
     * Exchanges the PKCE authorization code for an access + id + refresh token set.
     * Uses HTTP Basic Auth to send credentials, as required by confidential Zitadel clients.
     *
     * @return array<string, mixed>
     * @throws Exception
     */
    private function exchangeCodeForTokens(string $code, string $codeVerifier): array
    {
        $data = $this->postTokenRequest([
            'grant_type'    => 'authorization_code',
            'code'          => $code,
            'redirect_uri'  => $this->callbackUrl,
            'code_verifier' => $codeVerifier,
        ]);
        if (empty($data['access_token'])) {
            throw new Exception('No access_token in token response.');
        }

        return $data;
    }

    /**
     * Validates the id_token JWT:
     * - Fetches the public keys from Zitadel's JWKS endpoint
     * - Verifies the signature
     * - Checks iss, aud, exp, and iat claims
     *
     * @throws Exception if validation fails for any reason
     */
    private function validateIdToken(string $idToken, string $nonce): stdClass
    {
        $jwks = $this->fetchJwks();
        $previousLeeway = JWT::$leeway;

        try {
            $keys    = JWK::parseKeySet($jwks, 'RS256');
            JWT::$leeway = $this->clockSkewSeconds;
            $payload = JWT::decode($idToken, $keys);
        } catch (UnexpectedValueException $e) {
            throw new Exception('id_token validation failed: ' . $e->getMessage(), 0, $e);
        } finally {
            JWT::$leeway = $previousLeeway;
        }

        // Verify issuer matches our Zitadel domain.
        if (!isset($payload->iss) || $payload->iss !== $this->zitadelDomain) {
            throw new Exception(sprintf(
                'id_token issuer mismatch: expected "%s", got "%s".',
                $this->zitadelDomain,
                $payload->iss ?? '(missing)'
            ));
        }

        // Verify audience contains our client ID.
        $audiences = is_array($payload->aud ?? null) ? $payload->aud : [(string)($payload->aud ?? '')];
        if (!in_array($this->clientId, $audiences, true)) {
            throw new Exception(sprintf(
                'id_token audience does not include client_id "%s".',
                $this->clientId
            ));
        }

        if (!isset($payload->nonce) || !hash_equals($nonce, (string)$payload->nonce)) {
            throw new Exception('id_token nonce mismatch.');
        }

        return $payload;
    }

    /**
     * Fetches Zitadel's public JWKS (JSON Web Key Set) used to verify id_token signatures.
     *
     * @return array<string, mixed>
     * @throws Exception
     */
    private function fetchJwks(): array
    {
        return $this->getJson($this->backchannelDomain . '/oauth/v2/keys', ['Accept: application/json']);
    }

    /**
     * @return array<string, mixed>
     * @throws Exception
     */
    private function fetchUserInfo(string $accessToken): array
    {
        return $this->getJson($this->backchannelDomain . '/oidc/v1/userinfo', [
            'Authorization: Bearer ' . $accessToken,
        ]);
    }

    /**
     * @param array<string, mixed> $userInfo
     * @throws Exception
     */
    private function validateUserInfo(array $userInfo, stdClass $idTokenPayload): void
    {
        if (empty($userInfo['sub']) || !isset($idTokenPayload->sub) || $userInfo['sub'] !== $idTokenPayload->sub) {
            throw new Exception('Zitadel userinfo subject does not match id_token subject.');
        }

        if ($this->requireEmailVerified && empty($userInfo['email_verified'])) {
            throw new Exception('Zitadel email address is not verified.');
        }

        if ($this->allowedEmailDomains !== [] && !empty($userInfo['email'])) {
            $domain = strtolower(substr(strrchr((string)$userInfo['email'], '@') ?: '', 1));
            if (!in_array($domain, array_map('strtolower', $this->allowedEmailDomains), true)) {
                throw new Exception('Zitadel email domain is not allowed.');
            }
        }

        if ($this->allowedResourceOwnerIds !== []) {
            $resourceOwnerId = (string)($userInfo['urn:zitadel:iam:user:resourceowner:id'] ?? '');
            if (!in_array($resourceOwnerId, $this->allowedResourceOwnerIds, true)) {
                throw new Exception('Zitadel resource owner is not allowed.');
            }
        }
    }

    /**
     * @param array<string, string> $fields
     * @return array<string, mixed>
     * @throws Exception
     */
    private function postTokenRequest(array $fields): array
    {
        $headers = ['Content-Type: application/x-www-form-urlencoded'];
        if ($this->backchannelHostHeader !== '') {
            $headers[] = 'Host: ' . $this->backchannelHostHeader;
        }
        if ($this->clientSecret !== '') {
            $headers[] = 'Authorization: Basic ' . base64_encode($this->clientId . ':' . $this->clientSecret);
        } else {
            $fields['client_id'] = $this->clientId;
        }

        $ch = curl_init($this->backchannelDomain . '/oauth/v2/token');
        if ($ch === false) {
            throw new Exception('Failed to initialize Zitadel token request.');
        }

        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST           => true,
            CURLOPT_CONNECTTIMEOUT => 5,
            CURLOPT_TIMEOUT        => 15,
            CURLOPT_POSTFIELDS     => http_build_query($fields),
            CURLOPT_HTTPHEADER     => $headers,
        ]);

        $body   = curl_exec($ch);
        $status = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error  = curl_error($ch);
        curl_close($ch);

        if ($status !== 200 || $body === false) {
            throw new Exception('Failed to exchange tokens with Zitadel (HTTP ' . $status . '): ' . $error);
        }

        return json_decode((string)$body, true, 512, JSON_THROW_ON_ERROR);
    }

    /**
     * @param string[] $headers
     * @return array<string, mixed>
     * @throws Exception
     */
    private function getJson(string $url, array $headers): array
    {
        if ($this->backchannelHostHeader !== '') {
            $headers[] = 'Host: ' . $this->backchannelHostHeader;
        }

        $ch = curl_init($url);
        if ($ch === false) {
            throw new Exception('Failed to initialize Zitadel request.');
        }

        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_CONNECTTIMEOUT => 5,
            CURLOPT_TIMEOUT        => 15,
            CURLOPT_HTTPHEADER     => $headers,
        ]);

        $body   = curl_exec($ch);
        $status = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error  = curl_error($ch);
        curl_close($ch);

        if ($status !== 200 || $body === false) {
            throw new Exception('Failed to fetch Zitadel resource (HTTP ' . $status . '): ' . $error);
        }

        return json_decode((string)$body, true, 512, JSON_THROW_ON_ERROR);
    }

    /**
     * Finds an existing Monarc user by email, or auto-creates one if auto-provisioning
     * is enabled. Throws if the user does not exist and provisioning is disabled.
     *
     * @param array<string, mixed> $userInfo
     * @throws Exception
     */
    private function findOrCreateUser(array $userInfo): User
    {
        $email = (string)$userInfo['email'];

        try {
            /** @var User $user */
            return $this->userTable->findByEmail($email);
        } catch (EntityNotFoundException) {
            // User does not exist — auto-provision below if enabled.
        }

        if (!$this->autoProvisionUsers) {
            throw new Exception(sprintf(
                'No Monarc account found for "%s" and auto-provisioning is disabled.',
                $email
            ));
        }

        $nameParts = explode(' ', (string)($userInfo['name'] ?? $email), 2);
        $firstname = $nameParts[0] ?? '';
        $lastname  = $nameParts[1] ?? '';

        $user = new User([
            'firstname'  => $firstname,
            'lastname'   => $lastname,
            'email'      => $email,
            'role'       => [$this->defaultRole],
            'creator'    => 'Monarc SSO',
            'language'   => $this->defaultLanguage,
            'mospApiKey' => '',
        ]);

        $this->userTable->save($user);

        return $user;
    }
}
