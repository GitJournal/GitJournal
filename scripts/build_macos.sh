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
flutter config --enable-macos-desktop
flutter build macos --release --build-number="$BUILD_NUM" --build-name="$BUILD_NAME"

# Signing and Notarizing
export APP_NAME=GitJournal
export APP_NOTARIZER="$(pwd)/scripts/app_notarizer.sh"
export FASTLANE_PASSWORD=$(cat ios/keys/fastlane_password)
export ENTITLEMENTS="$(pwd)/macos/Runner/Release.entitlements"

cd "$MACOS_APP_RELEASE_PATH"

$APP_NOTARIZER --notarize -a "$APP_NAME.app" -b "io.gitjournal.gitjournal" \
    -u "ios.ci@gitjournal.io" -p "$FASTLANE_PASSWORD" \
    -e "$ENTITLEMENTS" -v "4NYTN6RU3N" \
    -i "Developer ID Application: Vishesh Handa (4NYTN6RU3N)"

xml sel -t -v "//plist" /tmp/app_notarizer | grep -A 1 RequestUUID | tail -n 1 | tr -d "[:blank:]" >/tmp/app_notarize

# FIXME: What till request is done?
$APP_NOTARIZER --staple --file "$APP_NAME.app"

echo ""
echo " -- Creating DMG -- "
echo ""

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

$APP_NOTARIZER --notarize -a "$APP_NAME.dmg" -b "io.gitjournal.gitjournal" \
    -u "ios.ci@gitjournal.io" -p "$FASTLANE_PASSWORD" \
    -v "4NYTN6RU3N" \
    -i "Developer ID Installer: Vishesh Handa (4NYTN6RU3N)"

xml sel -t -v "//plist" /tmp/app_notarizer | grep -A 1 RequestUUID | tail -n 1 | tr -d "[:blank:]" >/tmp/dmg_notarize

# FIXME: What till request is done?
$APP_NOTARIZER --staple --file "$APP_NAME.dmg"
