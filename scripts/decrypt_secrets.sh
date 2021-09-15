#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

set -eu pipefail

echo "$GITCRYPT_KEY" | base64 -d > ./secret
sha1sum ./secret

echo 'Unlocking ...'
git-crypt unlock ./secret
