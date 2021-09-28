#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

set -eo pipefail

cd "$(dirname "$0")"
cd ../

flutter pub get

# Download the required libraries
export LIBS_URL="https://github.com/GitJournal/ios-libraries/releases/download/v1.1/libs.zip"

if [ ! -d "ios/libs" ]; then
    echo "Downloading Libs"
    wget -q "$LIBS_URL"
    cd ios
    unzip -q ../libs.zip
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

# I cannot figure out why the flutter replace isn't working for the ShareExtension
if ! command -v which gsed &>/dev/null; then
    echo "gsed could not be found"

    sed -i "s|\$(FLUTTER_BUILD_NAME)|$BUILD_NAME|" ios/ShareExtension/Info.plist
    sed -i "s|\$(FLUTTER_BUILD_NUMBER)|$BUILD_NUM|" ios/ShareExtension/Info.plist

else
    gsed -i "s|\$(FLUTTER_BUILD_NAME)|$BUILD_NAME|" ios/ShareExtension/Info.plist
    gsed -i "s|\$(FLUTTER_BUILD_NUMBER)|$BUILD_NUM|" ios/ShareExtension/Info.plist
fi

xcodebuild -version

flutter build ios --release --no-codesign --build-number="$BUILD_NUM" --build-name="$BUILD_NAME" --dart-define=INSTALL_SOURCE=appstore

cd ios

export FASTLANE_PASSWORD=$(cat keys/fastlane_password)

echo "Updating fastlane ..."
bundle exec fastlane --version
bundle update fastlane
bundle exec fastlane --version

echo "fastlane release ..."
bundle exec fastlane release
