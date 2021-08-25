#!/usr/bin/env bash

set -eo pipefail

cd "$(dirname "$0")"
cd ../

flutter pub get

BUILD_NUM=$(git rev-list --count HEAD)
echo "Build Number: $BUILD_NUM"

BUILD_NAME=$(cat pubspec.yaml | grep version | awk '{ print $2 }' | awk -F "+" '{ print $1 }')
echo "Build Name: $BUILD_NAME"

xcodebuild -version

export MACOS_APP_RELEASE_PATH=build/macos/Build/Products/Release
flutter build macos --release --no-codesign --build-number="$BUILD_NUM" --build-name="$BUILD_NAME"

# Signing
export APP_NAME=GitJournal
export MACOS_APP_PATH=./$MACOS_APP_RELEASE_PATH/$APP_NAME.app

/usr/bin/codesign -vv --force --deep -s 2BC9130EA0A9C6F623E1AAEB5594BFA04FA875F3 "$MACOS_APP_PATH"

# Debugging Signing Issues
pkgutil --check-signature "$MACOS_APP_PATH"
codesign -dvv "$MACOS_APP_PATH"

# Build dmg
cd $MACOS_APP_RELEASE_PATH

create-dmg \
    --volname "$APP_NAME" \
    --window-pos 200 120 \
    --window-size 800 529 \
    --icon-size 130 \
    --text-size 14 \
    --icon "$APP_NAME.app" 260 250 \
    --hide-extension "$APP_NAME.app" \
    --app-drop-link 540 250 \
    --hdiutil-quiet \
    "$APP_NAME.dmg" \
    "$APP_NAME.app"
