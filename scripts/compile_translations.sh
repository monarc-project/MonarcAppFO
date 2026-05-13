#!/bin/bash

set -e

APP_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export MONARC_PUBLIC_JS_DIR="$APP_ROOT/public/js"
export MONARC_PUBLIC_CSS_DIR="$APP_ROOT/public/css"

pushd "$APP_ROOT/node_modules/ng_client" >/dev/null

GRUNT_BIN="./node_modules/.bin/grunt"
if [ ! -x "$GRUNT_BIN" ]; then
    GRUNT_BIN="$(command -v grunt)"
fi

if [ -z "$GRUNT_BIN" ]; then
    echo "grunt is not available. Install project dependencies or provide a local grunt binary." >&2
    exit 1
fi

"$GRUNT_BIN" compile_translations
"$GRUNT_BIN" concat

if [ -d po ]; then
  for i in po/*.po; do
    [ -e "$i" ] || continue
    l=$(basename "$i" .po)
    msgfmt -o "./po/$l.mo" -v "$i"
  done
fi

popd >/dev/null
