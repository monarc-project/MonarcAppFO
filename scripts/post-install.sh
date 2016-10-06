#!/bin/bash

npm install

cd node_modules/ng_backoffice
npm install

cd ../..

# Compile stuff needed for the minified frontend
./scripts/compile_translations.sh
./scripts/link_modules_resources.sh