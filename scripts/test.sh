#!/usr/bin/env bash

set -eux

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$SCRIPT_DIR/.."

touch ~/.android/repositories.cfg

# Download all Images
for i in $(seq 21 28); do
    echo "Downling SDK $i"
    sdkmanager "system-images;android-$i;google_apis;x86"
done


for i in $(seq 21 28); do
    echo "Creating for API $i"

    NAME="gitjournal_test_api_$i"
    echo no | avdmanager create avd -n "$NAME" -f -k "system-images;android-$i;google_apis;x86"

    # Launch the device
    emulator -ports 5570,5571 -avd "$NAME" &
    EMULATOR_PID=$!

    adb wait-for-device
    adb -s emulator-5570 shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done; input keyevent 82'

    # Run the test
    flutter drive --target=test_driver/git.dart

    adb -s emulator-5570 emu kill
    kill -9 $EMULATOR_PID
    avdmanager delete avd -n "$NAME"
done
