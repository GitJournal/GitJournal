#!/usr/bin/env bash

set -eux

flutter config --enable-linux-desktop
flutter build linux

appimage-builder --skip-test
