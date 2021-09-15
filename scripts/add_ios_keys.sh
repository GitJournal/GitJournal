#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

set -eo pipefail

#
# Provisioning Profiles
#
cd ios/keys/profiles

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles

uuid=$(security cms -D -i CI__iogitjournalgitjournal.mobileprovision | grep -aA1 UUID | grep -o "[-a-zA-Z0-9]\{36\}")
cp ./CI__iogitjournalgitjournal.mobileprovision "$HOME/Library/MobileDevice/Provisioning Profiles/${uuid}.mobileprovision"

uuid=$(security cms -D -i CI__iogitjournalgitjournalShareExtension.mobileprovision | grep -aA1 UUID | grep -o "[-a-zA-Z0-9]\{36\}")
cp ./CI__iogitjournalgitjournalShareExtension.mobileprovision "$HOME/Library/MobileDevice/Provisioning Profiles/${uuid}.mobileprovision"

echo "Provisioning Profiles"
ls "$HOME/Library/MobileDevice/Provisioning Profiles/"

#
# Keychain
#
cd ..
echo ""
echo "Configuring Keychain"

KEYCHAIN_NAME="build.keychain"
KEYCHAIN_PATH="$HOME/Library/Keychains/$KEYCHAIN_NAME"
KEYCHAIN_PASSWORD=""

security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
security import dist.p12 -k "$KEYCHAIN_PATH" -P "$KEYCHAIN_PASSWORD" -A
security import dev.p12 -k "$KEYCHAIN_PATH" -P "$KEYCHAIN_PASSWORD" -A

security list-keychains -s "$KEYCHAIN_PATH"
security default-keychain -s "$KEYCHAIN_PATH"
security set-keychain-settings "$KEYCHAIN_PATH" # Remove relock timeout
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

# To fix "codesign  unable to build chain to self-signed root for signer"
# https://stackoverflow.com/a/66083449/147435
wget -q https://developer.apple.com/certificationauthority/AppleWWDRCA.cer
wget -q https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer

security add-certificates -k "$KEYCHAIN_PATH" "AppleWWDRCA.cer" || true
security add-certificates -k "$KEYCHAIN_PATH" "AppleWWDRCAG3.cer" || true

# Apple Magic https://stackoverflow.com/a/40870033/147435
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

# Print out installed code signing identities
# security find-identity -v -p codesigning
