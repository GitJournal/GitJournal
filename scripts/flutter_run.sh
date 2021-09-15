#!/usr/bin/env zsh

# SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

set -eu

cd "$(dirname "$0")"
cd ..

FILTER="$1"

DEVICE=$(./flutterw devices --device-timeout=1 --machine | jq -r '.[].name' | fzf -1 -q "$FILTER")
DEVICE_INFO=$(./flutterw devices --machine | jq -r ".[] | select(.name==\"$DEVICE\")")
DEVICE_ID=$(echo "$DEVICE_INFO" | jq -r .id)
DEVICE_TARGET=$(echo "$DEVICE_INFO" | jq -r .targetPlatform)

#echo "Device: $DEVICE"
#echo "Device ID: $DEVICE_ID"
#echo "Device Target: $DEVICE_TARGET"

#print -s "make run \"$DEVICE\""

if [[ $DEVICE_TARGET == *"android"* ]]; then
    echo
    echo "flutter run -d $DEVICE_ID --flavor dev --track-widget-creation"
    echo
    ./flutterw run -d "$DEVICE_ID" --flavor dev --track-widget-creation
else
    echo
    echo "flutter run -d $DEVICE_ID --track-widget-creation"
    echo
    ./flutterw run -d "$DEVICE_ID" --track-widget-creation
fi
