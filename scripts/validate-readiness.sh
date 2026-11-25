#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
export MONARC_TEST_APP_DIR="$PWD"
released=0
runtime=0
for argument in "$@"; do
    case "$argument" in
        --released) released=1 ;;
        --runtime) runtime=1 ;;
        *) echo "Usage: bash scripts/validate-readiness.sh [--released] [--runtime]" >&2; exit 2 ;;
    esac
done
composer --no-plugins validate --strict --no-check-publish
composer --no-plugins check-platform-reqs
composer --no-plugins check-platform-reqs --lock
php -d error_reporting=32767 -d display_errors=stderr tests/locked-doctrine.php
if [[ "$released" -eq 1 ]]; then
    php tests/released-sources.php
    php -d error_reporting=32767 -d display_errors=stderr bin/phpunit -c phpunit.xml --testsuite Unit --exclude-group local-sources --display-all-issues
else
    php -d error_reporting=32767 -d display_errors=stderr bin/phpunit -c phpunit.xml --testsuite Unit --display-all-issues
    (
        cd ../zm-core
        MONARC_TEST_APP=MonarcAppFO php -d error_reporting=32767 -d display_errors=stderr "$MONARC_TEST_APP_DIR/bin/phpunit" -c phpunit.xml --display-all-issues
    )
    (
        cd ../zm-client
        MONARC_TEST_APP=MonarcAppFO php -d error_reporting=32767 -d display_errors=stderr "$MONARC_TEST_APP_DIR/bin/phpunit" -c phpunit.xml --display-all-issues
    )
fi
if [[ "$runtime" -eq 1 ]]; then
    source_args=()
    if [[ "$released" -eq 1 ]]; then source_args+=(--released); fi
    php -d error_reporting=32767 -d display_errors=stderr tests/runtime-readiness.php "${source_args[@]}" --strict-mapping --historicals --delivery-models --guides --questions --interviews --ropa
fi
