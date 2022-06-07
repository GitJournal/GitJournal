#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

set -eux

cd "$(dirname "$0")/../"

FLUTTER_VERSION_RANGE=$(cat pubspec.yaml | grep 'flutter:' | head -n 1 | awk '{ print $2 }' | tr -d '"')
FLUTTER_VERSION="${FLUTTER_VERSION_RANGE:2}"

echo "Using Flutter Version: $FLUTTER_VERSION"

wget -O flutter.zip https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_${FLUTTER_VERSION}-stable.zip
unzip flutter.zip
export PATH="$PATH:$(pwd)/flutter/bin"

flutter precache
flutter doctor
