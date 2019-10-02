#!/usr/bin/env bash

set -eu

BUILD_NUM=`git rev-list --count HEAD`
echo "Build Number: $BUILD_NUM"

flutter build appbundle --build-number=$BUILD_NUM --verbose
flutter build apk --build-number=$BUILD_NUM --verbose
