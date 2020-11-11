#!/usr/bin/env bash

set -eox pipefail

#
# Provisioning Profiles
#
cd ios/keys/profiles

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles

uuid=$(security cms -D -i CI__iogitjournalgitjournal.mobileprovision | grep -aA1 UUID | grep -o "[-a-zA-Z0-9]\{36\}")
cp ./CI__iogitjournalgitjournal.mobileprovision "$HOME/Library/MobileDevice/Provisioning Profiles/${uuid}.mobileprovision"

uuid=$(security cms -D -i CI__iogitjournalgitjournalShareExtension.mobileprovision | grep -aA1 UUID | grep -o "[-a-zA-Z0-9]\{36\}")
cp ./CI__iogitjournalgitjournalShareExtension.mobileprovision "$HOME/Library/MobileDevice/Provisioning Profiles/${uuid}.mobileprovision"

ls -l "$HOME/Library/MobileDevice/Provisioning Profiles/"

#
# Key Chain
#
cd ..

security create-keychain -p "" build.keychain
security import ios_distribution.cer -t agg -k ~/Library/Keychains/build.keychain -P "" -A

security list-keychains -s ~/Library/Keychains/build.keychain
security default-keychain -s ~/Library/Keychains/build.keychain
security unlock-keychain -p "" ~/Library/Keychains/build.keychain

#security set-key-partition-list -S apple-tool:,apple: -s -k "" ~/Library/Keychains/build.keychain
