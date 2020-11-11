#!/usr/bin/env bash

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
ls

KEYCHAIN_NAME="build.keychain"
KEYCHAIN_PATH="$HOME/Library/Keychains/$KEYCHAIN_NAME"

security create-keychain -p "" "$KEYCHAIN_NAME"
security import dist.p12 -k "$KEYCHAIN_PATH" -P "" -A
security import dev.p12 -k "$KEYCHAIN_PATH" -P "" -A

security list-keychains -s "$KEYCHAIN_PATH"
security default-keychain -s "$KEYCHAIN_PATH"
security unlock-keychain -p "" "$KEYCHAIN_PATH"

# Apple Magic https://stackoverflow.com/a/40870033/147435
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "" "$KEYCHAIN_PATH"

# Print out installed code signing identities
security find-identity -v -p codesigning
