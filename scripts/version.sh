#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

set -eu

VERSION=$(grep version pubspec.yaml | awk '{ print $2 }' | awk '{split($0,a,"+"); print a[1]}')

echo "Build Version: $VERSION"
echo "Build Number :   $(git rev-list HEAD --count)"
