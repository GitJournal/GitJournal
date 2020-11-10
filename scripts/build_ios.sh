#!/usr/bin/env bash

if [ -z ${FASTLANE_PASSWORD+x} ]; then
    echo "Must set FASTLANE_PASSWORD"
    exit 1
fi

set -eo pipefail

cd "$(dirname "$0")"
cd ../

# Check for uncommitted changes
if [[ $(git status -s | grep -v '??') ]]; then
    echo "Uncommitted Changes."
    echo "Exiting"
    git status
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

BUILD_NUM=$(git rev-list --count HEAD)
echo "Build Number: $BUILD_NUM"

BUILD_NAME=$(cat pubspec.yaml | grep version | awk '{ print $2 }' | awk -F "+" '{ print $1 }')
echo "Build Name: $BUILD_NAME"

flutter build ios --release --no-codesign --build-number=$BUILD_NUM --build-name=$BUILD_NAME

cd ios
fastlane release
