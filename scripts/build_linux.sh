#!/usr/bin/env bash

set -eux

cd "$(dirname "$0")/.."

flutter config --enable-linux-desktop
flutter build linux

sed -i "s|_CODE_PATH_|$(pwd)|" AppImageBuilder.yml
appimage-builder --skip-test
