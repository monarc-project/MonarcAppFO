#!/bin/bash

pushd node_modules/ng_client
grunt compile_translations
grunt concat

if [ -d po ]; then
  for i in $(ls po/*\.po); do
    l=$(basename $i .po)
    msgfmt -o ./po/$l.mo -v ./po/$l.po
  done;
fi
