#!/usr/bin/bash

# SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

set -eu

cd "$(dirname "$0")"

ID=$(awk '{print $1}' secrets/poeditor-api-key.txt)
TOKEN=$(awk '{print $2}' secrets/poeditor-api-key.txt)

RESP=$(curl -s -X POST https://api.poeditor.com/v2/contributors/list -d api_token="$TOKEN" -d id="$ID")

cd "../assets/langs"
for file in $(ls); do
    lang="${file%.*}"
    echo "Adding license for $lang"

    DATA=$(echo "$RESP" | jq -r ".result.contributors[] | select( .permissions[].languages[] | contains(\"$lang\") )")
    PEOPLE=$(echo "$DATA" | jq -r '.name + " <" + .email + ">" ')
    IFS='
' 
    for p in $PEOPLE; do
        reuse addheader --license 'CC-BY-4.0' --copyright "$p" --year '2019-2021' $file   
    done
    reuse addheader --license 'CC-BY-4.0' --copyright "Vishesh Handa <me@vhanda.in>" --year '2019-2021' $file
    unset IFS
done
