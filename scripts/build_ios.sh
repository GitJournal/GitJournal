#!/usr/bin/env bash

if [ -z ${FASTLANE_PASSWORD+x} ]; then
    echo "Must set FASTLANE_PASSWORD"
    exit 1
fi

set -eu

cd "$(dirname "$0")"
cd ../

# Check for uncommitted changes
if [[ $(git status -s | grep -v '??') ]]; then
    echo "Uncommitted Changes."
    echo "Exiting"
    exit 1
fi

flutter build ios --release

cd ios
fastlane release
