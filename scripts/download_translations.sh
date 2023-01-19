#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

set -eu

cd "$(dirname "$0")"

ID=$(awk '{print $1}' secrets/poeditor-api-key.txt)
TOKEN=$(awk '{print $2}' secrets/poeditor-api-key.txt)

langs=$(curl -s -X POST https://api.poeditor.com/v2/languages/list -d api_token="$TOKEN" -d id="$ID" | jq -r .result.languages[].code)

cd "../lib/l10n"
for lang in $langs; do
    echo "Downloading for $lang"

    url=$(curl -s -X POST https://api.poeditor.com/v2/projects/export -d api_token="$TOKEN" -d id="$ID" -d language="$lang" -d type="arb" | jq -r .result.url)

    TEMP_FILE="/tmp/t"
    wget -q -O $TEMP_FILE "$url"
    cat $TEMP_FILE | jq >"app_$lang.arb"
done

mv app_pt-br.arb app_pt.arb
mv app_zh-Hans.arb app_zh_Hans.arb
mv app_zh-TW.arb app_zh_TW.arb

echo "Done"
