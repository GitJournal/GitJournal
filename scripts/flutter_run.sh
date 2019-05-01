#!/usr/bin/env bash

set -eu

cd "$(dirname "$0")"
touch /tmp/flutter.pid
./reload.sh &
BGPID=$!
trap 'kill $BGPID; exit' SIGINT
cd ../

DEVICES=$(adb devices -l | tail -n +2)
NUM_DEVICES=$(echo "$DEVICES" | wc -l)

if [ "$NUM_DEVICES" = 1 ]; then
    DEVICE_ID="$DEVICES"
else
    DEVICE_ID=$(echo "$DEVICES" | fzf)
fi

DEVICE_ID=$(echo "$DEVICE_ID" | awk '{ print $1 }')

echo "Running on $DEVICE_ID"
flutter run -d "$DEVICE_ID" --pid-file /tmp/flutter.pid --observatory-port 8888 "$@"
