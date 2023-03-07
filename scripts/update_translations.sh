#!/bin/bash

pushd node_modules/ng_client

if [[ -d po && -f po/template.pot ]]; then
    for f in po/*.po; do
     msgmerge --backup=none -U "$f" po/template.pot
     msgattrib --no-obsolete --clear-fuzzy --empty -o "$f" "$f"
 done;
fi
