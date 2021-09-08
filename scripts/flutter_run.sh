#!/usr/bin/env zsh

set -eu

cd "$(dirname "$0")"
cd ..

FILTER="$1"

DEVICE=$(flutter devices --device-timeout=1 --machine | jq -r '.[].name' | fzf -1 -q "$FILTER")
DEVICE_INFO=$(flutter devices --machine | jq -r ".[] | select(.name==\"$DEVICE\")")
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
    flutter run -d "$DEVICE_ID" --flavor dev --track-widget-creation
else
    echo
    echo "flutter run -d $DEVICE_ID --track-widget-creation"
    echo
    flutter run -d "$DEVICE_ID" --track-widget-creation
fi
