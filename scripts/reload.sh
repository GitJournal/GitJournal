#!/usr/bin/env bash

cd "$(dirname "$0")"
cd ../

while true
do
    find lib/ -name '*.dart' | \
        entr -d -p ./scripts/reload_run_app.sh
done
