#!/usr/bin/env bash

set -eux

cd "$(dirname "$0")"/../android/app

BUILD_NUM=$(curl -s 'https://circleci.com/api/v1.1/project/github/GitJournal/ndk-libraries?limit=1&offset=0&filter=successful' | jq .[0] | jq -r .build_num)
echo "CircleCI Buld Number: $BUILD_NUM"

URL=$(curl -s https://circleci.com/api/v1.1/project/github/GitJournal/ndk-libraries/$BUILD_NUM/artifacts | grep -o 'https://[^"]*libs.tar')

echo "Downloading $URL"

curl "$URL" -o "libs.tar"
rm -rf libs
tar xf libs.tar
mv libs ci_libs
mkdir libs
cp -r ci_libs/openssl-lib/* libs/
cp -r ci_libs/libssh2/* libs/
cp -r ci_libs/libgit2/* libs/
rm -rf ci_libs
rm libs.tar
