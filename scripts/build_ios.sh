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

# Download the required libraries
export LIBS_URL="https://github.com/GitJournal/ios-libraries/releases/download/v1.1/libs.zip"

if [ ! -d "ios/libs" ]; then
    echo "Downloading Libs"
    wget "$LIBS_URL"
    cd ios
    unzip ../libs.zip
    cd -
    rm libs.zip
fi

# Place gj_common
if [ ! -L "gj_common" ]; then
    echo "=> gj_common doesn't exist. Cloning"
    git clone https://github.com/GitJournal/git_bindings.git
    ln -s git_bindings/gj_common gj_common
fi

flutter build ios --release --no-codesign

#cd ios
#fastlane release

#git co .
