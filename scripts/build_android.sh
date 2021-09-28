#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

set -eux pipefail

BUILD_NUM=$(git rev-list --count HEAD)
echo "Build Number: $BUILD_NUM"

flutter build appbundle --flavor prod --build-number="$BUILD_NUM" --dart-define=INSTALL_SOURCE=playstore --verbose

# Also building the apk, as it's useful for non Google Play users
flutter build apk --flavor prod --build-number="$BUILD_NUM" --dart-define=INSTALL_SOURCE=fdroid --verbose
