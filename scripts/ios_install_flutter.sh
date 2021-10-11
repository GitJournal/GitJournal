#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

set -eux

wget -O flutter.zip https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_2.5.2-stable.zip
unzip flutter.zip
export PATH="$PATH:$(pwd)/flutter/bin"

flutter precache
flutter doctor
