#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
bash scripts/check_node.sh

composer validate --strict
composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader
php tests/released-sources.php
php tests/locked-doctrine.php
# Compile every packaged module file before building the frontend or an artifact.
find vendor/monarc -type f -name '*.php' -print0 | xargs -0 -n 1 php -l

mkdir -p module/Monarc data/cache data/LazyServices/Proxy data/DoctrineORMModule/Proxy data/import/files public/captcha
ln -sfn ../../vendor/monarc/core module/Monarc/Core
if [[ -d vendor/monarc/frontoffice ]]; then
    ln -sfn ../../vendor/monarc/frontoffice module/Monarc/FrontOffice
else
    ln -sfn ../../vendor/monarc/backoffice module/Monarc/BackOffice
fi
./scripts/install-frontend.sh
./scripts/link_modules_resources.sh
./scripts/compile_translations.sh
