<?php declare(strict_types=1);

namespace Monarc\Zitadel\Controller;

use Exception;
use Laminas\Http\Response;
use Laminas\Mvc\Controller\AbstractActionController;
use Monarc\Zitadel\Service\ZitadelAuthService;

/**
 * Handles the Zitadel OIDC/PKCE authentication routes:
 *
 *   GET  /api/auth/zitadel/login            → redirect to Zitadel authorization endpoint
 *   GET  /api/auth/zitadel/callback         → exchange code, issue Monarc token, redirect to front-end
 *   POST /api/auth/zitadel/logout           → redirect to Zitadel end_session
 *   GET  /api/auth/zitadel/logout/callback  → validate state, clear session
 *
 * PKCE verifier, state and nonce are stored in short-lived HttpOnly cookies during the
 * login redirect and consumed in the callback. Monarc's actual authentication is
 * token-based (stored in user_tokens table), so no server-side session state is needed.
 */
class ZitadelAuthController extends AbstractActionController
{
    private ZitadelAuthService $zitadelAuthService;

    public function __construct(ZitadelAuthService $zitadelAuthService)
    {
        $this->zitadelAuthService = $zitadelAuthService;
    }

    private function jsonResponse(array $data, int $status = 200): Response
    {
        /** @var Response $response */
        $response = $this->getResponse();
        $response->setStatusCode($status);
        $response->getHeaders()->addHeaderLine('Content-Type', 'application/json');
        $response->setContent(json_encode($data, JSON_THROW_ON_ERROR));

        return $response;
    }

    /**
     * GET /api/auth/zitadel/login
     *
     * Generates PKCE parameters, stores the verifier + state in short-lived
     * HttpOnly cookies (no server-side session required), and redirects the
     * browser to the Zitadel authorization endpoint.
     */
    public function loginAction(): Response
    {
        try {
            $authData = $this->zitadelAuthService->buildAuthorizationUrl();
        } catch (Exception $e) {
            /** @var Response $response */
            $response = $this->getResponse();
            $response->setStatusCode(500);
            $response->setContent(json_encode(['error' => $e->getMessage()], JSON_THROW_ON_ERROR));

            return $response;
        }

        /** @var Response $response */
        $response = $this->getResponse();

        /** @var \Laminas\Http\Request $request */
        $request    = $this->getRequest();
        $uri        = $request->getUri();
        $isSecure   = $uri !== null && strtolower($uri->getScheme() ?? '') === 'https';
        $secure     = $isSecure ? '; Secure' : '';
        $cookiePath = '; Path=/api/auth/zitadel; HttpOnly; SameSite=Lax' . $secure;
        $ttl        = '; Max-Age=300'; // 5 minutes — enough for any SSO round-trip

        $response->getHeaders()
            ->addHeaderLine('Set-Cookie', 'zitadel_pkce_verifier=' . urlencode($authData['codeVerifier']) . $cookiePath . $ttl)
            ->addHeaderLine('Set-Cookie', 'zitadel_state=' . urlencode($authData['state']) . $cookiePath . $ttl)
            ->addHeaderLine('Set-Cookie', 'zitadel_nonce=' . urlencode($authData['nonce']) . $cookiePath . $ttl);

        $response->setStatusCode(302);
        $response->getHeaders()->addHeaderLine('Location', $authData['authorizeUrl']);

        return $response;
    }

    /**
     * GET /api/auth/zitadel/callback
     *
     * Handles the Zitadel redirect after user authentication:
     * 1. Validates state parameter (CSRF)
     * 2. Exchanges code for tokens via PKCE
     * 3. Issues a Monarc session token
     * 4. Redirects to the configured front-end post-login URL with the Monarc token in the URL fragment.
     */
    public function callbackAction()
    {
        /** @var \Laminas\Http\Request $request */
        $request      = $this->getRequest();
        $code         = $request->getQuery('code');
        $stateParam   = $request->getQuery('state');

        // PKCE verifier, state and nonce are stored in HttpOnly cookies by loginAction().
        $cookies      = $request->getCookie();
        $storedState  = $cookies ? urldecode((string)($cookies->offsetGet('zitadel_state') ?? '')) : null;
        $codeVerifier = $cookies ? urldecode((string)($cookies->offsetGet('zitadel_pkce_verifier') ?? '')) : null;
        $nonce        = $cookies ? urldecode((string)($cookies->offsetGet('zitadel_nonce') ?? '')) : null;

        /** @var Response $response */
        $response = $this->getResponse();

        // Clear the short-lived PKCE cookies.
        $clearCookie = '; Path=/api/auth/zitadel; HttpOnly; SameSite=Lax; Max-Age=0';
        $response->getHeaders()
            ->addHeaderLine('Set-Cookie', 'zitadel_pkce_verifier=; ' . $clearCookie)
            ->addHeaderLine('Set-Cookie', 'zitadel_state=; ' . $clearCookie)
            ->addHeaderLine('Set-Cookie', 'zitadel_nonce=; ' . $clearCookie);

        if (!$code || !$codeVerifier || !$nonce) {
            return $this->jsonResponse(['error' => 'Missing authorization code, PKCE verifier, or nonce.'], 400);
        }

        if (!$storedState || !hash_equals((string)$storedState, (string)$stateParam)) {
            return $this->jsonResponse(['error' => 'State mismatch — possible CSRF attack.'], 400);
        }

        try {
            $result = $this->zitadelAuthService->handleCallback($code, $codeVerifier, (string)$nonce);
        } catch (Exception $e) {
            return $this->jsonResponse(['error' => 'Zitadel authentication failed: ' . $e->getMessage()], 401);
        }

        $redirectUrl = $this->zitadelAuthService->buildPostLoginRedirectUrl($result);
        if ($redirectUrl === null) {
            return $this->jsonResponse($result);
        }

        $response->setStatusCode(302);
        $response->getHeaders()->addHeaderLine('Location', $redirectUrl);

        return $response;
    }

    /**
     * GET /api/auth/zitadel/logout?idToken=...
     *
     * Called by the frontend via browser navigation after the Monarc token has already
     * been revoked. Reads the idToken from the query string, builds the Zitadel
     * end_session URL and redirects the browser to Zitadel to end the SSO session.
     */
    public function logoutAction(): Response
    {
        /** @var \Laminas\Http\Request $request */
        $request = $this->getRequest();
        $idToken = $request->getQuery('idToken');

        if (!$idToken) {
            return $this->jsonResponse(['error' => 'idToken query parameter is required.'], 400);
        }

        try {
            $logoutData = $this->zitadelAuthService->buildLogoutUrl((string)$idToken);
        } catch (Exception $e) {
            return $this->jsonResponse(['error' => 'Failed to build Zitadel logout URL.'], 500);
        }

        /** @var Response $response */
        $response = $this->getResponse();

        $uri    = $request->getUri();
        $secure = ($uri !== null && strtolower($uri->getScheme() ?? '') === 'https') ? '; Secure' : '';
        $response->getHeaders()->addHeaderLine(
            'Set-Cookie',
            'zitadel_logout_state=' . urlencode($logoutData['state'])
            . '; Path=/api/auth/zitadel/logout/callback; HttpOnly; SameSite=Lax' . $secure
        );
        $response->setStatusCode(302);
        $response->getHeaders()->addHeaderLine('Location', $logoutData['url']);

        return $response;
    }

    /**
     * GET /api/auth/zitadel/logout/callback
     *
     * Validates the state CSRF cookie, clears it, and redirects the browser
     * back to the Angular app login page.
     */
    public function logoutCallbackAction(): Response
    {
        /** @var \Laminas\Http\Request $request */
        $request     = $this->getRequest();
        $stateParam  = $request->getQuery('state');
        $cookies     = $request->getCookie();
        $storedState = $cookies ? urldecode($cookies->offsetGet('zitadel_logout_state') ?? '') : '';

        /** @var Response $response */
        $response = $this->getResponse();
        $response->getHeaders()->addHeaderLine(
            'Set-Cookie',
            'zitadel_logout_state=; Path=/api/auth/zitadel/logout/callback; HttpOnly; Max-Age=0'
        );

        if (!$stateParam || !$storedState || !hash_equals($storedState, (string)$stateParam)) {
            return $this->jsonResponse(['error' => 'Invalid or missing state parameter.'], 400);
        }

        // Redirect browser back to the Angular app (login page).
        $response->setStatusCode(302);
        $response->getHeaders()->addHeaderLine('Location', '/');

        return $response;
    }
}
