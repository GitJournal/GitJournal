#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

set -eux pipefail

cd "$(dirname "$0")"/../ios

rm -rf libs
mkdir -p libs
cd libs

curl -J -L \
    https://github.com/GitJournal/build-openssl-ios/releases/download/v1.1.1b/release.tgz \
    -o release_openssl.tar.gz

curl -J -L \
    https://github.com/GitJournal/ios-libraries/releases/download/v1.0/release.tgz \
    -o release.tar.gz

tar -xf release_openssl.tar.gz
rm -rf release_openssl.tar.gz

tar -xf release.tar.gz
rm -rf release.tar.gz
