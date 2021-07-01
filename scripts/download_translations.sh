#!/usr/bin/env bash

set -eu

cd "$(dirname "$0")"

ID=$(awk '{print $1}' secrets/poeditor-api-key.txt)
TOKEN=$(awk '{print $2}' secrets/poeditor-api-key.txt)

langs=$(curl -s -X POST https://api.poeditor.com/v2/languages/list -d api_token="$TOKEN" -d id="$ID" | jq -r .result.languages[].code)

cd "../assets/langs"
for lang in $langs; do
    echo "Downloading for $lang"

    url=$(curl -s -X POST https://api.poeditor.com/v2/projects/export -d api_token="$TOKEN" -d id="$ID" -d language="$lang" -d type="yml" | jq -r .result.url)
    wget -q -O "$lang.yaml" "$url"
done

echo "Done"
