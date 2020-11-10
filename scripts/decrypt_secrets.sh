#!/usr/bin/env bash

set -eu pipefail

echo "$GITCRYPT_KEY" | base64 -d > ./secret
sha1sum ./secret

echo 'Unlocking ...'
git-crypt unlock ./secret
