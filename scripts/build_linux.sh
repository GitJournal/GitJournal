#!/usr/bin/env bash

set -eux

cd "$(dirname "$0")/.."

BUILD_NUM=$(git rev-list --count HEAD)
echo "Build Number: $BUILD_NUM"

BUILD_NAME=$(cat pubspec.yaml | grep version | awk '{ print $2 }' | awk -F "+" '{ print $1 }')
echo "Build Name: $BUILD_NAME"

flutter config --enable-linux-desktop
flutter build linux --release --build-number="$BUILD_NUM" --build-name="$BUILD_NAME"

sed -i "s|_CODE_PATH_|$(pwd)|" AppImageBuilder.yml
appimage-builder --skip-test
