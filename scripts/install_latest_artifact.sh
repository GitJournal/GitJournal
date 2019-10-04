#!/usr/bin/env bash

set -eu

BUILD_NUM=`curl -s 'https://circleci.com/api/v1.1/project/github/GitJournal/GitJournal?limit=1&offset=0&filter=successful' | jq .[0] | jq -r .build_num`
echo "CircleCI Buld Number: $BUILD_NUM"

URL=`curl -s https://circleci.com/api/v1.1/project/github/GitJournal/GitJournal/$BUILD_NUM/artifacts | jq .[1] | jq -r .url`
APK_LOCATION="/tmp/gitjournal.apk"

echo "Downloading $URL"
curl "$URL" -o "$APK_LOCATION"

adb uninstall io.gitjournal.gitjournal || true
adb install -r "$APK_LOCATION"
