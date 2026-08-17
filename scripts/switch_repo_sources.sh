#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
APP_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)
COMPOSE_FILE="${APP_DIR}/docker-compose.dev.yml"

MODE="${1:-}"
SERVICE_NAME="monarcfoapp"

CORE_PACKAGE="monarc/core"
APP_PACKAGE="monarc/frontoffice"

CORE_REPOSITORY_KEY="repositories.monarc-core"
APP_REPOSITORY_KEY="repositories.monarc-frontoffice"

CORE_PATH="/var/www/html/zm-core"
APP_PATH="/var/www/html/zm-client"
LOCAL_PACKAGE_VERSION=$(sed -nE 's/^[[:space:]]*"monarc\/core":[[:space:]]*"\^([0-9]+\.[0-9]+)\.[0-9]+".*/\1.999/p' "${APP_DIR}/composer.json")

SHARED_NG_NAME="ng_anr"
SHARED_NG_REMOTE_URL="https://github.com/monarc-project/ng-anr.git"
SHARED_NG_LOCAL_TARGET="../../ng-anr"
SHARED_NG_CONTAINER_PATH="/var/www/html/ng-anr"

APP_NG_NAME="ng_client"
APP_NG_REMOTE_URL="https://github.com/monarc-project/ng-client.git"
APP_NG_LOCAL_TARGET="../../ng-client"
APP_NG_CONTAINER_PATH="/var/www/html/ng-client"

usage() {
    cat <<'EOF'
Switch FrontOffice dependencies between local sibling repos and remote packages.

Usage:
  ./scripts/switch_repo_sources.sh local
  ./scripts/switch_repo_sources.sh remote
  ./scripts/switch_repo_sources.sh status

Notes:
  - Requires the Docker dev app container to be running.
  - "local" uses Composer path repositories and node_modules symlinks to sibling repos.
  - "remote" removes those overrides and restores node_modules/ng_* as GitHub clones.
EOF
}

require_running_service() {
    if ! docker compose -f "${COMPOSE_FILE}" ps --status running --services | grep -qx "${SERVICE_NAME}"; then
        echo "Docker service '${SERVICE_NAME}' is not running. Start it with:"
        echo "  docker compose -f docker-compose.dev.yml up -d --build"
        exit 1
    fi
}

require_sibling_repositories() {
    local repo
    for repo in zm-core zm-client ng-anr ng-client; do
        if [[ ! -d "${APP_DIR}/../${repo}" ]]; then
            echo "Missing required sibling repository: ${APP_DIR}/../${repo}"
            exit 1
        fi
    done

    if [[ -z "${LOCAL_PACKAGE_VERSION}" ]]; then
        echo "Unable to derive a compatible local package version from composer.json."
        exit 1
    fi
}

run_in_app() {
    docker compose -f "${COMPOSE_FILE}" exec -T "${SERVICE_NAME}" sh -lc "cd /var/www/html/monarc && $*"
}

switch_php_to_local() {
    run_in_app "composer config ${CORE_REPOSITORY_KEY} '{\"type\":\"path\",\"url\":\"${CORE_PATH}\",\"options\":{\"symlink\":true,\"versions\":{\"${CORE_PACKAGE}\":\"${LOCAL_PACKAGE_VERSION}\"}}}'"
    run_in_app "composer config ${APP_REPOSITORY_KEY} '{\"type\":\"path\",\"url\":\"${APP_PATH}\",\"options\":{\"symlink\":true,\"versions\":{\"${APP_PACKAGE}\":\"${LOCAL_PACKAGE_VERSION}\"}}}'"
    run_in_app "composer update ${CORE_PACKAGE} ${APP_PACKAGE}"
}

switch_php_to_remote() {
    run_in_app "composer config --unset ${CORE_REPOSITORY_KEY} || true"
    run_in_app "composer config --unset ${APP_REPOSITORY_KEY} || true"
    run_in_app "composer update ${CORE_PACKAGE} ${APP_PACKAGE}"
}

switch_js_to_local() {
    run_in_app "mkdir -p node_modules && rm -rf 'node_modules/${SHARED_NG_NAME}' 'node_modules/${APP_NG_NAME}' && ln -s '${SHARED_NG_LOCAL_TARGET}' 'node_modules/${SHARED_NG_NAME}' && ln -s '${APP_NG_LOCAL_TARGET}' 'node_modules/${APP_NG_NAME}'"

    run_in_app "cd '${SHARED_NG_CONTAINER_PATH}' && npm install"
    run_in_app "cd '${APP_NG_CONTAINER_PATH}' && npm ci"
    run_in_app "./scripts/link_modules_resources.sh"
    run_in_app "./scripts/compile_translations.sh"
}

switch_js_to_remote() {
    run_in_app "rm -rf 'node_modules/${SHARED_NG_NAME}' 'node_modules/${APP_NG_NAME}' && mkdir -p node_modules && git clone --config core.fileMode=false '${SHARED_NG_REMOTE_URL}' 'node_modules/${SHARED_NG_NAME}'"
    run_in_app "git clone --config core.fileMode=false '${APP_NG_REMOTE_URL}' 'node_modules/${APP_NG_NAME}'"
    run_in_app "cd 'node_modules/${SHARED_NG_NAME}' && npm install"
    run_in_app "cd 'node_modules/${APP_NG_NAME}' && npm ci"
    run_in_app "./scripts/link_modules_resources.sh"
    run_in_app "./scripts/compile_translations.sh"
}

print_status() {
    local php_mode="remote"
    local js_mode="remote"

    if docker compose -f "${COMPOSE_FILE}" exec -T "${SERVICE_NAME}" sh -lc "[ -L /var/www/html/monarc/vendor/monarc/core ] && [ -L /var/www/html/monarc/vendor/monarc/frontoffice ]"; then
        php_mode="local"
    fi

    if docker compose -f "${COMPOSE_FILE}" exec -T "${SERVICE_NAME}" sh -lc "[ -L /var/www/html/monarc/node_modules/${SHARED_NG_NAME} ] || [ -L /var/www/html/monarc/node_modules/${APP_NG_NAME} ]"; then
        js_mode="local"
    fi

    echo "PHP source mode: ${php_mode}"
    echo "JS source mode: ${js_mode}"
}

case "${MODE}" in
    local)
        require_sibling_repositories
        require_running_service
        switch_php_to_local
        switch_js_to_local
        print_status
        ;;
    remote)
        require_running_service
        switch_php_to_remote
        switch_js_to_remote
        print_status
        ;;
    status)
        require_running_service
        print_status
        ;;
    *)
        usage
        exit 1
        ;;
esac
