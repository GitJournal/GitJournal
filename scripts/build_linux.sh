#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

set -eux

cd "$(dirname "$0")/.."

flutter config --enable-linux-desktop
flutter build linux

sed -i "s|_CODE_PATH_|$(pwd)|" AppImageBuilder.yml
appimage-builder --skip-test
