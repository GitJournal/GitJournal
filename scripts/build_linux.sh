#!/usr/bin/env bash

set -eux

cd "$(dirname "$0")/.."

flutter config --enable-linux-desktop
flutter build linux

appimage-builder --skip-test
