#!/usr/bin/env bash

set -eux pipefail

BUILD_NUM=$(git rev-list --count HEAD)
echo "Build Number: $BUILD_NUM"

flutter build appbundle --flavor prod --build-number="$BUILD_NUM" --verbose

# Also building the apk, as it's useful for non Google Play users
flutter build apk --flavor prod --build-number="$BUILD_NUM" --verbose
