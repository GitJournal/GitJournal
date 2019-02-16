#!/usr/bin/env bash
#
# This script adds the status bar on top of all the images
# It is required as flutter driver screenshot does not include the status bar
#

set -eu

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$SCRIPT_DIR/.."

DIR_NAME='./screenshots'
cd $DIR_NAME

for i in *.png; do
    FILE_NAME=$(basename "${i}" .png)_final.jpg
    echo "Converting $i -> $FILE_NAME"

    convert "${i}" "$SCRIPT_DIR/status_bar.png" -composite "${FILE_NAME}"
done
