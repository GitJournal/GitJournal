#!/usr/bin/env bash

set -eu

BUILD_NUM=`git rev-list --count HEAD`
echo "Build Number: $BUILD_NUM"

flutter build appbundle --flavor prod --build-number=$BUILD_NUM --verbose
flutter build apk --flavor prod --build-number=$BUILD_NUM --verbose
